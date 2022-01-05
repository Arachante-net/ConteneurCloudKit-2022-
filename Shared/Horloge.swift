//Arachante
// michel  le 24/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import Foundation

class Horloge: ObservableObject {
    @Published var temps = 0

    lazy var chronometre = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in self.temps += 1 }
    init() { chronometre.fire() }
    }
