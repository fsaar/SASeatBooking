//
//  ViewController.swift
//  SASeatBooking
//
//  Created by Frank Saar on 08/08/2017.
//  Copyright © 2017 SAMedialabs. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    var defaultSeatSize = (width: CGFloat(1),height:CGFloat(1),length:CGFloat(1))
    lazy var seatFactory = SASeatFactory()

    @IBOutlet var sceneView : SASeatBookingView! = nil {
        didSet {
            self.sceneView.seatDataSource = self
            self.sceneView.seatDelegate = self
        }
    }
    
    let seatMap : [[SASeatFactoryType]]  = [
        [.available,.available,.occupied],
        [.available,.available,.occupied],
        [.available,.available,.occupied],
        [.available,.available,.occupied],
        [.available,.available,.occupied]]
}

extension ViewController : SASeatBookingViewDatasource {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize {
        return (self.seatMap.count,self.seatMap.first?.count ?? 0)
    }
    
    func seatBookingView(_ view: SASeatBookingView,nodeAt position:  SASeatPosition) -> SCNNode? {
        let type = seatMap[position.row][position.column]
        let seatLabel = self.label(for: position)
        guard type != .space, let seat = self.seatFactory.seatNode(of: type,with: seatLabel) else {
            return nil
        }
        return seat
    }
}

extension ViewController : SASeatBookingViewDelegate {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition) {
        
    }
}

/// MARK : Help
extension ViewController {
    func label(for position : SASeatPosition) -> String {
        guard let letter = UnicodeScalar(65+position.column) else {
            return ""
        }
        let label = "\(position.row+1)\(letter)"
        return label
    }

}

