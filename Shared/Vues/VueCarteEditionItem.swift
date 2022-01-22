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




//TODO: A mettre à jour
/// Affiche pour édition une région géographique, permet de définir un lieu sur une carte géographique
///
///     VueEditionCarte(
///        item: item,
///        sectionGéographique: $mapRegion,
///        lesLieux: $locations_,
///        lieuEnCoursEdition: $selectedPlace )
///
///
///     - Paramêtres :
///         - item en cours d'édition
///         - sectionGeographique  Une région géographique rectangulaire centrée autour des coordonnées du lieu
///         - un tableau des lieux `(ici un seul élémént est utilisé (le dernier))`
///         - lieu sélectioné pour être édité
struct VueCarteEditionItem: View {
    

  @Binding var item:Item
  @Binding var laRegion: MKCoordinateRegion

  @State var suivi:MapUserTrackingMode = .follow
  @State var monSuivi:Bool = false
    
    lazy var place:IdentifiablePlace = IdentifiablePlace(lat: item.latitude, long: item.longitude)
    lazy var lieu:Lieu = Lieu( latitude: item.latitude, longitude: item.longitude)

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
      let _ = print("🌐 Appel de VueCarteEdition sur une région centrée en ",
                  laRegion.center.latitude,
                  laRegion.center.longitude)
      let _ = print("🌐 suivi : ", suivi)

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
          
      EtiquetteCoordonnees(prefix: "centre carte ", latitude: laRegion.center.latitude,         longitude: laRegion.center.longitude,         font: .caption).padding(.leading)
      EtiquetteCoordonnees(prefix: "pointeur ",     latitude: item.latitude,                    longitude: item.longitude,                    font: .body).padding(.leading)
      ZStack {
          Map(
            coordinateRegion: $laRegion,
            showsUserLocation:true,
            userTrackingMode: monSuivi ? .constant(.follow) : .constant(.none) , //$suivi, //.constant(.follow), //$suivi,
            annotationItems: [yPlace()])   { place in
              MapPin(
                coordinate: yPlace().location,
                tint: laRegion.center == place.location ? Color.red : Color.clear)
            }
//          Map( coordinateRegion: $item.région, annotationItems: [yPlace()])   { place in
//              MapPin(
//                coordinate: yPlace().location,
//                tint: item.région.center == place.location ? Color.red : Color.clear)
//            }
          
          Circle()
              .fill(.red)
              .opacity(laRegion.center == yPlace().location ? 0.2 : 0.7)
              .frame(width: 30, height: 30).scaleEffect(laRegion.center == yPlace().location ? 0.5 : 1)
          
          VStack {
              HStack {
                  Spacer()
                  Button {
                      // Survoler la position de l'utilisateur
                      monSuivi = true

                  } label: {
                      Image(systemName: "paperplane.fill")
                  }
                  .buttonStyle(.borderless)
                  .padding()
                  .background(.black.opacity(0.75))
                  .foregroundColor(.white)
                  .font(.title)
                  .clipShape(Circle())
                  .padding(.trailing)
                  .padding(.top)
              }
              Spacer()
          }
          VStack {
              Spacer()
              HStack {
                  Spacer()
                  Button {
                      // création d'un Lieu positionné au centre de la région géographique affichée
//                      let nouveauLieu = Lieu(
////                                id: UUID(),
////                                libellé: "Nouveau Lieu",
////                                description: "Ceci est un lieu qu'il est bien",
//                          latitude:  Ξ.sectionGéographique.center.latitude,
//                          longitude: Ξ.sectionGéographique.center.longitude)
//
//                      Ξ.lesLieux.append(nouveauLieu)
//
//                      Ξ.item.longitude = nouveauLieu.longitude
//                      Ξ.item.latitude  = nouveauLieu.latitude
//
//                      let _ = print("🌐 Nouveau lieu :", nouveauLieu.longitude, nouveauLieu.latitude)
//

                  } label: {
                      Image(systemName: "plus")
                  }
                  .buttonStyle(.borderless)
                  .padding()
                  .background(.black.opacity(0.75))
                  .foregroundColor(.white)
                  .font(.title)
                  .clipShape(Circle())
                  .padding(.trailing)
                  .padding(.bottom)
              }
          }
          
          
          
          
          
          }
          .onAppear()    {print("🌐 Affichage carte Item")}
          .onDisappear() {
              monSuivi = false
              laRegion = item.région
              print("🔺 Disparition carte Item")}
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
