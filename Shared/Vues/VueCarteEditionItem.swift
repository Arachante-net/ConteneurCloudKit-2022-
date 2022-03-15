//Arachante
// michel  le 17/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit
import os.log




//TODO: A mettre à jour
/// Affiche pour édition une région géographique, permet de définir un lieu sur une carte géographique
///
///                 VueCarteEditionItem(item: $item, laRegion: $laRegion)
///
///     - Paramêtres :
///         - item en cours d'édition
///         - laRegion géographique rectangulaire centrée autour des coordonnées du lieu
struct VueCarteEditionItem: View {
    
    
    /// L'Iten cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var item: Item
    
    
    /// Région géographique ou se situe l'Item
    @State var laRégion: MKCoordinateRegion
    
 //   Cannot convert value of type 'ObservedObject<Item>.Wrapper' to expected argument type 'Binding<Item>'
    
    
    
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
    
    
    init(_ unItem: Item) { //}, achevée: @escaping  RetourInfoItemAchevée) {
        
        _item = ObservedObject<Item>(wrappedValue : unItem)
        
//         self.laModificationDeItemEstRéalisée    = achevée
        
        _laRégion          = State(wrappedValue : unItem.région)

        }
    
    
  var body: some View {

      VStack(alignment: .leading) {
          
      EtiquetteCoordonnees(prefix: "centre carte ", latitude: laRégion.center.latitude,         longitude: laRégion.center.longitude,         font: .caption).padding(.leading)
//    EtiquetteCoordonnees(prefix: "pointeur ",     latitude: item.latitude,                    longitude: item.longitude,                    font: .body).padding(.leading)
      ZStack {
          Map(
            coordinateRegion: $laRégion,
            showsUserLocation:true,
            userTrackingMode: monSuivi ? .constant(.follow) : .constant(.none) ,
            annotationItems: [ PositionIdentifiable(lat: item.latitude, long: item.longitude) /* yPlace()  */   ])   { place in
              MapPin(
                coordinate: place.location, //yPlace().location,
                tint: laRégion.center == place.location ? Color.red : Color.clear)
            }
          
          Circle()
              .fill(.red)
              .opacity(laRégion.center == yPlace().location ? 0.2 : 0.7)
              .frame(width: 30, height: 30).scaleEffect(laRégion.center == yPlace().location ? 0.5 : 1)
          
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
                      item.centrerSur(laRégion)
                    } label: { Image(systemName: "plus") }
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
          .onAppear()    {Logger.interfaceUtilisateur.info("onAppear VueCarteEditionItem")}
          .onDisappear() { monSuivi = false }
        }
      }
    }
   
     
