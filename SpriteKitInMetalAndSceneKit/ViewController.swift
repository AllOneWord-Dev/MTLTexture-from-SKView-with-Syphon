//
//  ViewController.swift
//  SpriteKitInMetalAndSceneKit
//
//  Created by Johnny Turpin on 5/18/24.
//

import Cocoa
import SpriteKit
import SceneKit
import MetalKit
import simd


class ViewController: NSViewController {

	@IBOutlet var mainView: NSView!
	@IBOutlet weak var skView: SKView!
	@IBOutlet weak var scnView: SCNView!
	
	var myScene: MyScene!
	var scnScene: SCNScene!
	var plane:SCNGeometry!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = NSColor(calibratedWhite: 0.1, alpha: 1.0).cgColor
		
		if let scene = SKScene(fileNamed: "MyScene") as? MyScene {
			myScene = scene
			skView.presentScene(scene)
			skView.ignoresSiblingOrder = true
			skView.showsFPS = true
			myScene.setupMetal()
			myScene.setupTexture()
		}
		
		scnScene = SCNScene()
		plane = SCNPlane(width: 600, height: 600)
		let planeNode = SCNNode(geometry: plane)
		scnScene.rootNode.addChildNode(planeNode)
		scnView.scene = scnScene
		scnView.autoenablesDefaultLighting = true
		scnView.allowsCameraControl = false
		scnView.isPlaying = true
		plane.materials.first?.diffuse.contents = myScene.offscreenTexture.makeTextureView(pixelFormat: .bgra8Unorm_srgb)
		
		skView.wantsLayer = true
		skView.layer?.cornerRadius = 10
		skView.layer?.masksToBounds = true
		scnView.wantsLayer = true
		scnView.layer?.masksToBounds = true
		scnView.layer?.cornerRadius = 10
		
	}
	


	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

