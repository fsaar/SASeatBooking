
import Foundation
import UIKit
import SceneKit


class SASeatFactory : SASeatFactoryProtocol{
    let seatSize : (width : CGFloat,height: CGFloat, length: CGFloat)
    init(width: CGFloat,height:CGFloat,length:CGFloat) {
        seatSize = (width,height,length)
    }
    lazy var availableSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 0.2)
        seat.materials.first!.diffuse.contents = #imageLiteral(resourceName: "greenChenille")
        return seat
    }()
    lazy var occupiedSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 0.2)
        seat.materials.first!.diffuse.contents = #imageLiteral(resourceName: "redchenille")
        return seat
    }()
    
    lazy var availableRest : SCNGeometry = {
        let rest = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length/3, chamferRadius: 2)
        rest.materials.first!.diffuse.contents = #imageLiteral(resourceName: "greenChenille")
        return rest
    }()
    lazy var occupiedRest : SCNGeometry = {
        let rest = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length/3, chamferRadius: 2)
        rest.materials.first!.diffuse.contents = #imageLiteral(resourceName: "redchenille")
        return rest
    }()

}
