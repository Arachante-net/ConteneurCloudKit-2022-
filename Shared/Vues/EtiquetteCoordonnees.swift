//Arachante
// michel  le 26/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//


import SwiftUI

struct EtiquetteCoordonnees: View {
  static let symbole = UnitAngle.degrees.symbol

  let prefix : String
  let latitude: Double
  let longitude: Double
  let font: Font

  private var chaineLatitude: String {
    return String(format: "%.2f", abs(latitude)) +
      (latitude < 0 ? "\(EtiquetteCoordonnees.symbole) S" : "\(EtiquetteCoordonnees.symbole) N")
    }

  private var chaineLongitude: String {
    return String(format: "%.2f", abs(longitude)) +
      (longitude < 0 ? "\(EtiquetteCoordonnees.symbole) W" : "\(EtiquetteCoordonnees.symbole) E")
    }

  var body: some View {
      
      HStack {
          Text("Coordonnées \(prefix) : ")
              .foregroundColor(.secondary)
          Text(chaineLatitude).padding(.horizontal)
          Text(" , ")
              .foregroundColor(.secondary)
          Text(chaineLongitude).padding(.horizontal)
          }
      .clipShape(Capsule() )
      .overlay( Capsule()
              .strokeBorder(.primary, lineWidth: 0.1)
              )
  }
    
}


