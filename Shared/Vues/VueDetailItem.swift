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
    
    @StateObject private var Ξ = ViewModel()
//    @StateObject private var Ξ : ViewModel //(Item.bidon())
    
    @State var item : Item
    @State var région : MKCoordinateRegion
    

    

    let formatDate: DateFormatter = {
        let formateur = DateFormatter()
            formateur.dateStyle = .long
            formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")
     return formateur
    }()
    
    
    
    

    
    
    var body: some View {
        VStack {
//        Text("VueTestItem").font(.largeTitle)
//        Text(" \(item.leTitre) : ")
//        + Text("\(item.latitude) \(item.longitude) ")
//        Text("Survol de : ")
//        + Text("\(région.center.latitude) \(région.center.longitude).")
//        Divider()
        description
                .isHidden( (item.isDeleted || item.isFault) ? true : false  )
                .opacity(item.valide ? 1.0 : 0.1)
            
                .sheet(isPresented: $Ξ.feuilleModificationItemPresentée) {
                
                    VueModifItem( item: item, région: $région ) { valeur in
    //                print("CLOSURE" , valeur, "... ACTION FORMULAIRE MODIFICATION ITEM")
                    Ξ.feuilleModificationItemPresentée = false
                    }
                }


        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing)
            { barreMenu }
            }

        
        
        .onAppear(perform: {})
        
        }
        }
    
    
    
    
    
    
    //MARK: - Sous Vues -
    
    var description: some View {
        VStack(alignment: .leading , spacing: 2) {
            let _ = print("🌐 Appel de VueCarte avec longitudes :", item.longitude )
            VStack(alignment: .leading , spacing: 2) { // (alignment: .leading , spacing: 2)

                Etiquette("Identifiant", valeur: item.id?.uuidString ?? "❌")
                    .onHover { over in
                        print("〽️")
//                        .overlay(Text("〽️"))
                    }
                
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
//                + Text( item.valeur == valeurLocale ? "🆗" : "〰️")


                }
                .padding(.horizontal)
            
            VStack(alignment: .leading , spacing: 2) {
                Etiquette("Principal", valeur: item.principal?.nom ?? "❌")

                Text("Membre de")
                    .foregroundColor(.secondary)
                + Text(" \(item.lesGroupes.count ) ")
                + Text(" groupes")
                    .foregroundColor(.secondary)
                
                ForEach( Array(item.lesGroupes) )
                    { groupe in Text("° \(groupe.nom ?? "..") ").padding(.horizontal) }
                
                }
                .padding(.horizontal)
            

            Spacer()

//            let _ = print("🌐 Appel de VueCarte avec longitudes :", Ξ.item.longitude, lieuDeEvenement.longitude )
            VueCarte(
                item : $item ,
                laRegion: $région
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
    
    
}

