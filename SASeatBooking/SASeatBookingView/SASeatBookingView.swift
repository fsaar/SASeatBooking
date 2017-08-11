
import Foundation
import UIKit
import SceneKit
import SceneKit.ModelIO

typealias SASeatPosition = (column: Int,row: Int)
typealias SASeatBookingSize = (columns: Int,rows :Int)


protocol SASeatBookingViewDatasource : class {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize
    func seatBookingView(_ view: SASeatBookingView,nodeAt position:  SASeatPosition) -> SCNNode?
}

protocol SASeatBookingViewDelegate : class {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition)
}

protocol SASeatFactoryProtocol {
    var availableSeat : SCNGeometry { get }
    var occupiedSeat : SCNGeometry { get }
    var availableRest : SCNGeometry { get }
    var occupiedRest : SCNGeometry { get }
}

class SASeatBookingView: SCNView {
    var save : Bool = false
    let offset = CGPoint.zero
    let seatToSeatDistance = (x:CGFloat(0.2),z:CGFloat(1))
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
        floor.firstMaterial?.diffuse.contents = UIColor.lightGray
        let floorNode = SCNNode()
        floorNode.geometry = floor
        return floorNode
    }()
    
    
    weak var seatDelegate : SASeatBookingViewDelegate?
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
        self.showsStatistics = true
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
        self.scene?.rootNode.addChildNode(self.floorNode)
    }
    
    func setupSetMap() {
        guard let seatDataSource = self.seatDataSource
                 else {
            return
        }
        let size = seatDataSource.numberOfRowsAndColumnsInSeatBookingView(self)
        for (z,x) in SASeatBookingSequence(size: size) {
            if let seatNode = seatDataSource.seatBookingView(self, nodeAt: (column:x,row:z)) {
                let box = seatNode.boundingBox
                let width = box.max.x - box.min.x
                let length = box.max.z - box.min.z
                seatNode.position = SCNVector3Make(Float(x) * (Float(width) + Float(self.seatToSeatDistance.x)) + Float(offset.x),
                                                   -Float(box.min.y),
                                                   -Float(z) * (Float(length)+Float(self.seatToSeatDistance.z)) + Float(offset.y))
                originNode.addChildNode(seatNode)
            }
        }
        originNode = originNode.flattenedClone()
    }

}
