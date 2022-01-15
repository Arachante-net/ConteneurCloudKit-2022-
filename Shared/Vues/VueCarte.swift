//Arachante
// michel  le 17/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit




/// Affiche la carte d'une région géographiquerelative et une série de marquages (annotations) associés
///
///VueCarte(
///laRegion: régionCarto,
///annotations_: [lieuCartographique]
///)
///
struct VueCarte: View {
    
  @State var item:Item
  @State var laRegion: MKCoordinateRegion 
//  let annotations: [Lieu]
  @State var annotations: [Lieu]


    
  var body: some View {
      let _ = print("🌐 Appel de VueCarte sur une région centrée en ",
                  laRegion.center.latitude,
                  laRegion.center.longitude)
      
      EtiquetteCoordonnees(prefix: "c   ", latitude: laRegion.center.latitude,         longitude: laRegion.center.longitude,         font: .body)
      EtiquetteCoordonnees(prefix: "a   ", latitude: annotations.first?.latitude ?? 0, longitude: annotations.first?.longitude ?? 0, font: .body)
      EtiquetteCoordonnees(prefix: "I ! ", latitude: item.latitude,                    longitude: item.longitude,                    font: .title)
      ZStack {
          //=================================
          Map(
            coordinateRegion: $laRegion,
//            coordinateRegion: MKCoordinateRegion(
//                    center: CLLocationCoordinate2D(
//                        latitude:  item.latitude,
//                        longitude: item.longitude),
//                    span: MKCoordinateSpan(
//                        latitudeDelta: 0.5,
//                        longitudeDelta: 0.5)
//                    ),
            
            annotationItems: annotations) { annotation in
              MapAnnotation(coordinate: annotation.coordonnées) {
                  RoundedRectangle(cornerRadius: 7.0)
                      .stroke(.red, lineWidth: 4.0)
                      .background(Color(red: 1, green: 1, blue: 0).opacity(0.5) )
                      .frame(width: 30, height: 30)
                  }
          }//.edgesIgnoringSafeArea(.all)
//          .onChange(of: $laRegion) {n in print("🌐")}
          
          Circle()
              .background(Color(.blue))
              .opacity(0.01)
              .frame(width:30, height:30)
              .clipShape(Circle())
          
              
        }
          .onAppear()    {print("🌐 Affichage carte Item")}
          .onDisappear() {print("🔺 Disparition carte Item")}
        }
    }
   
     




//struct VueCartoItem_Previews: PreviewProvider {
//  static let coordinates = CLLocationCoordinate2D(latitude: -32, longitude: 115)
//  static let span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
//  static var previews: some View {
//    VueCartoItem(
//      mapRegion: MKCoordinateRegion(
//        center: coordinates,
//        span: span),
//      annotations: [AnnotationItem(coordonnées: coordinates,  couleur: UIColor.orange)] //, color: UIColor.orange)]
//    )
//  }
//}
