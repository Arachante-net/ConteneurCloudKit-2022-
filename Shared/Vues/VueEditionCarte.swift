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
    
    @ObservedObject var item: Item

    @Binding  var sectionGéographique : MKCoordinateRegion
    @Binding  var lesLieux : [Lieu]
    @Binding  var lieuEnCoursEdition : Lieu?

    var body: some View {
//            NavigationView {
        Text("= \(lesLieux.last?.latitude ?? 0) - \(lesLieux.last?.longitude ?? 0)       \(sectionGéographique.center.latitude) - \(sectionGéographique.center.longitude)").font(.caption)
            ZStack {
                let _ = print("🚩🚩 édition carte avec", lesLieux.count, "marqueurs")
                let _ = print("🚩🚩 dernier", lesLieux.last ?? "/")

                Map(coordinateRegion: $sectionGéographique, annotationItems: $lesLieux) { location in
                    
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
                            lieuEnCoursEdition = location.wrappedValue   //////////
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
                            // positionnement du lieu de l'item
                            let nouveauLieu = Lieu(
                                id: UUID(),
                                libellé: "Nouveau Lieu",
                                description: "Ceci est un lieu qu'il est bien",
                                latitude:  sectionGéographique.center.latitude,
                                longitude: sectionGéographique.center.longitude)
                            
                            lesLieux.append(nouveauLieu)
                            
                            item.longitude = nouveauLieu.longitude
                            item.latitude  = nouveauLieu.latitude
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
            .sheet(item: $lieuEnCoursEdition) { place in
                VueEditionLieu(place) { unLieu in
//                    print("🚩 édition de ", unLieu.libellé,  unLieu.description)
                    if let index = lesLieux.firstIndex(of: place) {
                        lesLieux[index] = unLieu
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
