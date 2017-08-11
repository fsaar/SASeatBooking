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
    lazy var seatFactory = SASeatFactory(width: self.defaultSeatSize.width,height:self.defaultSeatSize.height,length:self.defaultSeatSize.length)

    @IBOutlet var sceneView : SASeatBookingView! = nil {
        didSet {
            self.sceneView.seatDataSource = self
            self.sceneView.seatDelegate = self
        }
    }
    
    let seatMap : [[SASeatFactoryType]]  = [
        [.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],
        [.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,],[.available,.available,.occupied,.space,.available,.available,.available,.available,.available,.space,.available,.available,.available,]]
    
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
        let node = self.seatFactory.seat(of:type)
        
        guard type != .space else {
            return node
        }
        let title = self.title(for: position)
        let titleNode = self.titleNode(with: title)
        node.addChildNode(titleNode)
        return node
    }
    
    func title(for position : SASeatPosition) -> String {
        guard let letter = UnicodeScalar(65+position.column) else {
            return ""
        }
        let title = "\(position.row)\(letter)"
        return title
    }
    
    func titleNode(with title: String) -> SCNNode {
        let title = SCNText(string: title, extrusionDepth: 0.1)
        title.firstMaterial?.diffuse.contents = UIColor.white
        title.font = UIFont.systemFont(ofSize: 2)
        title.flatness = 0.1
        
        let titleNode = SCNNode()
        titleNode.geometry = title
        titleNode.scale = SCNVector3Make(0.2,0.2,0.2)
        titleNode.geometry?.firstMaterial?.shininess = 0
        titleNode.rotation = SCNVector4Make(1, 0, 0, -Float(Double.pi / 4))
        let middleText = (titleNode.boundingBox.max.x - titleNode.boundingBox.min.x) / 10
        titleNode.position = SCNVector3Make(-middleText, 0.5, 0.3)
        return titleNode
    }

}

extension ViewController : SASeatBookingViewDelegate {
    func seatBookingView(_ view: SASeatBookingView,didTapSeatAt position: SASeatPosition) {
        
    }
}

