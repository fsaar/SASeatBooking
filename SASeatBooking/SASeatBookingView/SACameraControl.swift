//
//  SACameraControl.swift
//  PanTest
//
//  Created by Frank Saar on 24/08/2017.
//  Copyright © 2017 SAMedialabs. All rights reserved.
//

import UIKit
import SceneKit

class SACameraControl {
    let cameraNode : SCNNode
    var cameraHeight : Float = 0

    init(with view: UIView,for camera: SCNNode) {
        self.cameraNode = camera
        self.cameraHeight = camera.position.y
        addRecognizers(to: view)
    }
    
    
    func addRecognizers(to view: UIView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(recognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,action:#selector(pinch(recognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    @objc func pinch(recognizer : UIPinchGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            cameraHeight = cameraNode.position.y
        case .changed,.ended:
            let scale = Float(recognizer.scale)
            let pos = cameraNode.position
            let newHeight = cameraHeight + (1-scale) * 10
            let newPos = SCNVector3(pos.x,newHeight,pos.z)
            let action = SCNAction.move(to: newPos, duration: 0.1)
            cameraNode.runAction(action)
        default:
            break
        }
    }
    
    @objc func pan(recognizer : UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: recognizer.view)
        switch recognizer.numberOfTouches {
        case 1:
            let v = SIMD2<Float>(Float(velocity.x),Float(velocity.y))
            let normalized = simd_normalize(v)
            let vector = SCNVector3Make(normalized.x/5,0 , normalized.y/5)
            let action = SCNAction.move(by: vector, duration: 0.1)
            cameraNode.runAction(action)
        case 2:
            let unit_in_radian = CGFloat(Double.pi / 180) / 5
            let angles = velocity.y > 0 ? unit_in_radian : -unit_in_radian
            let action = SCNAction.rotateBy(x: angles, y: 0, z: 0, duration: 0.1)
            cameraNode.runAction(action)
        default:
            break
        }
    }
}
