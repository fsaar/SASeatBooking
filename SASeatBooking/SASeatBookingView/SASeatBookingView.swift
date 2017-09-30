
import Foundation
import UIKit
import SceneKit
import SceneKit.ModelIO

typealias SASeatPosition = (column: Int,row: Int)
typealias SASeatBookingSize = (columns: Int,rows :Int)


extension SCNTransaction {
    static func animation(with duration : CFTimeInterval,
                   and timingFunction : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear),
                   using animationBlock: () ->(),
                   and completionBlock : (()->())? = nil) {
        self.begin()
        self.animationTimingFunction = timingFunction
        self.animationDuration = duration
        self.completionBlock = {
            completionBlock?()
        }
        animationBlock()
        self.commit()
    }
}



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
    static let tapHandler = #selector(SASeatBookingView.tapHandler(recognizer:))
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
    var cameraControl : SACameraControl?
    let offset = CGPoint.zero
    let seatToSeatDistance = (x:CGFloat(0.2),z:CGFloat(1))
    lazy var originNode : SCNNode = SCNNode()
    lazy var selectAction : SCNAction = {
       let moveUp = SCNAction.move(by: SCNVector3Make(0, 0.5, 0), duration: 1)
        moveUp.timingMode = .easeOut
        return moveUp
    }()
   
    lazy var light : SCNLight = {
        let light = SCNLight()
        light.intensity = 1000
        light.type = .omni
        return light
    }()
    
    lazy var lightNode : SCNNode = {
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3Make(0, 10, 0)
        return lightNode
    }()
    
    lazy var cameraNode : SCNNode = {
        let camera = SCNCamera()
        camera.zFar = 500
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(5, 60, 20)
        return cameraNode
    }()
    

    lazy var animationCameraNode : SCNNode = {
        let camera = SCNCamera()
        camera.zFar = 500
        let animationCameraNode = SCNNode()
        animationCameraNode.camera = camera
        animationCameraNode.position = SCNVector3Make(-100, 100, 100)
        animationCameraNode.eulerAngles = SCNVector3(-Double.pi / 4,-Double.pi / 2,0)
        return animationCameraNode
    }()
    

    
    lazy var floorNode : SCNNode = {
        let floorMaterial = SCNMaterial()
    
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        let floorNode = SCNNode()
        floorNode.geometry = floor
        return floorNode
    }()
    
    
    weak var seatDelegate : SASeatBookingViewDelegate?
    weak var seatDataSource : SASeatBookingViewDatasource? = nil {
        didSet {
            setupSeatMap()
            setupCamera()

        }
    }
    
    init(frame: CGRect, options: [String : Any]? = nil,with animationEnabled : Bool = false) {
        super.init(frame: frame, options: options)
        setup(animationEnabled: animationEnabled)
    }


    
    func startAnimation() {
        SCNTransaction.animation(with: 1.5,and: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),using:  {
            self.pointOfView = self.cameraNode
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        self.showsStatistics = true
    }
    
    func reloadData() {
        self.originNode.childNodes.forEach { $0.removeFromParentNode() }
        setupSeatMap()
        setupCamera()
    }
    
    @objc func tapHandler(recognizer : UITapGestureRecognizer) {
        let p = recognizer.location(in: self)
        let renderer = self as SCNSceneRenderer
        let results = renderer.hitTest(p, options: nil)
        handleSelection(results: results)
    }
    
    func handleSelection(results : [SCNHitTestResult]) {
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
// MARK: Helper methods
fileprivate extension SASeatBookingView {
    
    func seatNode(for node: SCNNode?) -> SCNNode? {
        guard let bookingNode = node else {
            return nil
        }
        return bookingNode as? SASeatBookingNode  ?? seatNode(for:node?.parent)
    }
    
    func setup(animationEnabled : Bool = false) {
        self.scene = SCNScene()
        self.scene?.rootNode.addChildNode(self.originNode)
        self.originNode.addChildNode(lightNode)
        self.scene?.rootNode.addChildNode(self.cameraNode)
        self.scene?.rootNode.addChildNode(self.animationCameraNode)
        self.scene?.rootNode.addChildNode(self.floorNode)
        
        let tapHandler = UITapGestureRecognizer(target: self, action: Selector.tapHandler)
        self.addGestureRecognizer(tapHandler)
        
        self.cameraControl = SACameraControl(with: self, for: self.cameraNode)
        self.pointOfView = animationEnabled ? self.animationCameraNode : self.cameraNode
    }
    
    func scenePosition(for node: SCNNode, at seatPosition: SASeatPosition) -> SCNVector3 {
        let box = node.boundingBox
        let width = box.max.x - box.min.x
        let length = box.max.z - box.min.z
        let (x,z) = seatPosition
        return SCNVector3Make(Float(x) * (Float(width) + Float(self.seatToSeatDistance.x)) + Float(offset.x),
                                                -Float(box.min.y),
                                                -Float(z) * (Float(length)+Float(self.seatToSeatDistance.z)) + Float(offset.y))

    }
    
    func seatBookingNode(for node: SCNNode,with position: SASeatPosition) -> SASeatBookingNode {
        let containerNode = SASeatBookingNode(position: position)
        containerNode.addChildNode(node)
        containerNode.position = scenePosition(for: node, at: position)
        return containerNode
    }
    
    func setupSeatMap() {
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
    }
    func boundingBox(for size: SASeatBookingSize) -> (min: SCNVector3, max: SCNVector3)? {
        let sortedNodes = originNode.childNodes.flatMap { $0 as? SASeatBookingNode }.sorted { node1,node2 in
            let pos1 = node1.seatPosition
            let pos2 = node2.seatPosition
            let index1 = pos1.column + pos1.row * size.rows
            let index2 = pos2.column + pos2.row * size.rows
            return index1 < index2
        }
        switch sortedNodes.count {
        case 1...:
            let v1 = sortedNodes[0].position
            let v2 = sortedNodes[sortedNodes.count-1].position
            return (min:v1,max:v2)
        default:
            return nil
        }
    }
    
    func setupCamera() {
        guard let size = seatDataSource?.numberOfRowsAndColumnsInSeatBookingView(self),let bounds = boundingBox(for: size) else {
            return
        }
        let width = bounds.max.x - bounds.min.x
        self.cameraNode.position = SCNVector3Make(width/2, 10, 10)
        self.cameraNode.rotation = SCNVector4Make(1, 0, 0, -Float(30 * Double.pi/180))
    }

}
