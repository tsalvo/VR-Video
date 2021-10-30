//
//  MovieTheaterView.swift
//  CDMPlayer
//
//  Created by Tom Salvo on 11/19/16.
//
//

import UIKit
import SceneKit
import SpriteKit
import CoreMotion
import AVFoundation

class MovieTheaterView: UIView {

    private enum Lighting {
        case none, auxOnly, mainOnly, auxAndMain
        
        var isMainLightOn: Bool {
            switch self {
            case .mainOnly, .auxAndMain: return true
            default: return false
            }
        }
        
        var isAuxLightOn: Bool {
            switch self {
            case .auxOnly, .auxAndMain: return true
            default: return false
            }
        }
        
        var next: Lighting {
            switch self {
            case .none: return .auxOnly
            case .auxOnly: return .mainOnly
            case .mainOnly: return .auxAndMain
            case .auxAndMain: return .none
            }
        }
    }
    
    private static let motionRollInitialOffset: Float = (-90.0 * Float.pi) / 180.0
    private let movieTheaterScene: SCNScene
    private let motionManager: CMMotionManager
    private var currentLighting: Lighting {
        didSet {
            self.movieTheaterScene.rootNode.childNode(withName: "mainLighting", recursively: true)?.isHidden = !self.currentLighting.isMainLightOn
            self.movieTheaterScene.rootNode.childNode(withName: "auxLighting", recursively: true)?.isHidden = !self.currentLighting.isAuxLightOn
        }
    }
    
    init?(withPlayer aPlayer: AVPlayer) {
        
        // Create Scene
        guard let safeMovieTheaterScene = SCNScene(named: "MovieTheater.scn") else {
            return nil
        }
        
        self.movieTheaterScene = safeMovieTheaterScene
        self.motionManager = CMMotionManager()
        self.currentLighting = .auxAndMain
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let leftSceneView = SCNView()
        let rightSceneView = SCNView()
        leftSceneView.translatesAutoresizingMaskIntoConstraints = false
        rightSceneView.translatesAutoresizingMaskIntoConstraints = false
        leftSceneView.loops = true
        leftSceneView.isPlaying = true
        rightSceneView.loops = true
        rightSceneView.isPlaying = true
        
        self.addSubview(leftSceneView)
        self.addSubview(rightSceneView)
        
        // pin left and right scene views onto left and right sides of MovieTheaterView
        self.topAnchor.constraint(equalTo: leftSceneView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: leftSceneView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: leftSceneView.leadingAnchor).isActive = true
        leftSceneView.trailingAnchor.constraint(equalTo: rightSceneView.leadingAnchor).isActive = true
        leftSceneView.widthAnchor.constraint(equalTo: rightSceneView.widthAnchor).isActive = true
        self.topAnchor.constraint(equalTo: rightSceneView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: rightSceneView.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: rightSceneView.trailingAnchor).isActive = true
        
        leftSceneView.scene = safeMovieTheaterScene
        rightSceneView.scene = safeMovieTheaterScene
        
        guard let leftCameraNode = safeMovieTheaterScene.rootNode.childNode(withName: "cameraL", recursively: true),
              let rightCameraNode = safeMovieTheaterScene.rootNode.childNode(withName: "cameraR", recursively: true),
              let camerasNode = safeMovieTheaterScene.rootNode.childNode(withName: "camerasNode", recursively: true),
              let screen = safeMovieTheaterScene.rootNode.childNode(withName: "movieScreen", recursively: false)
        else
        {
            return
        }
        
        leftSceneView.pointOfView = leftCameraNode
        rightSceneView.pointOfView = rightCameraNode
        
        //Create 2D SpriteKit scene with Video Node pointing to AVPlayer
        let videoScene = SKScene(size: CGSize(width: 640, height: 360))
        let videoNode = SKVideoNode(avPlayer: aPlayer)
        videoNode.size = videoScene.size
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoScene.addChild(videoNode)
        videoNode.play()
        
        //Create a SceneKit material texture from the 2D SpriteKit movie scene
        let videoMaterialProperty = SCNMaterialProperty(contents: videoScene)
        let videoMaterial = SCNMaterial()
        videoMaterial.diffuse.contents = videoMaterialProperty.contents
        videoMaterial.specular.contents = videoMaterialProperty.contents
        videoMaterial.emission.contents = videoMaterialProperty.contents
        videoMaterial.isDoubleSided = true
        screen.geometry?.materials = [videoMaterial]
        
        // Respond to user head movement
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical, to: OperationQueue.main, withHandler: { (motion: CMDeviceMotion?, error: Error?) -> Void in
            camerasNode.eulerAngles = SCNVector3Make(
                Float(motion!.attitude.roll) + MovieTheaterView.motionRollInitialOffset,
                Float(motion!.attitude.yaw),
                Float(motion!.attitude.pitch));
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func screenTapped() {
        self.currentLighting = self.currentLighting.next
    }
}
