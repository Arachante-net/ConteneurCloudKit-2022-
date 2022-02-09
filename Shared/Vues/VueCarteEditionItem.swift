//Arachante
// michel  le 17/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit




//TODO: A mettre à jour
/// Affiche pour édition une région géographique, permet de définir un lieu sur une carte géographique
///
///                 VueCarteEditionItem(item: $item, laRegion: $laRegion)
///
///     - Paramêtres :
///         - item en cours d'édition
///         - laRegion géographique rectangulaire centrée autour des coordonnées du lieu
struct VueCarteEditionItem: View {
    

  @Binding var item:Item
  @Binding var laRegion: MKCoordinateRegion

  @State private var suivi:MapUserTrackingMode = .follow
  @State private var monSuivi:Bool = false
    
    lazy var place:PositionIdentifiable = PositionIdentifiable(lat: item.latitude, long: item.longitude)
    lazy var lieu:Lieu = Lieu( latitude: item.latitude, longitude: item.longitude)
    
    func Place_() -> PositionIdentifiable {
        var moiMutable = self
        return moiMutable.place
        }
    
    func yPlace() -> PositionIdentifiable {
        PositionIdentifiable(lat: item.latitude, long: item.longitude)
        }
    
  var body: some View {

      VStack(alignment: .leading) {
          
      EtiquetteCoordonnees(prefix: "centre carte ", latitude: laRegion.center.latitude,         longitude: laRegion.center.longitude,         font: .caption).padding(.leading)
//    EtiquetteCoordonnees(prefix: "pointeur ",     latitude: item.latitude,                    longitude: item.longitude,                    font: .body).padding(.leading)
      ZStack {
          Map(
            coordinateRegion: $laRegion,
            showsUserLocation:true,
            userTrackingMode: monSuivi ? .constant(.follow) : .constant(.none) ,
            annotationItems: [ PositionIdentifiable(lat: item.latitude, long: item.longitude) /* yPlace()  */   ])   { place in
              MapPin(
                coordinate: place.location, //yPlace().location,
                tint: laRegion.center == place.location ? Color.red : Color.clear)
            }
          
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
                  Button {} label: { Image(systemName: "plus") }
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
          .onAppear()    {print("onAppear VueCarteEditionItem")}
          .onDisappear() { monSuivi = false }
        }
      }
    }
   
     
