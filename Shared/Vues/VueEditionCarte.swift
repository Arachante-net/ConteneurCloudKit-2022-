//Arachante
// michel  le 26/12/2021
// pour le projet  PositionUtilisateur
// Swift  5.0  sur macOS  12.1
//
//  2021 27 Décembre
//

import MapKit
import SwiftUI
import CoreData

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
///
struct VueEditionCarte: View {
    
//    @ObservedObject var item: Item
    
    @StateObject private var Ξ : ViewModel //    viewModel = ViewModel()

//    @Binding  var sectionGéographique : MKCoordinateRegion
//    @Binding  var lesLieux : [Lieu]
//    @Binding  var lieuEnCoursEdition : Lieu?
    
//    var sectionGéographique : MKCoordinateRegion
//    var lesLieux : [Lieu]
//    var lieuEnCoursEdition : Lieu?

    init(_ unItem: Item,
         sectionGéographique : MKCoordinateRegion,
         lesLieux : [Lieu],
         lieuEnCoursEdition : Lieu?
        ) {
        _Ξ = StateObject(wrappedValue: ViewModel(
            unItem,
            sectionGéographique: sectionGéographique,
            lesLieux: lesLieux, // la position
            lieuEnCoursEdition: lieuEnCoursEdition
            ))
//        self.sectionGéographique = sectionGéographique
//        self.lesLieux = lesLieux
//        self.lieuEnCoursEdition = lieuEnCoursEdition
        print("Init VueEditionCarte avec longitudes :", Ξ.item.longitude,  Ξ.sectionGéographique.center.longitude  )
        }
    
    
    var body: some View {
//            NavigationView {
        Text("= \(Ξ.lesLieux.last?.latitude ?? 0) - \(Ξ.lesLieux.last?.longitude ?? 0)       Section \(Ξ.sectionGéographique.center.latitude) - \(Ξ.sectionGéographique.center.longitude)").font(.caption)
            ZStack {
                let _ = print("🌐 édition carte avec", Ξ.lesLieux.count, "marqueurs, sur la région centrée en", Ξ.sectionGéographique.center.latitude , Ξ.sectionGéographique.center.longitude)
                let _ = print("🌐 dernier", Ξ.lesLieux.last ?? "/")

                Map(coordinateRegion: $Ξ.sectionGéographique, annotationItems: $Ξ.lesLieux) { location in
                    
                    MapAnnotation(coordinate: location.wrappedValue.coordonnées) {
                        
                        VStack {
                            Text(location.wrappedValue.libellé)
                                .fixedSize()
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())

                        }
                        .onTapGesture {
                            Ξ.lieuEnCoursEdition = location.wrappedValue   //////////
                        }
                    }

                }
    //            .ignoresSafeArea()
               
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // création d'un Lieu positionné au centre de la région géographique affichée
                            let nouveauLieu = Lieu(
                                id: UUID(),
                                libellé: "Nouveau Lieu",
                                description: "Ceci est un lieu qu'il est bien",
                                latitude:  Ξ.sectionGéographique.center.latitude,
                                longitude: Ξ.sectionGéographique.center.longitude)
                            
                            Ξ.lesLieux.append(nouveauLieu)
                            
                            Ξ.item.longitude = nouveauLieu.longitude
                            Ξ.item.latitude  = nouveauLieu.latitude
                            
                            let _ = print("🌐 Nouveau lieu :", nouveauLieu.longitude, nouveauLieu.latitude)
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
                    }
                }
            }
        
        // item : Un lien avec une optionelle source de vérité pour cette feuille.
        // Si item n'est pas nil, le système transmet le contenu d'item à la fermeture du modificateur.
        //
        // Affichage de ce contenu dans une feuille affichee à l'utilisateur.
        // Si item change, le système remplace la feuile par une nouvelle (en utilisant le même processus).
        //
        // isPresented : valeur booléenne qui détermine s'il faut présenter la feuille
        // fournie par le contenu de la fermeture (closure)
            .sheet(item: $Ξ.lieuEnCoursEdition) { place in
                VueEditionLieu(place) { unLieu in
//                    print("🚩 édition de ", unLieu.libellé,  unLieu.description)
                    if let index = Ξ.lesLieux.firstIndex(of: place) {
                        Ξ.lesLieux[index] = unLieu
//                        print("🚩 modif de ", index, lesLieux[index].libellé,  lesLieux[index].latitude, lesLieux[index].longitude )
                        }
                    }
                
                }
            
            }
    
    }



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
