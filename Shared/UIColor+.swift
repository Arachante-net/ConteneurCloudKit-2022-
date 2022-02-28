//Arachante
// michel  le 09/03/2021
// pour le projet  Formes
// Swift  5.0  sur macOS  11.2
//
//  2021
//

import SwiftUI

extension UIColor {
    var inverser: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
        }
    }


