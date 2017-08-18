//
//  ViewController.swift
//  SASeatBooking
//
//  Created by Frank Saar on 08/08/2017.
//  Copyright © 2017 SAMedialabs. All rights reserved.
//

import UIKit
import SceneKit

class SAViewController: UIViewController {
    var defaultSeatSize = (width: CGFloat(1),height:CGFloat(1),length:CGFloat(1))
    lazy var seatFactory = SASeatFactory()
    
    @IBOutlet var sceneView : SASeatBookingView! = nil {
        didSet {
            self.sceneView.seatDataSource = self
            self.sceneView.seatDelegate = self
        }
    }
}

extension SAViewController : SASeatBookingViewDatasource {
    func numberOfRowsAndColumnsInSeatBookingView(_ view : SASeatBookingView) -> SASeatBookingSize {
        return (seatMap.count,seatMap.first?.count ?? 0)
    }
    
    func seatBookingView(_ view: SASeatBookingView,nodeAt position:  SASeatPosition) -> SCNNode? {
        let row = seatMap[position.row]
        let type = row[position.column]
        let columnOffset = row[0..<position.column].filter ({ $0 == .space }).count
        let labelPosition = (column: position.column - columnOffset,row: position.row)
        let seatLabel = self.label(for: labelPosition)
        guard type != .space, let seat = self.seatFactory.seatNode(of: type,with: seatLabel) else {
            return nil
        }
        return seat
    }
}

extension SAViewController : SASeatBookingViewDelegate {
    func seatBookingView(_ view: SASeatBookingView,canSelectSeatAt position: SASeatPosition)  -> Bool{
        let type = seatMap[position.row][position.column]
        return type == .available
    }
    
    func seatBookingView(_ view: SASeatBookingView,didSelect seat : SCNNode,  at position: SASeatPosition) {
        animated(show: true, bodyOf: seat)
    }
    func seatBookingView(_ view: SASeatBookingView,didDeselect seat : SCNNode, at position: SASeatPosition) {
        animated(show: false, bodyOf: seat)
    }
}

/// MARK : Help
extension SAViewController {
    func addBodyIfNeedBe(to node: SCNNode) {
        if case .none =  node.childNode(withName: SASeatFactoryLabel.body.rawValue, recursively: true) {
            if let body = self.seatFactory.body {
                body.opacity = 0
                node.addChildNode(body)
            }
        }
    }
    
    func animated(show : Bool,bodyOf node: SCNNode) {
        addBodyIfNeedBe(to: node)
        if let body =  node.childNode(withName: SASeatFactoryLabel.body.rawValue, recursively: true) {
            let action = show ? SCNAction.fadeOpacity(to: 1, duration: 1) : SCNAction.fadeOpacity(to: 0, duration: 1)
            body.runAction(action)
        }
    }
    
    func label(for position : SASeatPosition) -> String {
        guard let letter = UnicodeScalar(65+position.column) else {
            return ""
        }
        let label = "\(position.row+1)\(letter)"
        return label
    }
    
}


