//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import CloudKit
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
    
    @State private var partageEnCours: CKShare? // initialisé on Appear
    @State private var feuillePartageAffichée = false
    @State private var showEditSheet  = false
    
    let coordinateurPartage : DéléguéDuControleurDePartageChargéDeLaCoordination

    
    init (item:Item) { //}, laRégion:MKCoordinateRegion) {
//        _item_    = State(wrappedValue: item)
        _item     = StateObject<Item>(wrappedValue: item)
        
        _laRégion = State(wrappedValue: item.région) //  laRégion:
        _message  = State(wrappedValue: item.leMessage)
        Logger.interfaceUtilisateur.debug("Init de VueDetailItem \(item.leTitre) \(item.longitude) \(item.latitude) (avant déplacement)")
        longitudeInitiale = item.longitude
        latitudeInitiale  = item.latitude
        
        coordinateurPartage = DéléguéDuControleurDePartageChargéDeLaCoordination(item: item)
        coordinateurPartage.tester()

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
                        

            if let _share = partageEnCours {

            Section {
//              if let _share = partage {
                List {
                ForEach(_share.participants, id: \.self) { participant in
                  VStack(alignment: .leading) {
                    Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                      .font(.headline)
                      Text("Accréditation: \(persistance.libellé(de: participant.acceptanceStatus))")
                      .font(.subheadline)
                      Text("Rôle: \(persistance.libellé(de: participant.role))")
                      .font(.subheadline)
                      Text("Permissions: \(persistance.libellé(de: participant.permission))")
                      .font(.subheadline)
                  }
                  .padding(.bottom, 8)
                } // for each
                }
              } // section
            header: { Text("Participants") }
            } // si partage
        } // VStack
        
        .sheet(isPresented: $Ξ.feuilleModificationItemPresentée) {
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
                }
            } // NavigationView
        
            .border( .red, width: 0.3)
            .ignoresSafeArea()

            } //Sheet modif

        
        .sheet(isPresented: $feuillePartageAffichée) { //}, content: {
          let _ = print("〽️〽️ - Appel de VuePartageCloudKit depuis VueDetailItem")
          if let __share = partageEnCours {
//              let _ = print("〽️〽️ Création du coordinateur de partage de", item.leTitre)
//              let coord = CoordinateurDePartageCloudKit(item: item)
              let _ = print("〽️〽️ Controleur de vue et son coordianateur", coordinateurPartage, "sont utilisés pour", item.leTitre)
              
              //MARK: Controleur de vue de partage   et    son délégué à la coordination
              VuePartageCloudKit(
                // CloudSharingView(share: share, container: stack.ckContainer, destination: destination)
                partage: __share,
                conteneurCK: persistance.conteneurCK, //  . stack.ckContainer,
//                itemAPartager: item,
                coordinateur: coordinateurPartage) //CoordinateurDePartageCloudKit(item: item))
              .border( .red, width: 0.5)
              .background(Color(.blue))
              .ignoresSafeArea()
          }
        }  // Sheet partage // )

        
        .toolbar {
            // Barre d'outils pour VuDetailItem
            ToolbarItemGroup(placement: .navigationBarTrailing)
            { barreMenu }
            }
        
        .onAppear() { //perform: {
//            let image = UIImage(named: "Soucoupe")
//            let donnéesImage = image?.pngData()
//            print("❗️❗️❗️❗️make image largeur :", image?.size.width ?? 0, "x hauteur :", image?.size.height ?? 0,  ", données:" , donnéesImage?.count, "octets")//   isEmpty ?.debugDescription)
            // 4032 × 3024     // 14 747 097
            apparaitre()
            Logger.interfaceUtilisateur.info("onAppear VueDetailItem \(item.leMessage) \(item.valeur) ")
            let _ = item.verifierCohérence(depuis: #file)
            //MARK: S'il existe, obtenir le partage à rejoindre.
            //self. /////////
            partageEnCours = persistance.obtenirUnPartageCK(item)
        } //)
        
       // .onAppear() {}
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
            Etiquette("Partage", valeur: partageEnCours != nil)
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
            
              Button {
                let _ = print("〽️ Bouton partage", persistance.estPartagéCK(objet: item).voyant)
//                 !persistance.isShared(object: item)
                if !persistance.estPartagéCK(objet: item) {
                    let _ = print("〽️ \(item.leTitre) n'est pas déjà partagé, donc création du partage.")
                    //MARK: Création du partage
//                    Task { await creerUnPartageCK(item) } //////// 9/6/22
                    Task { await self.partageEnCours = persistance.associerUnPartageCK(item)  }

                    }
                feuillePartageAffichée = true
              } label: {
                Image(systemName: "square.and.arrow.up")
              }
            
            
            
            

            Spacer()
            }
        }
    
    func apparaitre() {}
}






// MARK: Aides au Partage : participant permission, methodes and proprietés ...
// ne pas supprimer tout de suite
//extension VueDetailItem {
//
//// 9/6/22 remplacé par  self.partage = persistance.creerUnPartageCK(item)
////  private func creerUnPartageCK(_ item: Item) async {
////    do {
////        // Associer un item à un (nouveau ou existant) partage
////        print("〽️ 🔆 Création d'un partage pour", item.leTitre)
////        let (_, _partageTmp, _) = try await persistance.conteneur.share([item], to: nil)//    stack.persistentContainer.share([item], to: nil)
////        _partageTmp[CKShare.SystemFieldKey.title] = "Participer à l'événement\n\"\(item.titre ?? "...")\"\n(Création de la collaboration)"
////           let image = UIImage(named: "CreationPartage")
////           let donnéesImage = image?.pngData()
////        _partageTmp[CKShare.SystemFieldKey.thumbnailImageData] = donnéesImage
////        if coordinateurPartage.DonnéesMiniature() == donnéesImage {
////            print("〽️〽️〽️〽️〽️〽️ Mêmes données ! ")
////            }
////        // Type UTI qui decrit le contenu partagé
////        _partageTmp[CKShare.SystemFieldKey.shareType] = "com.arachante.nimbus.item"
////
////      self.partage = _partageTmp
////      }
////    catch { print("❗️Impossible de creer un partage") }
////    }
////
////  private func string(for permission: CKShare.ParticipantPermission) -> String {
////    switch permission {
////        case .unknown:
////          return "Inconnu" //"Unknown"
////        case .none:
////          return "Sans" //"None"
////        case .readOnly:
////          return "Lecture seule" //"Read-Only"
////        case .readWrite:
////          return "Lecture/Écriture" //"Read-Write"
////        @unknown default:
////          fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.Permission")
////        }
////    }
////
////  private func string(for role: CKShare.ParticipantRole) -> String {
////    switch role {
////        case .owner:
////          return "Propriétaire" //"Owner"
////        case .privateUser:
////          return "Utilisateur Privé" // participant ? //"Private User"
////        case .publicUser:
////          return "Utilisateur Publique" // "Public User"
////        case .unknown:
////          return "Inconnu" //Unknown"
////        @unknown default:
////          fatalError("Une nouvelle valeur inconnue pour  CKShare.Participant.Role")
////        }
////    }
////
////  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
////    switch acceptanceStatus {
////        case .accepted:
////          return "Accepté" //"Accepted"
////        case .removed:
////          return "Révoqué" //Enlevé, Révoqué "Removed"
////        case .pending:
////          return "Invité" //"Invited"
////        case .unknown:
////          return "Inconnu" //"Unknown"
////        @unknown default:
////          fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.AcceptanceStatus")
////        }
////    }
////
////  private var canEdit: Bool { persistance.jePeuxEditer(objet: item) }
//
//}
