//
//  SASeatBookingView.swift
//  SASeatBooking
//
//  Created by Frank Saar on 08/08/2017.
//  Copyright © 2017 SAMedialabs. All rights reserved.
//
import Foundation
import UIKit
import SceneKit

typealias SASeatPosition = (column: Int,row: Int)
typealias SASeatBookingSize = (columns: Int,rows :Int)

enum SASeatBookingType : Int {
    case occupied
    case available
    case space
}

protocol SASeatBookingViewDatasource : class {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize
    func seatBookingView(_ view: SASeatBookingView,nodeAt position:  SASeatPosition) -> SCNNode
}

protocol SASeatBookingViewDelegate : class {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition)
}

// 1. Add Subscript
// 2. add Generator
class SASeatBookingView: SCNView {
    let offset = CGPoint.zero
    let seatToSeatDistance = (x:CGFloat(2),z:CGFloat(10))
    lazy var originNode : SCNNode = SCNNode()
    
    lazy var lightNode : SCNNode = {
        let light = SCNLight()
        light.type = .directional
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    lazy var cameraNode : SCNNode = {
        let camera = SCNCamera()
        camera.zFar = 500
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.addChildNode(lightNode)
        cameraNode.position = SCNVector3Make(5, 60, 20)
        cameraNode.constraints = [SCNLookAtConstraint(target:originNode)]
        cameraNode.addChildNode(self.lightNode)
        return cameraNode
    }()
    
    lazy var floorNode : SCNNode = {
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents =   UIColor.white //"Circles.jpg";
    
        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 3.0
        floor.firstMaterial? = floorMaterial
        let floorNode = SCNNode()
        floorNode.geometry = floor
        return floorNode
    }()
    
    
    weak var seatDataSource : SASeatBookingViewDatasource? = nil {
        didSet {
            setupSetMap()
        }
    }
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        self.allowsCameraControl = true
    }
    
    weak var seatDelegate : SASeatBookingViewDelegate?
    
    var defaultSeatSize = (width: CGFloat(10),height:CGFloat(10),length:CGFloat(10))
    
    lazy var occupiedSeat : SCNBox = {
        let occupiedSeat = SCNBox(width: self.defaultSeatSize.width, height: self.defaultSeatSize.height, length: self.defaultSeatSize.length, chamferRadius: 2)
        occupiedSeat.materials.first!.diffuse.contents = UIColor.red.withAlphaComponent(0.85)
        return occupiedSeat
    }()

    lazy var availableSeat : SCNBox =  {
        let availableSeat = SCNBox(width: self.defaultSeatSize.width, height: self.defaultSeatSize.height, length: self.defaultSeatSize.length, chamferRadius: 2)
        availableSeat.materials.first!.diffuse.contents = UIColor.green
        return availableSeat
    }()
    
    func dequeueNode(of type:SASeatBookingType) -> SCNNode {
        let seatNode = SCNNode()
        
        switch type {
        case .available:
            seatNode.geometry = self.availableSeat
        case .occupied:
            seatNode.geometry = self.occupiedSeat
        case .space:
            seatNode.isHidden = true
        }
        return seatNode
    }
    
    func reloadData() {
        self.originNode.childNodes.forEach { $0.removeFromParentNode() }
        setupSetMap()
    }
}

fileprivate extension SASeatBookingView {
    func setup() {
        self.scene = SCNScene()
        self.scene?.rootNode.addChildNode(self.originNode)
        self.scene?.rootNode.addChildNode(self.cameraNode)
    }
    
    func setupSetMap() {
        guard let seatDataSource = self.seatDataSource
                 else {
            return
        }
        let size = seatDataSource.numberOfRowsAndColumnsInSeatBookingView(self)
        for (z,x) in SASeatBookingSequence(size: size) {
            let seatNode = seatDataSource.seatBookingView(self, nodeAt: (column:x,row:z))
            seatNode.position = SCNVector3Make(Float(x) * (Float(defaultSeatSize.width) + Float(self.seatToSeatDistance.x)) + Float(offset.x),
                                               Float(defaultSeatSize.height)/2,
                                               -Float(z) * (Float(defaultSeatSize.length)+Float(self.seatToSeatDistance.z)) + Float(offset.y))
            originNode.addChildNode(seatNode)
        }
        originNode.flattenedClone() 
    }
    
}
