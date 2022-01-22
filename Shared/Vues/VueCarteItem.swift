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
/// Les marqueurs devraient rester fixes
///
///VueCarte(
///laRegion: régionCarto,
///annotations_: [lieuCartographique]
///)
///
struct VueCarteItem: View {
    

//  @Binding var item:Item
//  @Binding var laRegion: MKCoordinateRegion
//    
    @State var item:Item
    @State var laRegion: MKCoordinateRegion

  @State var suivi:MapUserTrackingMode = .follow
  @State var monSuivi:Bool = false
    
    lazy var place:IdentifiablePlace = IdentifiablePlace(lat: item.latitude, long: item.longitude)
//    lazy var lieu:Lieu = Lieu( latitude: item.latitude, longitude: item.longitude)

//    init(_ unItem: Item, région:MKCoordinateRegion ) {
//       item = unItem
//       laRegion = région
//       _place = State(wrappedValue: IdentifiablePlace(
//            lat: item.latitude,
//            long: item.longitude))
//        }
    
//    func xPlace() -> IdentifiablePlace {
//        var moiMutable = self
//        return moiMutable.place
//        }
    
//    func yPlace() -> IdentifiablePlace {
//        IdentifiablePlace(lat: item.latitude, long: item.longitude)
//        }
    
  var body: some View {
      let _ = print("🌐 Appel de VueCarte sur une région centrée en ",
                  laRegion.center.latitude,
                  laRegion.center.longitude)
      let _ = print("🌐 suivi : ", suivi)

      VStack(alignment: .leading) {
          EtiquetteCoordonnees(prefix: "centre carte ", latitude: laRegion.center.latitude,         longitude: laRegion.center.longitude,         font: .caption).padding(.leading)
          EtiquetteCoordonnees(prefix: "pointeur ",     latitude: item.latitude,                    longitude: item.longitude,                    font: .body).padding(.leading)
          ZStack {
    //          GeometryReader { geometrie in
    //              let _ = geometrie.size.width
                  Map(
                    coordinateRegion: $laRegion,
                    showsUserLocation:true,
                    userTrackingMode: monSuivi ? .constant(.follow) : .constant(.none) , //$suivi, //.constant(.follow), //$suivi,
                    annotationItems: [IdentifiablePlace(lat: item.latitude, long: item.longitude)])
//                  annotationItems: [yPlace()])
                        { place in
                          MapPin(
//                          coordinate: yPlace().location,
                            coordinate: IdentifiablePlace(lat: item.latitude, long: item.longitude).location,
                            tint: laRegion.center == place.location ? Color.red : Color.clear)
                          }

                  
              HStack {
                  Spacer()
                  VStack {
                      Button
                      // Retourner survoler la positition de l'Item
                        {  laRegion.centrerSur(item) }
                        label: { Image(systemName: "arrow.counterclockwise.circle") }
                          .buttonStyle(.borderless)
                          .padding()
                          .background(.black.opacity(0.75))
                          .foregroundColor(.white)
                          .font(.title)
                          .clipShape(Circle())
                          .padding(.trailing)
                          .padding(.top)
                          .isHidden(laRegion.center == item.coordonnées)
                      Spacer()
                      }
                  }
                  Croix() .stroke(lineWidth:0.5).foregroundColor(.pink  ).opacity(0.2)
                  Viseur().stroke(lineWidth:5  ).foregroundColor(.yellow).opacity(0.8)

//                  Circle()
//                      .fill(.red)
//                     .opacity(laRegion.center == yPlace().location ? 0.2 : 0.7)
//                   .frame(width: 30, height: 30).scaleEffect(laRegion.center == yPlace().location ? 0.5 : 1)
                 

              .onAppear()    {print("🌐 Affichage carte Item")}
              .onDisappear() {print("🔺 Disparition carte Item")}
              }
              
      }
      }
    }
   
     
//MARK: -
struct Croix: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(   to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        path.move(   to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        return path  //  .stroke(Color.black, lineWidth: 2) as! Path

    }
}

struct Viseur: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(   to: CGPoint(x: rect.midX - 5, y: rect.maxY    ))
        path.addLine(to: CGPoint(x: rect.midX    , y: rect.maxY - 5))
        path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.maxY    ))

        path.move(   to: CGPoint(x: rect.midX - 5, y: rect.minY    ))
        path.addLine(to: CGPoint(x: rect.midX    , y: rect.minY + 5))
        path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.minY    ))

        path.move(   to: CGPoint(x: rect.minX    , y: rect.midY - 5 ))
        path.addLine(to: CGPoint(x: rect.minX + 5, y: rect.midY     ))
        path.addLine(to: CGPoint(x: rect.minX    , y: rect.midY + 5 ))
        
        path.move(   to: CGPoint(x: rect.maxX    , y: rect.midY - 5 ))
        path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.midY     ))
        path.addLine(to: CGPoint(x: rect.maxX    , y: rect.midY + 5 ))
        
        return path
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
