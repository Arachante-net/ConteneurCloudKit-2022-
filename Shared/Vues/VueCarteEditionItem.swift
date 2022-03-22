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
///                 VueCarteEditionItem(item: $item, laRegion: $uneRegion)
///
///     - Paramêtres :
///         - entrée : item en cours d'édition
///         - liaison : laRegion géographique rectangulaire centrée autour des coordonnées du lieu
struct VueCarteEditionItem: View {
    
    
    /// L'Iten cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var item: Item
    
    
    /// Région géographique ou se situe l'Item
//    @State var laRégion: MKCoordinateRegion
    // 22 mars State => Binding
    
    /// Région géographique où se situe l'Item, initialisée par la vue mère, modifiée par et liée à Map
    @Binding var laRégion: MKCoordinateRegion

    
 //   Cannot convert value of type 'ObservedObject<Item>.Wrapper' to expected argument type 'Binding<Item>'
    
    
    
  @State private var suivi:MapUserTrackingMode = .follow
  @State private var survolerMaPosition:Bool = false
    
//    lazy var place:PositionIdentifiable = PositionIdentifiable(lat: item.latitude, long: item.longitude)
//    lazy var lieu:Lieu = Lieu( latitude: item.latitude, longitude: item.longitude)
    
//    func Place_() -> PositionIdentifiable {
//        var moiMutable = self
//        return moiMutable.place
//        }
    
    func yPlace() -> PositionIdentifiable {
        PositionIdentifiable(lat: item.latitude, long: item.longitude)
        }
    
    
    init(_ unItem: Item, uneRégion:Binding<MKCoordinateRegion>) { //}, achevée: @escaping  RetourInfoItemAchevée) {
        
        _item = ObservedObject<Item>(wrappedValue : unItem)
        
//         self.laModificationDeItemEstRéalisée    = achevée
        
         // 22 mars State => Binding
//      _laRégion      = State(wrappedValue : unItem.région)
        _laRégion      = uneRégion //Binding<MKCoordinateRegion>(wrappedValue : unItem.région)

        }
    
    
  var body: some View {

      VStack(alignment: .leading) {
          
          HStack {
              EtiquetteCoordonnees(prefix: "centre carte ", latitude: laRégion.center.latitude,         longitude: laRégion.center.longitude,         font: .caption).padding(.leading)
              Spacer()
              Menu("Lieux") {
                  ForEach(Lieu.exemples) { unLieu in
                      Button { localiser(unLieu) } label: { Text(unLieu.libellé) }
                    }
                  }
              }
      ZStack {
          Map(
            coordinateRegion: $laRégion,
            showsUserLocation:true,
            userTrackingMode: survolerMaPosition ? .constant(.follow) : .constant(.none) ,
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
                      survolerMaPosition = true

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
                      Logger.interfaceUtilisateur.info("🌐 Mettre à jour les coordonnées de l'item avec \(laRégion.center.longitude) \(laRégion.center.longitude)")
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
          .onDisappear() { survolerMaPosition = false }
        }
      }
    
    // Placer la région autour du lieu
    func localiser(_ l:Lieu) {
        laRégion.center.latitude  = l.latitude
        laRégion.center.longitude = l.longitude
        item.centrerSur(laRégion)
        }
    
    }
   
     
