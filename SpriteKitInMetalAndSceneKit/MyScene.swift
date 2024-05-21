//
//  MyScene.swift
//  SpriteKitInMetalAndSceneKit
//
//  Created by Johnny Turpin on 5/18/24.
//

import Cocoa
import SpriteKit
import simd
import Syphon

class MyScene: SKScene {
	var rootNode: SKEffectNode!
	var shapeNode: SKShapeNode?
	var ratio: Double = 2
	var dx: Float = 100
	var device:MTLDevice!
	var commandQueue: MTLCommandQueue!
	var skRenderer: SKRenderer!
	var offscreenTexture:MTLTexture!
	let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
	let bytesPerPixel = Int(4)
	let bitsPerComponent = Int(8)
	let bitsPerPixel:Int = 32
	var textureSizeX:Int = 600
	var textureSizeY:Int = 600
	
	var syphonServer: SyphonMetalServer?
	

	override func didMove(to view: SKView) {
		rootNode = SKEffectNode()
		rootNode.blendMode = .add
		shapeNode = SKShapeNode(rectOf: CGSize(width: 70, height: 70), cornerRadius: 10)
		shapeNode?.blendMode = .add
		shapeNode?.lineWidth = 3
		shapeNode?.isAntialiased = true
		shapeNode?.strokeColor = .systemPink
		shapeNode?.run(SKAction.sequence([SKAction.wait(forDuration: 0.25), SKAction.fadeOut(withDuration: 0.35), SKAction.removeFromParent()]))
		self.addChild(rootNode)
	}

	func setupMetal() {
		guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Could not create a metal view") }
		self.device = device
		skRenderer = SKRenderer(device: device)
		commandQueue = device.makeCommandQueue()
		skRenderer.scene = self
		
		syphonServer = SyphonMetalServer(name: "EulerServer", device: device)
		if syphonServer != nil {
			print("syphonServer has started!")
		}
	}
	
	func setupTexture() {
		var rawData0 = [UInt8](repeating: 0, count: Int(textureSizeX) * Int(textureSizeY) * 4)
		
		let bytesPerRow = 4 * Int(textureSizeX)
		let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
		
		let context = CGContext(data: &rawData0, width: Int(textureSizeX), height: Int(textureSizeY), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: bitmapInfo)!
		context.setFillColor(NSColor(calibratedWhite: 0.0, alpha: 1.0).cgColor)
		context.fill(CGRect(x: 0, y: 0, width: CGFloat(textureSizeX), height: CGFloat(textureSizeY)))

		let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.bgra8Unorm, width: Int(textureSizeX), height: Int(textureSizeY), mipmapped: false)
		
		textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
		
		let textureA = device.makeTexture(descriptor: textureDescriptor)!
		
		let region = MTLRegionMake2D(0, 0, Int(textureSizeX), Int(textureSizeY))
		textureA.replace(region: region, mipmapLevel: 0, withBytes: &rawData0, bytesPerRow: Int(bytesPerRow))

		offscreenTexture = textureA
	}
	
	override func update(_ currentTime: TimeInterval) {
		
		doMetalRender()
		
		var timeInterval: Double = 1/60
		if currentTime > 200000 {
			timeInterval = currentTime - 200000
		} else {
			timeInterval = currentTime
		}
		if let node = self.shapeNode?.copy() as? SKShapeNode {
			let x = dx * sinf(Float(timeInterval))
			let y = dx * sinf(Float(timeInterval*ratio))
			node.position = CGPoint(x: Double(x), y: Double(y))
			node.zRotation = timeInterval
			rootNode?.addChild(node)
		}
	}
	
	
	func doMetalRender() {
		//rendering to a MTLTexture, so the viewport is the size of this texture
		let viewport = CGRect(x: 0, y: 0, width: CGFloat(textureSizeX), height: CGFloat(textureSizeY))
		
		//write to offscreenTexture, clear the texture before rendering using green, store the result
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = offscreenTexture
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1.0); //green
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		let commandBuffer = commandQueue.makeCommandBuffer()!
		skRenderer.render(withViewport: viewport, commandBuffer: commandBuffer, renderPassDescriptor: renderPassDescriptor)
		self.syphonServer?.publishFrameTexture(offscreenTexture, on: commandBuffer, imageRegion: viewport, flipped: true)
		commandBuffer.commit()
	}
}
