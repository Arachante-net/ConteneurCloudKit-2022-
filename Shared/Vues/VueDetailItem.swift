//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import MapKit
import os.log


/// Vue statique qui affiche les propriétées de l'Item passé en argument
struct VueDetailItem: View {
    
    
    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation

    @EnvironmentObject private var persistance: ControleurPersistance
    
    @StateObject private var Ξ = ViewModel()
    
    // l'appel depuis ListeItem impose que les @State item et laRegion soient publiques (pas private)
    // 'VueDetailItem' initializer is inaccessible due to 'private' protection level ??
    
    // ♔ La Source de verité pour Item ♔
    //
    /// Argument, Item en cours d'édition propriété de VueDetailItem
    @StateObject private var item: Item
//    @State  private var item_ : Item


    /// Argument, Région géographique ou se situe l'Item
    @State  private var laRégion : MKCoordinateRegion
    //TODO: Pas utilisé ?
    @State var message: String
    
    let longitudeInitiale : Double
    let latitudeInitiale  : Double
    
    
    init (item:Item) { //}, laRégion:MKCoordinateRegion) {
//        _item_    = State(wrappedValue: item)
        _item     = StateObject<Item>(wrappedValue: item)
        
        _laRégion = State(wrappedValue: item.région) //  laRégion:
        _message  = State(wrappedValue: item.leMessage)
        Logger.interfaceUtilisateur.debug("Init de VueDetailItem \(item.leTitre) \(item.longitude) \(item.latitude) (avant déplacement)")
        longitudeInitiale = item.longitude
        latitudeInitiale  = item.latitude
    }
    

    
    
    var body: some View {
        VStack {
            Group {
                descriptionPropriétés
                Divider()
                descriptionCollaboration
                }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            //TODO: A supprimer ?
            .onChange(of: item) {msg in Logger.interfaceUtilisateur.info("change item Message \(msg.leMessage)")}

            Spacer()
//            Text("VueDetailItem item      \(item.latitude), \(item.longitude)")
//            Text("VueDetailItem $laRegion \(item.latitude), \(item.longitude)")

            
            // Besoin de retour d'informations de la part de VueCarteItem
            // donc Binding pour item et laRegion
            // RQ1 : la position de l'Item n'est pas modifiée par la Vue CarteItem
            // RQ2 : la région affichée peut être deplacée par l'utilisateur
            // 17 Mars
            VueCarteItem( item,  uneRegion: $laRégion )
            
                .isHidden( (item.isDeleted || item.isFault) ? true : false  )
                .opacity(item.valide ? 1.0 : 0.1)
            
                .sheet(isPresented: $Ξ.feuilleModificationItemPresentée) {
//                    Text("VueDetailItem $laRegion \(laRegion.center.longitude), \(laRegion.center.latitude)")
//                    VueModifItem( item: $item, laRegion: $laRégion) { infoEnRetour in
                    NavigationView {
                    VueModifItemSimple(item) { aSauver, itemEnRetour in
                        Logger.interfaceUtilisateur.info("🌐 retour de VueModifItemSimple(item) depuis VueDetailItem : \(aSauver ? "SAUVER" : "ABANDONNER") \(itemEnRetour.leTitre) déplacement de \(item.longitude) \(item.latitude) \(longitudeInitiale) \(latitudeInitiale) vers \(itemEnRetour.longitude) \(itemEnRetour.latitude)")
                        Ξ.feuilleModificationItemPresentée = false
                        if aSauver {
                            // Mettre à jour les coordonnées de l'item avec le centre de la région cartographique affichée
                            withAnimation(.easeInOut(duration: 20)) {
                                laRégion.centrerSur(itemEnRetour)
                                //itemEnRetour.centrerSur(laRégion)
                                }
                            persistance.sauverContexte(depuis: "Retour VueModifItemSimple") //#function)
                            }
                        else {
                            persistance.retourArriereContexte()
                            }
//}
                        }
//                    .toolbar {
//                        // Barre d'outils pour VueModifItemSimple ??
//                        ToolbarItemGroup(placement: .navigationBarTrailing)
//                        {  Button(action: { print("A ECRIRE")  }) {
//                            VStack {
//                                Icones.valider.imageSystéme
//                                Text("? Valider ?").font(.caption)
//                                }
//                          }.buttonStyle(.borderedProminent)  }
//                        }
                    } // NavigationView
                
                    
                    .border( .red, width: 0.3)
                    .ignoresSafeArea()

                    } //Sheet


        .toolbar {
            // Barre d'outils pour VuDetailItem
            ToolbarItemGroup(placement: .navigationBarTrailing)
            { barreMenu }
            }

        

        .onAppear(perform: {
            Logger.interfaceUtilisateur.info("onAppear VueDetailItem \(item.leMessage) \(item.valeur) ")
            let _ = item.verifierCohérence(depuis: #file) })
        
        } // VStack
        .onAppear() {
            Logger.interfaceUtilisateur.info("onAppear VueDetailItem")
            apparaitre()
            }
    } // Body
    
    
    
    
    
    
    //MARK: - Sous Vues -
    
    var descriptionPropriétés: some View {
        
        VStack(alignment: .leading) {

            Etiquette("Identifiant", valeur: item.id?.uuidString ?? "❌")
            Etiquette("Message", valeur: item.leMessage)

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
    
    
    
          
    
    // L'avantage d'une proprieté comme ici, sur une vue décrite dans un autre fichier
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
    
    func apparaitre() {}
}

