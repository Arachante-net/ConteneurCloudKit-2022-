//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit
import CoreData
import CloudKit
import os.log

  
/// Affiche les propriétés du Groupe passé en argument
struct VueDetailGroupe: View {
    
    @Environment(\.managedObjectContext) private var contexte

    @EnvironmentObject private var persistance       : ControleurPersistance
    @EnvironmentObject private var configUtilisateur : Utilisateur
//    @EnvironmentObject private var nuage             : Nuage
//    @EnvironmentObject private var partageur         : DeleguePartageCloudKit


    
    //MARK: - ♔ Source de veritée, c'est cette Vue qui est proprietaire et créatrive de `groupe`
    // Rq: avec @State l'etat n'est pas MàJ immediatement
    // https://stackoverflow.com/questions/60111947/swiftui-prevent-view-from-refreshing-when-presenting-a-sheet?rq=1
    /// Argument, Le groupe en cours d'édition, propriétée de  la Vue  VuedetailGroupe
    /// // 1er Février 1
    @StateObject private var groupe: Groupe //= Groupe()
    // le groupe est fourni par ListeGroupe, il est instancié plus bas, dans l'init()
    
    // litem Principal de ce groupe
    @StateObject private var thePrincipal: Item

    @StateObject private var viewModel = ViewModel()
    
    
//    @State var appError: ErrorType? = nil
//    @State var coherenceGroupe: Coherence? = nil //[ErrorType]? = nil
    
    @State private var coherenceGroupe: Coherence? = nil
    @State private var estCoherent:Bool? = nil

    @State private var régionEnglobante: MKCoordinateRegion
    @State private var lesAnnotations: [AnnotationGeographique]? = nil


    // Etats 'locaux' de la Vue
    @State private var collaboration = false
    @State private var nom           = ""

    @State private var feuilleModificationPresentée = false
//    @State var laCarteEstVisible = true
    
    /// Le groupe édité fait partie des favoris de l'utilisateur
    @State private var estFavoris = false
    
    
    @State private var voirDétailsCollaboration = false
    
    @State private var partageEnCours: CKShare? // initialisé on Appear
    @State private var feuillePartageAffichée = false
    @State private var showEditSheet  = false
    
    let coordinateurPartage : DéléguéDuControleurDePartageChargéDeLaCoordination? = nil
    @State var nouvelleRecrue: Item? = nil
    
    /// Passer l'argument groupe sans étiquette `ET` le déclarer private sans pour autant générer  l'erreur  "Vue initializer is inaccessible due to 'private' protection level" lors de la compilation
    init (_ leGroupe:Groupe) {
        print ("⚙️ Init de la vue detail du groupe", leGroupe.leNom)
        _groupe       = StateObject<Groupe>(wrappedValue: leGroupe)
        _thePrincipal = StateObject<Item>  (wrappedValue: leGroupe.lePrincipal)

        _régionEnglobante = State(wrappedValue: leGroupe.régionEnglobante)
//      _lesAnnotations   = State(wrappedValue: lesAnnotations ?? [])
        _lesAnnotations   = State(wrappedValue: leGroupe.lesAnnotations )
//        _nouvelleRecrue   = State(wrappedValue: nil )
//        coordinateurPartage = DéléguéDuControleurDePartageChargéDeLaCoordination(item: leGroupe.lePrincipal)//ERREUR:
//        coordinateurPartage?.tester()
        print ("⚙️ init OK")
        }
    
    

//    static func == (lhs: VueDetailGroupe, rhs: VueDetailGroupe) -> Bool {
//        // propriétés qui identifient que la vue est égale et ne doit pas être réactualisée
//        
//           // << return yes on view properties which identifies that the
//           // view is equal and should not be refreshed (ie. `body` is not rebuilt)
//        false
//       }
    
    
    var body: some View {
    //let _ = assert(groupe.principal != nil, "❌ Groupe isolé")
//    let _ = groupe.groupesAuxquelsJeParticipe
        let _ = print("🔘⚙️❌ INIT VUE DETAIL GROUPE", groupe.leNom, ",  statut", groupe.statut)
        let _ = print("❌ INIT VUE DETAIL GROUPE PRINCIPAL", groupe.principal?.leTitre ?? "PAS DE PRINCIPAL")
        let _ = print("❌ INIT VUE DETAIL GROUPE PRINCIPAL RETOUR", groupe.principal?.principal?.nom ?? "PAS DE RETOUR")


    if let lePrincipal = groupe.principal {
        let _ = print("⚙️❌ BODY VUE DETAIL")

        // Si ce n'est pas un groupe isolé de son principal on présente la fiche
//        Text("Indicateur : \(groupe.integration.voyant)")
    VStack {
        BarreStatut(coherent: groupe.estCoherent, statut: groupe.statut, valide: groupe.valide)

    Form { //}(alignment: .leading, spacing: 2) {
        Section { //}(alignment: .leading, spacing: 2)  {
            let _ = print("❌ SECTION VUE DETAIL")
            Etiquette( "Item principal", valeur: (thePrincipal.titre)) //groupe.principal != nil) ? thePrincipal.titre ?? "␀" : "❌")
            Etiquette( "Valeur locale" , valeur: Int(thePrincipal.valeur))
            Etiquette( "Message"       , valeur: groupe.message) //thePrincipal.leMessage)
            Etiquette( "Créateur"      , valeur: groupe.createur)
            Etiquette( "Identifiant"   , valeur: groupe.id?.uuidString)
            Etiquette( "Nb CloudKit"   , valeur: partageEnCours?.participants.count ?? 0)
            Etiquette( "Nb Participant" , valeur: groupe.lesItems.count)
//
////            Etiquette( "Valide"        , valeur: groupe.valide)
////            Etiquette( "Cohérent"      , valeur: groupe.estCoherent)
//
////            Etiquette( "Suppression"   , valeur: groupe.isDeleted) //RQ: Mettre dans estCoherent ?
////            Etiquette( "Status CoreData" , valeur: !groupe.isFault)
            let _ = print("❌ FIN SECTION VUE DETAIL")

            }
        
        
        
        Section {
            let _ = print("❌ SECTION 2 VUE DETAIL")
            HStack {
                Etiquette( "Collaboratif"  , valeur: groupe.collaboratif)
                Spacer()
                Text(" ")
                Spacer()
                Toggle("Détails >", isOn: $voirDétailsCollaboration.animation())
                    .toggleStyle(.button)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 50)
                }
             if voirDétailsCollaboration {
                 let _ = print("〽️ voirDétailsCollaboration")
                 Section(header: Etiquette( "Collaborateurs", valeur: Int(groupe.nombre)) ) {
                     ForEach(Array(groupe.tableauItemsTrié) ) { item in
//                         Etiquette("   ⚬ \(item.principal?.nom ?? "RIEN")  (\(item.leTitre)   \(item.leMessage)" , valeur : Int(item.valeur))//.equatable()
//                         var noms:String=""
                         if let _partageTmp = persistance.obtenirUnPartageCK(item) {
                            let noms = _partageTmp.participants.compactMap {$0.userIdentity.nameComponents?.formatted(.name(style: .short))}.joined(separator: "|")
                             let _ = print("〽️〽️", noms)
                             if let _principal = item.principal {
                                 Text("° \(_principal.nom ?? "anonyme") 💭 | \(noms) ")
                                }
//                                   Text("(\(noms))").font(.caption2)
                            } // partage existe
                         else {
                             Text("° \(item.principal?.nom ?? "orphelin") ➖")
                            }


                         } // if
                     }
                 Etiquette( "Valeur globale", valeur: groupe.valeur)



                 Section(header: Etiquette( "Chefs", valeur: Int(groupe.nombre)) ) {

                     }
             }
            let _ = print("❌ FIN SECTION 2 VUE DETAIL")

            }   // FIN SECTION
        
        }
        
        
        VStack {
            VueCarteGroupe(groupe)
                .ignoresSafeArea()
                .frame( alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(  RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary, lineWidth: 0.5)
                        )
                .padding()
                .onAppear() { }
            Spacer()
            let _ = print("❌ FIN CARTOGRAPHIE VUE DETAIL")
            }
        
        
        
        }
        
        
//        .isHidden(groupe.isDeleted || groupe.isFault ? true : false)
//        .opacity(groupe.valide ? 1 : 0.1)
//        .disabled(groupe.valide ? false : true)
        .blur(radius: feuilleModificationPresentée ? 5 : 0, opaque: false)
//        .overlay(groupe.estCoherent ? Color(.clear): Color("rougeâtre").opacity(0.2))
        .overlay(estCoherent ?? false ? Color(.clear): Color("rougeâtre").opacity(0.2))

        .alert(item: $coherenceGroupe) {coherence in
            Alert(title: Text("⚠️ ERREUR ⚠️"),
                  // Recuperer les descriptions des erreurs consignées
                  message : Text("\(coherence.erreurs.map {$0.error.localizedDescription }.joined(separator: "\n")) ‼️")
            )}

        .onAppear() {
            print ("❌🔅")
//            viewModel.definirGroupe(groupe: leGroupe)
            Logger.interfaceUtilisateur.info("régionEnglobante ###### GET ONAPPEAR 2")
//            régionEnglobante = groupe.régionEnglobante
            Logger.interfaceUtilisateur.info("onAppear ###### régionEnglobante")//, régionEnglobante)
            lesAnnotations   = groupe.lesAnnotations
            estFavoris       = configUtilisateur.estFavoris(groupe)
            estCoherent      = groupe.estCoherent
            coherenceGroupe  = Coherence( err: groupe.verifierCohérence(depuis: "OnAppear de vueDetailGroupe") )
            
//            partageEnCours = persistance.obtenirUnPartageCK(groupe.principal!) //lePrincipal)
            print ("❌🔅 \(partageEnCours?.afficherParticipation()  ?? ".." ) ")
            }

        .sheet(isPresented: $feuilleModificationPresentée) {
            VueModifGroupe(groupe) {
                // Lorsque VueModifGroupe quitera elle executera le code suivant sera executé
                // avec en argument des informations provenant de VueModifGroupe
                quiterLaVue in
                Logger.interfaceUtilisateur.info("Retour de VueModifGroupe avec \(quiterLaVue ? "OK" : "KO")" )
                    feuilleModificationPresentée = false
//                Ξ.feuilleModificationItemPresentée = false

                } // fin closure

                .border( .red, width: 0.3)
                .ignoresSafeArea()
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        
        .sheet(isPresented: $feuillePartageAffichée, onDismiss: abandonnerPartage) { //}, content: {
            let _ = print("〽️〽️ - Appel de VuePartageCloudKit depuis VueDetailGroupe, pour la recrue :", nouvelleRecrue?.leTitre)
          if let __share = partageEnCours {
              let _ = print("〽️〽️ Controleur de vue et son coordinateur", coordinateurPartage?.description ?? "...", "sont utilisés pour le groupe", groupe.leNom, ", ayant comme principal :", groupe.lePrincipal.leTitre)

              //MARK: Controleur de vue de partage   et    son délégué à la coordination
              VuePartageCloudKit(
                // CloudSharingView(share: share, container: stack.ckContainer, destination: destination)
                partage: __share,
                conteneurCK: persistance.conteneurCK, //  . stack.ckContainer,
//                itemAPartager: nouvelleRecrue, //groupe.lePrincipal, //  ERREUR:
                coordinateur: DéléguéDuControleurDePartageChargéDeLaCoordination(item: nouvelleRecrue!)) // coordinateurPartage
              .border( .red, width: 0.5)
              .background(Color(.gray))
              .ignoresSafeArea()
          }
            else {let _ = print("〽️〽️ - PAS DE PARTAGE EN COURS") }
        }  // Sheet partage // )

        
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup() //placement: .navigationBarTrailing)
                { barreMenu }
            }
        
        
        // 15 mars
          //.navigationTitle(Text("Détails du groupe \(groupe.leNom)"))
        
        }
        else {
            let _ = print("❌⚙️ Pas d'item principal")
            Text("❌ PAS D'item principal \(groupe.principal?.leTitre ?? "...") pour le groupe \(groupe.leNom)")
        }
    } // body
        
    
    func abandonnerPartage() {
        print("〽️🗯 Abandonner le partage de", groupe.leNom, nouvelleRecrue?.leTitre ?? "..." , partageEnCours ?? "...")

//        nouvelleRecrue?.nuageux = false
//        nouvelleRecrue?.valide = false
        return
    }

    func _abandonnerPartage() {
        print("〽️🗯 Abandonner le partage de", groupe.leNom, nouvelleRecrue?.leTitre ?? "..." , partageEnCours ?? "...")
        let idObjet = nouvelleRecrue?.objectID
        guard (idObjet != nil) else {return}
        print("🗯🗯 idObjet :" , idObjet ?? "!!!")
        ///////////////////////
        if let magasinPersistant = idObjet?.persistentStore {
            print("🗯🗯 Magasin persistant de l'item en cours de partage :", magasinPersistant.description , "(", idObjet?.persistentStore?.description ?? "..." ,")")
                let _conteneur = NSPersistentCloudKitContainer( name: "ConteneurCloudKit")//persistentContainer  ///// DIRECT ??
                do {
                    let partages = try _conteneur.fetchShares(matching: [idObjet!])
                    if partages.first != nil {
                        partages.forEach() {_p in
                            let _pv = _p.value // CKShare
                            let id = _pv.recordID
                            let k = _pv.allKeys()

                            print("〽️🗯🗯 Partage , proprietaire :", _pv.owner.userIdentity.nameComponents ?? "...",
                                  " participation de", _pv.participants.count,
    //                              " " , cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_GROUPE_OBJECTIF") ) //
                                  " id :"     , _pv.recordID ,
    //                              " id_ :"    , _pv.recordID.value(forKey: "NIMBUS_PARTAGE_GROUPE_NOM") ?? "..." ,
                                  " NOM_ :"   , _pv.value(forKey: "NIMBUS_PARTAGE_GROUPE_NOM") ?? "..." ,
                                  " clefs_ :" , _pv.allKeys() ) // ["cloudkit.title", ...]
                            } // foreach
//                        _estPartagé = true
                    } //first
                    }
                catch {
                print("❗️Impossible de trouver un partage de \(idObjet): \(error)")
                }
        }
        ///////////////////////
        
        
        
//        persistance.estPartagé(objet: nouvelleRecrue)
//        CKShare.Participant
        guard let dernier = partageEnCours?.participants.last else { return }
        dernier.value(forKeyPath: "")
        partageEnCours?.removeParticipant(dernier)//
        }
    
    var barreMenu: some View {
        HStack {
            Spacer()
            //  Button("Alert") {
            //self.coherenceGroupe = Coherence(groupe.verifierCohérence()) //text: "Hi!")
//                      }
//            Button(action: {
//                self.coherenceGroupe = Coherence(err: groupe.verifierCohérence(depuis : "Bouton"))
//            }) {Image(systemName: "heart")}

 
            /// Favoris
            Button(action: {
                configUtilisateur.inverserFavoris(groupe, jeSuisFavoris: &estFavoris)
            }) {
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(estFavoris ? .red : .secondary)
                    Text("Favoris").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
                .help("bouton")


            /// Partager
            Button(action: {
                let _ = print("🔱 bouton de partage Cloud Kit de", groupe.leNom)
                recruter_(pourLe : groupe)
            }) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Partager").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
                .help("bouton")



//            Button {
//                let _ = print("〽️ Bouton partage événement", persistance.estPartagé(objet: groupe.lePrincipal).voyant)
////                 !persistance.isShared(object: item)
//              if !persistance.estPartagé(objet: groupe.lePrincipal) {
//                  let _ = print("〽️ \(groupe.leNom) n'est pas déjà partagé, donc création du partage.")
//                  //MARK: Création du partage
////                    Task { await creerUnPartageCK(item) } //////// 9/6/22
//                  Task { await self.partageEnCours = persistance.creerUnPartageCK(groupe.lePrincipal)  }
//
//                  }
//              feuillePartageAffichée = true
//            } label: {
//              Image(systemName: "square.and.arrow.up")
//            }.buttonStyle(.borderedProminent)




            Button(action: { feuilleModificationPresentée.toggle()  }) {
                VStack {
                    Image(systemName: "square.and.pencil")
                    Text("Modifier").font(.caption)
                    }
              }.buttonStyle(.borderedProminent)

            Button(role: .destructive, action: {
                //TODO: A mettre en // avec ListeItem
                groupe.supprimerAdhérences(mode: .défaut)
                persistance.supprimerObjets([groupe], mode: .défaut)
                }) {
                VStack {
//                    Image(systemName: Icones.supprimer.rawValue)
                    Icones.supprimer.imageSystéme
                    Text("Supprimer").font(.caption)
                    }
            }.buttonStyle(.borderedProminent)
                .opacity(0.5)
                .saturation(0.5)

            Spacer()
            }
        }

    
    private func enrôlerUnNouvelItem() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : contexte , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:contexte, recrues: [nouvelItem])
            }
        }
    
    
    func incrementer(max:Int) {
//        valeurLocale += 1
//        if valeurLocale >= max { valeurLocale = max }
//        groupe.principal?.valeur = Int64(valeurLocale)
//        persistance.sauverContexte("Item")
       }

    func decrementer(min:Int) {
//        valeurLocale -= 1
//        if valeurLocale < min { valeurLocale = min }
//        groupe.principal?.valeur = Int64(valeurLocale)
//        persistance.sauverContexte("Item")
       }
    
    
//    func shareNoteAction(_ sender: Any) {
//    func shareNoteAction(_ grp: Groupe?) {
//
//
//      guard  let grp =  grp else {
//        fatalError("Rien à partager")
//        }
//        print("Demande de partage de", grp.leNom)
////      let container = AppDelegate.sharedAppDelegate.coreDataStack.persistentContainer
//        let  container = persistance.conteneur
//        print("Demande de partage : conteneur", container.debugDescription)
//        let cloudSharingController = UICloudSharingController {
//        (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
//        print("Demande de partage : recue pour", grp.leNom)
//        container.share([grp], to: nil) { objectIDs, share, container, error in
//            print("Demande de partage recue pour", objectIDs?.first, share?.debugDescription, container.debugDescription, error)
//                if let actualShare = share {
//                    grp.managedObjectContext?.performAndWait {
//                        actualShare[CKShare.SystemFieldKey.title] = grp.leNom
//                    }
//                }
//            print("partage en cours de", grp)
//                completion(share, container, error)
//            }
//            print("Demande de partage : à l'étude")
//      }
//        print("Controleur de partage", cloudSharingController.debugDescription)
//
//      cloudSharingController.delegate = partageur
//        print("partage ..", cloudSharingController.delegate?.description ?? "...")
//        print("partage ur", partageur.description, partageur.maDescription() )
//
//
//      if let popover = cloudSharingController.popoverPresentationController {
////        popover.barButtonItem = barButtonItem
//          print("partage UIKit popover", popover.debugDescription)
//      }
////      present(cloudSharingController, animated: true) {}
//    print("Demande de partage : terminée")
//    }
    
}



extension VueDetailGroupe {

    /// Recruter un nouveau participant CK pour ce groupe
    /// càd: Ajouter un nouvel item aux items de ce groupe et ensuite le partager via Cloudkit
    func recruter_(pourLe groupe : Groupe) {
        
//        let referenceRecrue = "◎ \(groupe.id?.uuidString ?? "...")_\(UUID().uuidString)"
//        let referenceRecrue = "◎ \(groupe.leNom) \(Date())"
        let referenceRecrue = "\(groupe.leNom)_∂\(groupe.items?.count ?? 0)"
        // nouveauGroupe.items?.count ?? 0)"
        print("🔱〽️ Former et recruter l'Item :", referenceRecrue, "pour le groupe" , groupe.leNom)
        print("🔱 Ce groupe a déjà :" , groupe.lesItems.count , "items participants (CK ou non).")
        // Créer une version locale de l'item qui sera partagé
        nouvelleRecrue = Item.fournirNouveau(contexte:contexte , titre: "\(referenceRecrue)")
//        nouvelleRecrue?.nuageux = true
        nouvelleRecrue?.addToGroupes(groupe)
        groupe.addToItems(nouvelleRecrue!)
        persistance.sauverContexte()
        print("🔱 Desormais ce groupe dispose de :" , groupe.lesItems.count, "participants")
        print("🔱 La nouvelle recrue participe à", nouvelleRecrue?.groupes?.count ?? 0, "groupes")

        print("🔱 Parent (1er groupe) de la nouvelle recrue :", nouvelleRecrue?.lesGroupes.first?.leNom ?? "...")
        
//        coordinateurPartage = DéléguéDuControleurDePartageChargéDeLaCoordination(item: nouvelleRecrue!)

//        Task { await self.partageEnCours = persistance.creerUnPartageCK(nouvelleRecrue)  }
        let _ = print("🔱〽️ Nouvelle recrue déjà partagée :", persistance.estPartagé(objet: nouvelleRecrue!).voyant)
//                 !persistance.isShared(object: item)
        if !persistance.estPartagé(objet: nouvelleRecrue!) {
            let _ = print("🔱 \(nouvelleRecrue?.leTitre) n'est (EVIDEMENT) pas déjà partagé, donc création de son partage.")
            //MARK: Création du partage
            let message = "Participation à l'évenement\n \(groupe.leNom) \n \(groupe.lesItems.count)"
            Task { await self.partageEnCours = persistance.associerUnPartageCK(nouvelleRecrue!, nom: groupe.leNom, objectif:groupe.lObjectif, message: message)  }
            // La 'suite' dans DéléguéApplication.windowScene(... userDidAcceptCloudKitShareWith:
            }
        feuillePartageAffichée = true

    }

}
