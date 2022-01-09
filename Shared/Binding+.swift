//Arachante
// michel  le 09/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import Foundation
import SwiftUI

extension Binding {
    func onChange(_ handler : @escaping (Value) -> Void) -> Binding<Value> {
        Binding (
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
                }
        )
    }
    
}


// Slider(value: $rating.onChange(sliderChanged))
// func sliderChanged(_ value: Double) {...}
