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

enum LightingType {
    case none, auxOnly, mainOnly, auxAndMain
}

fileprivate func degreesToRadians(_ degrees: Float) -> Float {
    return (degrees * Float.pi) / 180.0
}

fileprivate func radiansToDegrees(_ radians: Float) -> Float {
    return (180.0 / Float.pi) * radians
}

public class MovieTheaterView: UIView {

    var movieTheaterScene:SCNScene?
    var motionManager : CMMotionManager?
    var currentLighting:LightingType = .mainOnly
    
    init(withPlayer aPlayer: AVPlayer) {
        
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
        
        self.addConstraints([
            NSLayoutConstraint(item: leftSceneView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftSceneView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftSceneView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: leftSceneView, attribute: .trailing, relatedBy: .equal, toItem: rightSceneView, attribute: .leading, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: leftSceneView, attribute: .width, relatedBy: .equal, toItem: rightSceneView, attribute: .width, multiplier: 1.0, constant: 0.0),
            
            
            NSLayoutConstraint(item: rightSceneView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightSceneView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightSceneView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            
            ])
        
        
        // Create Scene
        guard let safeMovieTheaterScene = SCNScene(named: "MovieTheater.scn") else {
            return
        }
        
        self.movieTheaterScene = safeMovieTheaterScene
        
        leftSceneView.scene = safeMovieTheaterScene
        rightSceneView.scene = safeMovieTheaterScene
        
        let leftCameraNode = safeMovieTheaterScene.rootNode.childNode(withName: "cameraL", recursively: true)
        let rightCameraNode = safeMovieTheaterScene.rootNode.childNode(withName: "cameraR", recursively: true)
        let camerasNode = safeMovieTheaterScene.rootNode.childNode(withName: "camerasNode", recursively: true)
        
        leftSceneView.pointOfView = leftCameraNode!
        rightSceneView.pointOfView = rightCameraNode!
        
        self.currentLighting = LightingType.none
        
        //Create 2D SpriteKit scene with Video Node pointing to AVPlayer
        let videoScene = SKScene(size: CGSize(width: 640, height: 360))
        let videoNode = SKVideoNode(avPlayer: aPlayer)
        videoNode.size = videoScene.size
        videoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        videoScene.addChild(videoNode)
        videoNode.play()
        
        //Create a SceneKit material texture from the 2D SpriteKit movie scene
        let videoMaterialProperty = SCNMaterialProperty(contents: videoScene)
        let videoMaterial = SCNMaterial()
        videoMaterial.diffuse.contents = videoMaterialProperty.contents
        videoMaterial.specular.contents = videoMaterialProperty.contents
        videoMaterial.emission.contents = videoMaterialProperty.contents
        videoMaterial.isDoubleSided = true
        
        let screen = safeMovieTheaterScene.rootNode.childNode(withName: "movieScreen", recursively: false)
        screen?.geometry?.materials = [videoMaterial]
        
        // Respond to user head movement
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        
        self.motionManager?.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical, to: OperationQueue.main, withHandler: { (motion: CMDeviceMotion?, error: Error?) -> Void in
            camerasNode!.eulerAngles = SCNVector3Make(
                Float(motion!.attitude.roll)+degreesToRadians(-90.0),
                Float(motion!.attitude.yaw),
                Float(motion!.attitude.pitch));
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func screenTapped() {
        NSLog("screen tapped")
        
        guard let safeMovieTheaterScene = self.movieTheaterScene else {
            return
        }
        
        switch self.currentLighting {
        case LightingType.none:
            safeMovieTheaterScene.rootNode.childNode(withName: "mainLighting", recursively: true)?.isHidden = true
            safeMovieTheaterScene.rootNode.childNode(withName: "auxLighting", recursively: true)?.isHidden = true
            self.currentLighting = LightingType.auxOnly
            break
        case LightingType.auxOnly:
            safeMovieTheaterScene.rootNode.childNode(withName: "mainLighting", recursively: true)?.isHidden = true
            safeMovieTheaterScene.rootNode.childNode(withName: "auxLighting", recursively: true)?.isHidden = false
            self.currentLighting = LightingType.mainOnly
            break
        case LightingType.mainOnly:
            safeMovieTheaterScene.rootNode.childNode(withName: "mainLighting", recursively: true)?.isHidden = false
            safeMovieTheaterScene.rootNode.childNode(withName: "auxLighting", recursively: true)?.isHidden = true
            self.currentLighting = LightingType.auxAndMain
            break
        case LightingType.auxAndMain:
            safeMovieTheaterScene.rootNode.childNode(withName: "mainLighting", recursively: true)?.isHidden = false
            safeMovieTheaterScene.rootNode.childNode(withName: "auxLighting", recursively: true)?.isHidden = false
            self.currentLighting = LightingType.none
            break
        }
    }
}
