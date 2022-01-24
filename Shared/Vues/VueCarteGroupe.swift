//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit

/// Afficher  sur une carte un groupe d'item representés par des annotations
struct VueCarteGroupe: View {
  @State var région: MKCoordinateRegion
  let annotations: [AnnotationGeographique]


  var body: some View {
 
      Map(coordinateRegion: $région, annotationItems: annotations) { annotation in
        MapAnnotation(coordinate: annotation.coordonnées) {
            Text(annotation.libellé)
                .foregroundColor(.black)
                .background(Color(red: 1, green: 1, blue: 0) )
            RoundedRectangle(cornerRadius: 7.0)
                .stroke(.red, lineWidth: 4.0)
                .background(Color(annotation.couleur)) //      Color(red: 1, green: 1, blue: 0).opacity(0.5) )
                .frame(width: 30, height: 30)
                .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
            }
    }
  }
}


