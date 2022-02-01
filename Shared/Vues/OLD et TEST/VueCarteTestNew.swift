//Arachante
// michel  le 17/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit


//struct IdentifiablePlace: Identifiable {
//    let id: UUID
//    let location: CLLocationCoordinate2D
//    init(id: UUID = UUID(), lat: Double, long: Double) {
//        self.id = id
//        self.location = CLLocationCoordinate2D(
//            latitude: lat,
//            longitude: long)
//    }
//}





/// Affiche la carte d'une région géographiquerelative et une série de marquages (annotations) associés
///
///VueCarte(
///laRegion: régionCarto,
///annotations_: [lieuCartographique]
///)
///
struct VueCarteTestNew: View {
    

  @Binding var item:Item
//  @Binding var laRegion: MKCoordinateRegion

//  let annotations: [Lieu]
//  @State var annotations: [Lieu]
    @State private var latitudeMem:  Double = 0
    @State private var longitudeMem: Double = 0
    @State private var actuelle = false
    
     lazy var place:IdentifiablePlace = IdentifiablePlace(lat: item.latitude, long: item.longitude)
   
//    @State var place = IdentifiablePlace(lat: item.latitude, long: item.longitude)

//    init(_ unItem: Item, région:MKCoordinateRegion ) {
//       item = unItem
//       laRegion = région
//       _place = State(wrappedValue: IdentifiablePlace(
//            lat: item.latitude,
//            long: item.longitude))
//        }
    
    func xPlace() -> IdentifiablePlace {
        var moiMutable = self
        return moiMutable.place
        }
    
    func yPlace() -> IdentifiablePlace {
        IdentifiablePlace(lat: item.latitude, long: item.longitude)
        }
    
  var body: some View {
      let _ = print("🌐 Appel de VueCarte sur une région centrée en ",
                    item.région.center.latitude,
                    item.région.center.longitude)
      
//      let place = IdentifiablePlace(lat: item.latitude, long: item.longitude)
//      lazy var place = IdentifiablePlace(lat: item.latitude, long: item.longitude)
      
      VStack(alignment: .leading) {
//      Text("VueCarteTest").font(.largeTitle)
//          HStack {
//
//              Button("Enregistrer Position") {
//                  print("🌐 Enregistrer", laRegion.center.latitude, laRegion.center.longitude )
//                  longitudeMem = laRegion.center.longitude
//                  latitudeMem  = laRegion.center.latitude
//                  print("🌐 Enregistrement de ", latitudeMem, longitudeMem)
//
//              }
//
//              Button("Survoler Paris") {
//                  print("🌐 Paris")
//                  laRegion.center.latitude  = Lieu.Paris.latitude
//                  laRegion.center.longitude = Lieu.Paris.longitude
//              }
//
//
//
//              Button("Revenir") {
//                  print("🌐 Revenir à ", latitudeMem,  longitudeMem )
////                  item.longitude = longitudeMem
////                  item.latitude  = latitudeMem
//                  laRegion.center.latitude  = latitudeMem
//                  laRegion.center.longitude = longitudeMem
//
//              }
//          }
          
      EtiquetteCoordonnees(prefix: "centre carte ", latitude: item.région.center.latitude,         longitude: item.région.center.longitude,         font: .caption).padding(.leading)
      EtiquetteCoordonnees(prefix: "pointeur ",     latitude: item.latitude,                    longitude: item.longitude,                    font: .body).padding(.leading)
      ZStack {
          Map( coordinateRegion: $item.région, annotationItems: [yPlace()])   { place in
              MapPin(
                coordinate: yPlace().location,
                tint: item.région.center == place.location ? Color.red : Color.clear)
            }
//          Map( coordinateRegion: $item.région, annotationItems: [yPlace()])   { place in
//              MapPin(
//                coordinate: yPlace().location,
//                tint: item.région.center == place.location ? Color.red : Color.clear)
//            }
          
          Circle()
              .fill(.red)
              .opacity(item.région.center == yPlace().location ? 0.2 : 0.7)
              .frame(width: 30, height: 30).scaleEffect(item.région.center == yPlace().location ? 0.5 : 1)
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
