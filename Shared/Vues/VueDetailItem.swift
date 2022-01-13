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
    
//    @StateObject private var Ξ = ViewModel()
    @StateObject private var Ξ:ViewModel // = ViewModel(item)

    //:FIXME: Item incorporable au ViewModel ??
//    @ObservedObject var item: Item
    

    //  @State ??? non car Property wrapper ne peut être appliqué a une propriété calculée
    var régionCarte: MKCoordinateRegion {
      MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude:  Ξ.item.latitude ,
            longitude: Ξ.item.longitude),
        span: MKCoordinateSpan(
            latitudeDelta:  0.5,
            longitudeDelta: 0.5)
        )
      }
    

    let formatDate: DateFormatter = {
        let formateur = DateFormatter()
            formateur.dateStyle = .long
            formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")
     return formateur
    }()
    
    
    
    
    
    var annotationCartographique: AnnotationGeographique {
      AnnotationGeographique(
        libellé: "ici",
        coordonnées: régionCarte.center,
        couleur: UIColor(Ξ.item.coloris)
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

    init(_ unItem: Item) { _Ξ = StateObject(wrappedValue: ViewModel(unItem)) }
    
    var body: some View {
        let _ = assert(Ξ.item.principal != nil, "❌ Item isolé")
        description
            .isHidden( (Ξ.item.isDeleted || Ξ.item.isFault) ? true : false  )
            .opacity(Ξ.item.valide ? 1.0 : 0.1)
        
            .sheet(isPresented: $Ξ.feuilleModificationItemPresentée) {
            
                VueModifItem( Ξ.item ) { valeur in
//                print("CLOSURE" , valeur, "... ACTION FORMULAIRE MODIFICATION ITEM")
                Ξ.feuilleModificationItemPresentée = false
                }
////////////////////:                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing)
            { barreMenu }
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
    
    
    
    
    
    
    //MARK: - Sous Vues -
    
    var description: some View {
        VStack(alignment: .leading , spacing: 2) {
            VStack(alignment: .leading , spacing: 2) { // (alignment: .leading , spacing: 2)

                Text("Identifiant :").foregroundColor(.secondary)
                + Text(" \(Ξ.item.id?.uuidString ?? "❌")")
                Etiquette("Identifiant", valeur: Ξ.item.id?.uuidString ?? "❌")
                Text("Crée le ").foregroundColor(.secondary)
                + Text(" \( formatDate.string(from: Ξ.item.horodatage )) ")
                + Text(" à")
                    .foregroundColor(.secondary)
                + Text(" \(Ξ.item.horodatage, style: .time)")
                + Text(", par ")
                    .foregroundColor(.secondary)
                + Text(" \(Ξ.item.createur ?? "inconnu")")
                + Text(".")
                    .foregroundColor(.secondary)

                HStack {
                    Text ("En mode :")
                        .foregroundColor(.secondary)
                    + Text(" \(Ξ.item.mode.rawValue).  ")
                    Text("Couleur : ")
                        .foregroundColor(.secondary)
                    Circle()
                        .fill(Ξ.item.coloris)
                        .clipShape(Circle())
                        .overlay( Circle()
                            .strokeBorder(.primary, lineWidth: 0.5)
                            )
                        .frame(width: 20, height: 20)
                    }

                Text("Valeur :").foregroundColor(.secondary)
                + Text("\(Ξ.item.valeur)")
//                + Text( item.valeur == valeurLocale ? "🆗" : "〰️")


                }
                .padding(.horizontal)
            
            VStack(alignment: .leading , spacing: 2) {
                Etiquette("Principal", valeur: Ξ.item.principal?.nom ?? "❌")

                Text("Membre de")
                    .foregroundColor(.secondary)
                + Text(" \(Ξ.item.lesGroupes.count ) ")
                + Text(" groupes")
                    .foregroundColor(.secondary)
                
                ForEach( Array(Ξ.item.lesGroupes) )
                    { groupe in Text("° \(groupe.nom ?? "..") ").padding(.horizontal) }
                
                }
                .padding(.horizontal)
            

            Spacer()

            
            VueCarte(
                laRegion: MKCoordinateRegion(
                    center:  CLLocationCoordinate2D(
                        latitude:  Ξ.latitude ,  /////// $
                        longitude: Ξ.longitude ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.5,
                        longitudeDelta: 0.5)
                    ),
                annotations: [lieuCartographique]
                )
            
            VueCarte(
                laRegion: régionCarte ,
                annotations: [lieuCartographique]
                )

             
        }
        }

    
    var barreMenu: some View {
        HStack {
            Spacer()

            Button(action: { Ξ.feuilleModificationItemPresentée.toggle() }) {
                VStack {
                    Image(systemName: "square.and.pencil")
                    Text("Modifier").font(.caption)
                    }
              }.buttonStyle(.borderedProminent)

            Button(role: .destructive, action: {  }) {
                VStack {
                    Image(systemName: "trash")
                    Text("Supprimer").font(.caption)
                    }
              }.buttonStyle(.borderedProminent)

            Spacer()
            }
        }

    
    
    //MARK: - quelques fonctions -
    
    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            Ξ.item.rallier(contexte:contexte, communauté: groupes )
            }
        persistance.sauverContexte("Groupe")
        }
    
}

