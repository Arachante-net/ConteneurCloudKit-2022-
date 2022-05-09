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
    
    @State private var partage: CKShare?
    @State private var showShareSheet = false
    @State private var showEditSheet  = false
    
    
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
                        
            
            Section {
              if let _share = partage {
                ForEach(_share.participants, id: \.self) { participant in
                  VStack(alignment: .leading) {
                    Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                      .font(.headline)
                    Text("Accréditation: \(string(for: participant.acceptanceStatus))")
                      .font(.subheadline)
                    Text("Rôle: \(string(for: participant.role))")
                      .font(.subheadline)
                    Text("Permissions: \(string(for: participant.permission))")
                      .font(.subheadline)
                  }
                  .padding(.bottom, 8)
                }
              }
            } header: { Text("Participants") }
            // Section Header
            
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

        
        .sheet(isPresented: $showShareSheet) { //}, content: {
          if let __share = partage {
              VuePartageCloudKit(
                // CloudSharingView(share: share, container: stack.ckContainer, destination: destination)
                partage: __share,
                conteneurCK: persistance.ckContainer, //  . stack.ckContainer,
                item: item)
              .border( .red, width: 0.3)
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
            Logger.interfaceUtilisateur.info("make onAppear VueDetailItem")
            self.partage = persistance.getShare(item)
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
            
              Button {  //stack
                let _ = print("〽️ make bouton")
                let _ = print("〽️ make partage", persistance.estPartagé(objet: item).voyant)
//                 !persistance.isShared(object: item)
                if !persistance.estPartagé(objet: item) {
                  let _ = print("❗️make n'est pas partagé")
                  Task { await createShare(item) }
                  }
                showShareSheet = true
              } label: {
                Image(systemName: "square.and.arrow.up")
              }
            
            
            
            

            Spacer()
            }
        }
    
    func apparaitre() {}
}

// MARK: Aides au Partage : participant permission, methodes and proprietés ...
extension VueDetailItem {
  private func createShare(_ item: Item) async {
    print("❗️make un partage")
    do {
        // Associer item à un (nouveau ou existant) partage
        let (_, _share, _) = try await persistance.conteneur.share([item], to: nil)//    stack.persistentContainer.share([item], to: nil)
      _share[CKShare.SystemFieldKey.title] = item.titre
      self.partage = _share
      }
    catch { print("❗️Impossible de creer un partage") }
    }

  private func string(for permission: CKShare.ParticipantPermission) -> String {
    switch permission {
        case .unknown:
          return "Inconnu" //"Unknown"
        case .none:
          return "Sans" //"None"
        case .readOnly:
          return "Lecture seule" //"Read-Only"
        case .readWrite:
          return "Lecture/Écriture" //"Read-Write"
        @unknown default:
          fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.Permission")
        }
    }

  private func string(for role: CKShare.ParticipantRole) -> String {
    switch role {
        case .owner:
          return "Propriétaire" //"Owner"
        case .privateUser:
          return "Utilisateur Privé" // participant ? //"Private User"
        case .publicUser:
          return "Utilisateur Publique" // "Public User"
        case .unknown:
          return "Inconnu" //Unknown"
        @unknown default:
          fatalError("Une nouvelle valeur inconnue pour  CKShare.Participant.Role")
        }
    }

  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
    switch acceptanceStatus {
        case .accepted:
          return "Accepté" //"Accepted"
        case .removed:
          return "Révoqué" //Enlevé, Révoqué "Removed"
        case .pending:
          return "Invité" //"Invited"
        case .unknown:
          return "Inconnu" //"Unknown"
        @unknown default:
          fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.AcceptanceStatus")
        }
    }

  private var canEdit: Bool { persistance.canEdit(object: item) }
    
}
