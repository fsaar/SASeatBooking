
import Foundation
import UIKit
import SceneKit


enum SASeatFactoryType {
    case occupied
    case available
    case space
}

enum SASeatFactoryLabel : String {
    case seat
    case rest
    case badge
    case body
}

class SASeatFactory {
    lazy var occupiedSeatNode : SCNNode? = {
        let seat = self.seat(with : #imageLiteral(resourceName: "redchenille"))
        return seat
    }()
    lazy var availableSeatNode : SCNNode? = {
        let seat =  self.seat(with : #imageLiteral(resourceName: "greenChenille"))
        return seat
    }()
    
 

    func seatNode(of type: SASeatFactoryType,with label: String) -> SCNNode? {
        guard let node = node(with: type) else {
            return nil
        }
        updateBadge(of: node,with:label)
        return node
    }

}

/// MARK: Helper

extension SASeatFactory {
    var body : SCNNode?  {
        let url = Bundle.main.url(forResource: "Seat", withExtension: "scn")
        guard let seatURL = url,let scene = try? SCNScene(url: seatURL, options: nil) else {
            return nil
        }
        let bodyNode = scene.rootNode.childNode(withName: "body", recursively: true)
        return bodyNode
    }
    
    func node(with type : SASeatFactoryType) -> SCNNode? {
        switch type {
        case .available:
            return availableSeatNode?.clone()
        case .occupied:
            return occupiedSeatNode?.clone()
        case .space:
            return nil
        }
    }
    
    func updateBadge(of node: SCNNode,with label: String) {
        guard let oldBadge = node.childNode(withName: SASeatFactoryLabel.badge.rawValue, recursively: true),
            let sources = oldBadge.geometry?.sources, let elements = oldBadge.geometry?.elements else {
            return
        }
        oldBadge.geometry = SCNGeometry(sources: sources, elements:elements)
        oldBadge.geometry?.firstMaterial?.diffuse.contents = self.image(with: label)
    }
    
    func seat(with materialImage : UIImage) -> SCNNode? {
        let url = Bundle.main.url(forResource: "Seat", withExtension: "scn")
        guard let seatURL = url,let scene = try? SCNScene(url: seatURL, options: nil) else {
            return nil
        }
        let chairNode = scene.rootNode.childNode(withName: "chair", recursively: true)
        let seatNode = chairNode?.childNode(withName: SASeatFactoryLabel.seat.rawValue, recursively: true)
        let restNode = chairNode?.childNode(withName: SASeatFactoryLabel.rest.rawValue, recursively: true)
        seatNode?.geometry?.materials.first?.diffuse.contents = materialImage
        restNode?.geometry?.materials.first?.diffuse.contents = materialImage
        return chairNode
    }
    
    func image(with title: String) -> UIImage {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 100, height: 50))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        let image =  #imageLiteral(resourceName: "redCarpet")
        return renderer.image { context in
            
            image.draw(in: bounds)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36), NSAttributedString.Key.paragraphStyle: paragraphStyle,NSAttributedString.Key.foregroundColor: UIColor(red: 200, green: 200, blue: 100, alpha: 1.0)]
            title.draw(with: bounds, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
