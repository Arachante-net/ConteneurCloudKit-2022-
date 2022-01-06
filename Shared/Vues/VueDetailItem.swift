//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import MapKit



struct VueDetailItem: View {
    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation

    @EnvironmentObject private var persistance: ControleurPersistance
    @ObservedObject var item: Item

//    @State var titre:     String = ""
//    @State var valeurLocale:    Int    = 0
//    @State var ordre:     Int    = 0
//    @State var latitude:  Double = 0
//    @State var longitude: Double = 0
//    @State var couleur  = Color.secondary
//    @State var instant  = Date()
    
    @State var itemMémoire = Item.Memoire(titre: "", valeur: 0,  longitude:0, latitude:0)
    
    

    //  @State ??? non car Property wrapper ne peut être appliqué a une propriété calculée
    var régionCarte: MKCoordinateRegion {
      //
      print("🟦 Région carto", item.latitude, item.longitude )
      let coordonnées = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
      // Dimension de la section à afficher en °
      let section = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
      return MKCoordinateRegion(center: coordonnées, span: section)
      }
    
//    @State var régionCarte_ = MKCoordinateRegion(
//        center:  CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
//        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//        )
    
    
//    var régionCarto: MKCoordinateRegion {
//      //
//      print("🟦 map Région", item.latitude, item.longitude )
//      let coordonnées = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
//      // Dimension de la section à afficher en °
//        let section = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//      return MKCoordinateRegion(center: coordonnées, span: section)
//      }

    
    
    
    @State private var selectedPlace: Lieu?

//    @FocusState var isInputActive: Bool

    let formatDate: DateFormatter = {
       let formateur = DateFormatter()
          formateur.dateStyle = .long
          formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")

      return formateur
    }()

    
//    var régionCarto: MKCoordinateRegion {
//      //
//      print("🟦 map Région", item.latitude, item.longitude )
//      let coordonnées = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
//      // Dimension de la section à afficher en °
//        let section = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//      return MKCoordinateRegion(center: coordonnées, span: section)
//    }
    
    
    
    
    
    
    var annotationCartographique: AnnotationGeographique {
      return AnnotationGeographique(
        libellé: "ici",
        coordonnées: régionCarte.center, ////////////////
        couleur: UIColor(item.coloris)
      )
    }
    
    var lieuCartographique: Lieu {
      return Lieu(
        id: UUID(),  // on peut avoir à le modifier
        libellé: "ICI",
        description: "...",
        latitude: régionCarte.center.latitude,
        longitude: régionCarte.center.longitude
      )
    }
    
    
    
    
    var lieux = [Lieu]()

    @State var feuilleAffectationGroupesPresentée = false
    @State var feuilleModificationItemPresentée = false


    var body: some View {
        
        VStack(alignment: .leading , spacing: 2) {
            VStack { // (alignment: .leading , spacing: 2)

                Text("Identifiant :").foregroundColor(.secondary)
                + Text(" \(item.id?.uuidString ?? "sans ID")")
                Text("Crée le ").foregroundColor(.secondary)
                + Text(" \( formatDate.string(from: item.horodatage )) ")
                + Text(" à")
                    .foregroundColor(.secondary)
                + Text(" \(item.horodatage, style: .time)")
                + Text(", par ")
                    .foregroundColor(.secondary)
                + Text(" \(item.createur ?? "inconnu")")
                + Text(".")
                    .foregroundColor(.secondary)

                HStack {
                    Text ("En mode :")
                        .foregroundColor(.secondary)
                    + Text(" \(item.mode.rawValue).  ")
                    Text("Couleur : ")
                        .foregroundColor(.secondary)
                    Circle()
                        .fill(item.coloris)
                        .clipShape(Circle())
                        .overlay( Circle()
                            .strokeBorder(.primary, lineWidth: 0.5)
                            )
                        .frame(width: 20, height: 20)
                    }
                Text("Valeur :").foregroundColor(.secondary)
                + Text("\(item.valeur)")
               // + Text( item.valeur == valeurLocale ? "🆗" : "〰️")


                }
                .padding(.horizontal)
            
            VStack(alignment: .leading , spacing: 2) {
                Etiquette("Principal", valeur: item.principal?.nom ?? "")

                Text("Membre de")
                    .foregroundColor(.secondary)
                + Text(" \(item.lesGroupes.count) ")
                + Text(" groupes")
                    .foregroundColor(.secondary)
                
                    ForEach(Array(item.lesGroupes)) { groupe in Text("° \(groupe.nom ?? "..") ").padding(.horizontal) }
                
                }
                .padding(.horizontal)
            
//            let _ = print ("🚩 comp",
//                        annotationCartographique.coordonnées.longitude,
//                        annotationCartographique.coordonnées.latitude,
//
//                       lieuCartographique.longitude,
//                       lieuCartographique.latitude
//                    )
            
            let régionCarte_ = MKCoordinateRegion(
                center:  CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
            
            VueCarte(
                laRegion: régionCarte_,     //////////////:régionCarte, ///////////:
                annotations: [lieuCartographique]
                )

             
        }
        .isHidden(item.isDeleted || item.isFault ? true : false)
        .opacity(item.valide ? 1.0 : 0.1)
        
        .sheet(isPresented: $feuilleModificationItemPresentée) {
            
            VueModifItem(item) { valeur in
//                print("CLOSURE" , valeur, "... ACTION FORMULAIRE MODIFICATION ITEM")
                feuilleModificationItemPresentée = false
                }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        
        
        
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Spacer()

                Button(action: { feuilleModificationItemPresentée.toggle() }) {
//                  Label("Modifier", systemImage: "square.and.pencil").labelStyle(.titleAndIcon)
                    VStack {
                        Image(systemName: "quare.and.pencil")
                        Text("Modifier").font(.caption)
                        }
                  }.buttonStyle(.borderedProminent)

                Spacer()

                }
            }

        
        
        
        
        
        .onAppear(perform: {
            //MARK: - EXPERIMENTATION -
            // charger un Item CoreData en mémoire
//            (titre, valeur, _) = item.charger()
//            let itemMem = item.charger()
//            itemMémoire = item.mémoriser()
//            print("ITEM MEMOIRE", itemMémoire)
            
//            titre     = item.titre ?? "..."
//            valeurLocale    = Int(item.valeur)
            
//            ordre     = Int(item.ordre )
//            latitude  = item.latitude
//            longitude = item.longitude
//            instant   = item.horodatage //timestamp!
//            couleur   = item.coloris
            })
        
    }



    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            item.rallier(contexte:contexte, communauté: groupes )
            }
        persistance.sauverContexte("Groupe")
        }
    
}

