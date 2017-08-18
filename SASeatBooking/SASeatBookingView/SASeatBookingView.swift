
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
    func seatBookingView(_ view: SASeatBookingView,canSelectSeatAt position: SASeatPosition) -> Bool
    func seatBookingView(_ view: SASeatBookingView,didSelect seat : SCNNode,  at position: SASeatPosition)
    func seatBookingView(_ view: SASeatBookingView,didDeselect seat : SCNNode, at position: SASeatPosition)
}

protocol SASeatFactoryProtocol {
    var availableSeat : SCNGeometry { get }
    var occupiedSeat : SCNGeometry { get }
    var availableRest : SCNGeometry { get }
    var occupiedRest : SCNGeometry { get }
}

fileprivate extension Selector {
    static let touchHandler = #selector(SASeatBookingView.touchHandler(recognizer:))
}

class SASeatBookingView: SCNView {
    class SASeatBookingNode : SCNNode {
        let seatPosition :  SASeatPosition
        var selected : Bool = false
        init(position : SASeatPosition) {
            seatPosition = position
            super.init()
        }
        required init?(coder aDecoder: NSCoder) {
            seatPosition = (column: 0, row:0)
            super.init(coder: aDecoder)
        }
    }
    var save : Bool = false
    let offset = CGPoint.zero
    let seatToSeatDistance = (x:CGFloat(0.2),z:CGFloat(1))
    lazy var originNode : SCNNode = SCNNode()
    lazy var selectAction : SCNAction = {
       let moveUp = SCNAction.move(by: SCNVector3Make(0, 0.5, 0), duration: 1)
        moveUp.timingMode = .easeOut
        return moveUp
    }()
    
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
    
    @objc func touchHandler(recognizer : UITapGestureRecognizer) {
        let p = recognizer.location(in: self)
        let renderer = self as SCNSceneRenderer
        let results = renderer.hitTest(p, options: nil)
        let nodes = results.flatMap({ self.seatNode(for: $0.node) as? SASeatBookingNode })
            .filter { node in
                let position = node.seatPosition
                let canSelect = self.seatDelegate?.seatBookingView(self, canSelectSeatAt: position) ?? false
                return canSelect
        }
        if let seatNode = nodes.first, let node = seatNode.childNodes.first {
            if !seatNode.selected {
                seatNode.selected = true
                self.seatDelegate?.seatBookingView(self, didSelect: node, at: seatNode.seatPosition)
                seatNode.runAction(self.selectAction)
            }
            else {
                seatNode.selected = false
                self.seatDelegate?.seatBookingView(self, didDeselect: node, at: seatNode.seatPosition)
                seatNode.runAction(self.selectAction.reversed())
            }
        }
    }
    
}

fileprivate extension SASeatBookingView {
    func seatNode(for node: SCNNode?) -> SCNNode? {
        guard let bookingNode = node else {
            return nil
        }
        if let _ = bookingNode as? SASeatBookingNode {
            return node
        }
        return seatNode(for:node?.parent)
    }
    
    func setup() {
        self.scene = SCNScene()
        self.scene?.rootNode.addChildNode(self.originNode)
        self.scene?.rootNode.addChildNode(self.cameraNode)
        self.scene?.rootNode.addChildNode(self.floorNode)
        let touchHandler = UITapGestureRecognizer(target: self, action: Selector.touchHandler)
        self.addGestureRecognizer(touchHandler)
    }
    
    func seatBookingNode(for node: SCNNode,with position: SASeatPosition) -> SASeatBookingNode {
        let containerNode = SASeatBookingNode(position: position)
        containerNode.addChildNode(node)
        let box = node.boundingBox
        let width = box.max.x - box.min.x
        let length = box.max.z - box.min.z
        let (x,z) = position
        containerNode.position = SCNVector3Make(Float(x) * (Float(width) + Float(self.seatToSeatDistance.x)) + Float(offset.x),
                                                -Float(box.min.y),
                                                -Float(z) * (Float(length)+Float(self.seatToSeatDistance.z)) + Float(offset.y))
        return containerNode
    }
    
    func setupSetMap() {
        guard let seatDataSource = self.seatDataSource
                 else {
            return
        }
        let size = seatDataSource.numberOfRowsAndColumnsInSeatBookingView(self)
        for (z,x) in SASeatBookingSequence(size: size) {
            let position = (column:x,row:z)
            if let seatNode = seatDataSource.seatBookingView(self, nodeAt: position) {
                let containerNode = seatBookingNode(for: seatNode,with: position)
                originNode.addChildNode(containerNode)
            }
        }
        originNode = originNode.flattenedClone()
    }

}
