//Arachante
// michel  le 09/03/2021
// pour le projet  Formes
// Swift  5.0  sur macOS  11.2
//
//  2021
//

import SwiftUI

extension CGRect {
    /// center of rect
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    /// if rect is not square take centered square to draw
    var centeredSquare: CGRect {
        let width = ceil(min(size.width, size.height))
        let height = width

        let newOrigin = CGPoint(x: origin.x + (size.width - width) / 2, y: origin.y + (size.height - height) / 2)
        let newSize = CGSize(width: width, height: height)
        return CGRect(origin: newOrigin, size: newSize)
    }
    
    func flatten() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        return (origin.x, origin.y, size.width, size.height)
    }
}


