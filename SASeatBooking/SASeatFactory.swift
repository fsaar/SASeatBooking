
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
}

class SASeatFactory {
    lazy var occupiedSeatNode : SCNNode? = {
        return self.seat(with : #imageLiteral(resourceName: "redchenille"))
    }()
    lazy var availableSeatNode : SCNNode? = {
        return self.seat(with : #imageLiteral(resourceName: "greenChenille"))
    }()

    func seatNode(of type: SASeatFactoryType,with title: String) -> SCNNode? {
        guard let node = node(with: type) else {
            return nil
        }
        updateBadge(of: node,with:title)
        return node
    }

}

/// MARK: Helper

extension SASeatFactory {
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
    
    func updateBadge(of node: SCNNode,with title: String) {
        let badge  = node.childNode(withName: SASeatFactoryLabel.badge.rawValue, recursively: true)
        let image = self.image(with: title)
        badge?.geometry?.firstMaterial?.diffuse.contents = image
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
        let bounds = CGRect(origin:.zero, size: CGSize(width: 100, height: 40))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        let image =  #imageLiteral(resourceName: "leather")
        return renderer.image { context in
            
            image.draw(in: bounds)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 36), NSAttributedStringKey.paragraphStyle: paragraphStyle,NSAttributedStringKey.foregroundColor: UIColor(red: 200, green: 200, blue: 100, alpha: 1.0)]
            title.draw(with: bounds, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
