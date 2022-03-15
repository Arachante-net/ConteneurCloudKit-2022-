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
    
   
    @Binding var item:Item
    
    // La région doit etre mise à jour par la VueDeatailItem
    // @Binding pour laRégion car son évolution doit être retournée à la Vue appelante (VueDetailItem)
    @Binding var laRegion: MKCoordinateRegion

    
    // Etats locaux
    @State private var suivi:MapUserTrackingMode = .follow
    @State private var monSuivi:Bool = false
    
    lazy var place:PositionIdentifiable = PositionIdentifiable(lat: item.latitude, long: item.longitude)

   
    
//    func xPlace() -> IdentifiablePlace {
//        var moiMutable = self
//        return moiMutable.place
//        }
    

    
  var body: some View {
      let _ = Logger.interfaceUtilisateur.info("🌐 Appel de VueCarte sur une région centrée en \(laRegion.center.latitude) \(laRegion.center.longitude)")
      let _ = Logger.interfaceUtilisateur.info("🌐 suivi : \(suivi.hashValue) \(item.coloris)")
      
//      var coul = item.coloris

      VStack(alignment: .leading) {

          EtiquetteCoordonnees(prefix: "centre carte ",
                               latitude: laRegion.center.latitude,
                               longitude: laRegion.center.longitude,
                               font: .caption)
              .padding(.leading)
              .foregroundColor(item.coloris)


          ZStack {
    //          GeometryReader { geometrie in
    //              let _ = geometrie.size.width
                  Map(
                    coordinateRegion: $laRegion,

                    interactionModes: .zoom,
                    showsUserLocation:true,
                    userTrackingMode: monSuivi ? .constant(.follow) : .constant(.none),
                    
                    // Collection de données utilisée pour afficher les annotations.
                    //TODO: à creuser, ici on passe un argument bidon
                    // cf. VueCarteEditionItem pour une (meilleure) façon de faire
                    annotationItems: [PositionIdentifiable(lat: 0, long: 0)]) { place in
                        // Contenu de chacunes des annotationItems
                        //let _ = place.location
                          MapPin(
                            coordinate: laRegion.center,
                            //FIXME: BUG ? Ici on ne recupere pas la couleur en direct
                            // Alors que plus haut dans la description : OUI
                            tint: couleur(item) )
                        
//                        MapAnnotation(coordinate: laRegion.center) {
//                            Circle()
//                                .stroke(.black, lineWidth: 1)
//                                .background( couleur(item) )
//                                .frame(width: 30, height: 30)
//                                .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
//                                .clipShape(Circle())
//                            }
                        
                          }

                  
              HStack {
                  VStack {
                      HStack {
                          Button(action: zoomPlus ) { Icones.augmenter.imageSystéme }
                          Button(action: zoomMoins) { Icones.diminuer.imageSystéme  }
                          }
                          .background(.black.opacity(0.5))
                          .foregroundColor(.yellow) //white)
                          .font(.title)
                          .clipShape(Capsule())
                          .padding(.leading, 5)
                          .padding(.top, 3)

                      Spacer()
                    }
                  Spacer()
                  VStack {
                      Button {
                      // Retourner survoler la positition de l'Item
                         laRegion.centrerSur(item) }
                       
                        label: { Icones.arrière.imageSystéme }
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
                 

              .onAppear()    { Logger.interfaceUtilisateur.info("onAppear VueCarteItem")}
              .onDisappear() { }
              }
            }
      }
    
    
    func zoomMoins()  {
        let pas =  0.5
        let max = 90.0
        let nouvelleValeur = laRegion.span.latitudeDelta + pas
        laRegion.span.latitudeDelta =
            nouvelleValeur < max ?  nouvelleValeur : max
        }
    
    func zoomPlus() {
        let pas = 0.5
        let min = 0.0
        let nouvelleValeur = laRegion.span.latitudeDelta - pas
        laRegion.span.latitudeDelta =
            nouvelleValeur > min ?  nouvelleValeur : min
        }

    
    
  }
   
     
//MARK: -

func couleur(_ item:Item ) -> Color {
//  BUG ?     necessaire pour forcer la convertion de couleur
    item.coloris
    }

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





