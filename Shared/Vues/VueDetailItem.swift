//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import MapKit


/// Vue statique qui affiche les propriétées de l'Item passé en argument
struct VueDetailItem: View {
    
    
    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation

    @EnvironmentObject private var persistance: ControleurPersistance
    
    @StateObject private var Ξ = ViewModel()
    
    // l'appel depuis ListeItem impose que le @State item soit publics (pas private)
    // 'VueDetailItem' initializer is inaccessible due to 'private' protection level
    /// Argument, Item en cours d'édition propriété de VueDetailItem
    @State var item : Item


    
    //TODO: A mettre dans un module utilitaires
    let formatDate: DateFormatter = {
        let formateur = DateFormatter()
            formateur.dateStyle = .long
            formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")
     return formateur
    }()
    
    
    
    

    
    
    var body: some View {
        VStack {
            Group {
                descriptionPropriétés
                Divider()
                descriptionCollaboration
                }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)

            Spacer()

            // pas de Binding la position de l'Item n'est pas modifiée par la Vue
            VueCarteItem(
                item : item ,
                laRegion: item.région
                )
            
                .isHidden( (item.isDeleted || item.isFault) ? true : false  )
                .opacity(item.valide ? 1.0 : 0.1)
            
                .sheet(isPresented: $Ξ.feuilleModificationItemPresentée) {
                    VueModifItem( item: $item) { infoEnRetour in
                        Ξ.feuilleModificationItemPresentée = false
                        }
                    .border( .red, width: 0.3)

                    }


        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing)
            { barreMenu }
            }

        
        
        .onAppear(perform: { let _ = item.verifierCohérence(depuis: #file) })
        
        }
        }
    
    
    
    
    
    
    //MARK: - Sous Vues -
    
    var descriptionPropriétés: some View {
        
        VStack(alignment: .leading) {

            Etiquette("Identifiant", valeur: item.id?.uuidString ?? "❌")

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
        }
    
    
    var descriptionCollaboration: some View {
        
        VStack(alignment: .leading) {
            Etiquette("Principal", valeur: item.principal?.nom ?? "❌")

            Text("Membre de")
                .foregroundColor(.secondary)
            + Text(" \(item.lesGroupes.count ) ")
            + Text(" groupes")
                .foregroundColor(.secondary)

            ForEach( Array(item.lesGroupes) )
                { groupe in Text("° \(groupe.nom ?? "..") ")  } .padding(.leading)

            }
        }
    
    
    
          
    
    // l'avantage d'une proprieté comme ici, sur une vue décrite dans un autre fichier
    // c'est le partage d'information qui est direct
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

