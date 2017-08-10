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

    @IBOutlet var sceneView : SASeatBookingView! = nil {
        didSet {
            self.sceneView.seatDataSource = self
            self.sceneView.seatDelegate = self
        }
    }
    
    let seatMap : [[SASeatBookingType]]  = [
        [.occupied,.available,.available,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.available,.space,.occupied,.available,.available],
        [.available,.occupied,.occupied,.occupied,.available,.available]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
}

extension ViewController : SASeatBookingViewDatasource {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize {
        return (self.seatMap.count,self.seatMap.first?.count ?? 0)
    }
    
    func seatBookingView(_ view: SASeatBookingView,nodeAt position:  SASeatPosition) -> SCNNode {
        let type = seatMap[position.row][position.column]
        let node = view.dequeueNode(of: type)
        return node
    }

}

extension ViewController : SASeatBookingViewDelegate {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition) {
        
    }
}

