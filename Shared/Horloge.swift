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

let formatDate: DateFormatter = {
    let formateur = DateFormatter()
        formateur.dateStyle = .long
        formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")
 return formateur
}()

let formatHorodatage: DateFormatter = {
    let formateur = DateFormatter()
        formateur.dateStyle = .short
        formateur.timeStyle = .medium
        formateur.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
//          formatter.timeZone = TimeZone(     "UTC")
    return formateur
}()
