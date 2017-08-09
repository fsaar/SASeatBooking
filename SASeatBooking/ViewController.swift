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
        [.occupied,.available,.available],
        [.available,.available,.space],
        [.available,.occupied,.occupied]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
}

extension ViewController : SASeatBookingViewDatasource {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize {
        return (3,3)
    }
    
    func seatBookingView(_ view: SASeatBookingView,at position:  SASeatPosition) -> SASeatBookingType {
        return seatMap[position.row][position.column]
    }
    
    func seatBookingView(_ view: SASeatBookingView,node: SCNNode,for position: SASeatPosition) {
    }

}

extension ViewController : SASeatBookingViewDelegate {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition) {
        
    }
}

