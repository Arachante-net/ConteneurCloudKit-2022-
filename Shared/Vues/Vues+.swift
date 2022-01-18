//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import Foundation
import SwiftUI

extension View {
    
    /// Masquer ou afficher une vue en fonction d'un booléen
    ///
    /// Exemples :
    ///
    ///     Text("Bonjour")
    ///         .isHidden(true)
    ///
    ///     Text("Re Bonjour !")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden:  `false` pour garder la Vue visible. `true` pour cacher la Vue.
    ///   - remove: Booléen indiquant s'il faut ou non supprimer la vue.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden { if !remove { self.hidden() } }
        else { self }
        }
    
    
    
//        /// Overlays this view with a view that provides a toolTip with the given string.
        func toolTip(_ toolTip: String?) -> some View {
            self.overlay(Text(toolTip ?? ""))
        }
//    }
//
//    private struct TooltipView: NSViewRepresentable, ShapeStyle {
//        let toolTip: String?
//
//        init(_ toolTip: String?) {
//            self.toolTip = toolTip
//        }
//
//        func makeNSView(context: NSViewRepresentableContext) -> NSView {
//            let view = NSView()
//            view.toolTip = self.toolTip
//            return view
//        }
//
//        func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext) {
//        }
    
}
