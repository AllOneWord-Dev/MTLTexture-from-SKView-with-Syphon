# SpriteKit View with Syphon Server Output

![Screenshot](https://raw.githubusercontent.com/AllOneWord-Dev/MTLTexture-from-SKView-with-Syphon/main/docs/screenshot.png)


Example of how to grab a MTLTexture from a SpriteKit scene (a MTLTexture is used in publishing frames to a Syphon Server instance)

In this example, there is a single SKScene - which is rendered to an SKView (the view on the left). There is also a separate SKRenderer() that is called in the SKScene update() method. The SKRenderer is used to render to a MTLTexture.

This MTLTexture is then used as both the source of a SceneKit Plane Node texture which is rendered in a SCNView and also published to the Syphon Server.

This simple project is based on the following SceneKitOffscreenRendering example:

[SceneKitOffscreenRendering](https://github.com/lachlanhurst/SceneKitOffscreenRendering)

To view the output of the Syphon Server - easiest to download the [Syphon Recorder Demo App from the Syphon Project](https://syphon.github.io/recorder). But should also work in any Syphon enabled client.
