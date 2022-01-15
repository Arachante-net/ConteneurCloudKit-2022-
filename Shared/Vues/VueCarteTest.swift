//Arachante
// michel  le 17/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit


struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}





/// Affiche la carte d'une région géographiquerelative et une série de marquages (annotations) associés
///
///VueCarte(
///laRegion: régionCarto,
///annotations_: [lieuCartographique]
///)
///
struct VueCarteTest: View {
    

  @State var item:Item
  @Binding var laRegion: MKCoordinateRegion

//  let annotations: [Lieu]
//  @State var annotations: [Lieu]
    @State var latitudeMem:  Double = 0
    @State var longitudeMem: Double = 0
    
//    let place = IdentifiablePlace(lat: item.latitude, long: item.longitude)

  var body: some View {
      let _ = print("🌐 Appel de VueCarte sur une région centrée en ",
                  laRegion.center.latitude,
                  laRegion.center.longitude)
      
      let place = IdentifiablePlace(lat: item.latitude, long: item.longitude)

      
      VStack {
      Text("VueCarteTest").font(.largeTitle)
          HStack {
              
              Button("Enregistrer Position") {
                  print("🌐 Enregistrer", laRegion.center.latitude, laRegion.center.longitude )
                  longitudeMem = laRegion.center.longitude
                  latitudeMem  = laRegion.center.latitude
                  print("🌐 Enregistrement de ", latitudeMem, longitudeMem)

              }
              
              Button("Survoler Paris") {
                  print("🌐 Paris")
                  laRegion.center.latitude  = Lieu.Paris.latitude
                  laRegion.center.longitude = Lieu.Paris.longitude
              }
              
           
             
              Button("Revenir") {
                  print("🌐 Revenir à ", latitudeMem,  longitudeMem )
//                  item.longitude = longitudeMem
//                  item.latitude  = latitudeMem
                  laRegion.center.latitude  = latitudeMem
                  laRegion.center.longitude = longitudeMem

              }
          }
      EtiquetteCoordonnees(prefix: "centre ", latitude: laRegion.center.latitude,         longitude: laRegion.center.longitude,         font: .body)
      EtiquetteCoordonnees(prefix: "item ! ", latitude: item.latitude,                    longitude: item.longitude,                    font: .title)
      ZStack {
          Map( coordinateRegion: $laRegion, annotationItems: [place])   { place in
              MapPin(
                coordinate: place.location,
                tint: Color.purple)
            }
          
          Circle()
              .fill(.red)
              .opacity(0.5)
              .frame(width: 30, height: 30)
          }
          .onAppear()    {print("🌐 Affichage carte Item")}
          .onDisappear() {print("🔺 Disparition carte Item")}
      }//.background(Color(.clear))
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
