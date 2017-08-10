
import Foundation
import UIKit
import SceneKit


class SASeatFactory {
    let seatSize : (width : CGFloat,height: CGFloat, length: CGFloat)
    init(width: CGFloat,height:CGFloat,length:CGFloat) {
        seatSize = (width,height,length)
    }
    lazy var availableSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 2)
        return seat
    }()
    lazy var occupiedSeat : SCNGeometry = {
        let seat = SCNBox(width: self.seatSize.width, height: self.seatSize.height, length: self.seatSize.length, chamferRadius: 2)
        return seat
    }()
}
