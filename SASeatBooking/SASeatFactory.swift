
import Foundation
import UIKit
import SceneKit


enum SASeatFactoryType {
    
    case occupied
    case available
    case space
}

class SASeatFactory {
    let seatSize : (width : CGFloat,height: CGFloat, length: CGFloat)
    init(width: CGFloat,height:CGFloat,length:CGFloat) {
        seatSize = (width,height,length)
    }
    fileprivate lazy var availableSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 0.2)
        seat.materials.first!.diffuse.contents = #imageLiteral(resourceName: "greenChenille")
        return seat
    }()
    fileprivate lazy var occupiedSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 0.2)
        seat.materials.first!.diffuse.contents = #imageLiteral(resourceName: "redchenille")
        return seat
    }()
    
    fileprivate lazy var availableRest : SCNGeometry = {
        let rest = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length/3, chamferRadius: 2)
        rest.materials.first!.diffuse.contents = #imageLiteral(resourceName: "greenChenille")
        return rest
    }()
    fileprivate lazy var occupiedRest : SCNGeometry = {
        let rest = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length/3, chamferRadius: 2)
        rest.materials.first!.diffuse.contents = #imageLiteral(resourceName: "redchenille")
        return rest
    }()
    
    func seat(of type:SASeatFactoryType) -> SCNNode {
        let seatNode = self.seatNode(of: type)
        return seatNode
    }

    fileprivate func seatNode(of type: SASeatFactoryType) -> SCNNode {
        let restNode = SCNNode()
        let seatNode = SCNNode()
        let node = SCNNode()
        node.addChildNode(seatNode)
        node.addChildNode(restNode)
        var seat : SCNGeometry?
        var rest : SCNGeometry?
        switch type {
        case .available:
            seat = self.availableSeat
            rest = self.availableRest
        case .occupied:
            seat = self.occupiedSeat
            rest = self.occupiedRest
        case .space:
            seatNode.isHidden = true
            seat = nil
        }
        seatNode.geometry = seat
        restNode.geometry = rest
        restNode.position = SCNVector3Make(0, Float(self.seatSize.height * 7/8), -Float(self.seatSize.length/3))
        node.flattenedClone()
        return node
    }

}
