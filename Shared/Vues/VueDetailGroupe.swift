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
    
    let coordinateurPartage : DéléguéDuControleurDePartageChargéDeLaCoordination

    
    /// Passer l'argument groupe sans étiquette `ET` le déclarer private sans pour autant générer  l'erreur  "Vue initializer is inaccessible due to 'private' protection level" lors de la compilation
    init (_ leGroupe:Groupe) {
        _groupe       = StateObject<Groupe>(wrappedValue: leGroupe)
        _thePrincipal = StateObject<Item>  (wrappedValue: leGroupe.lePrincipal)

        _régionEnglobante = State(wrappedValue: leGroupe.régionEnglobante)
//      _lesAnnotations   = State(wrappedValue: lesAnnotations ?? [])
        _lesAnnotations   = State(wrappedValue: leGroupe.lesAnnotations )
        
        coordinateurPartage = DéléguéDuControleurDePartageChargéDeLaCoordination(item: leGroupe.lePrincipal)
        coordinateurPartage.tester()

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
        
    if let lePrincipal = groupe.principal {
    // Si ce n'est pas un groupe isolé de son principal on présente la fiche
//        Text("Indicateur : \(groupe.integration.voyant)")
    VStack {
    Form { //}(alignment: .leading, spacing: 2) {
        Section { //}(alignment: .leading, spacing: 2)  {
            Etiquette( "Item principal", valeur: (thePrincipal.titre)) //groupe.principal != nil) ? thePrincipal.titre ?? "␀" : "❌")
            Etiquette( "Valeur locale" , valeur: Int(thePrincipal.valeur))
            Etiquette( "Message"       , valeur: groupe.message) //thePrincipal.leMessage)
            Etiquette( "Créateur"      , valeur: groupe.createur)
            Etiquette( "Identifiant"   , valeur: groupe.id?.uuidString)
//            Etiquette( "Valide"        , valeur: groupe.valide)
//            Etiquette( "Cohérent"      , valeur: groupe.estCoherent)

//            Etiquette( "Suppression"   , valeur: groupe.isDeleted) //RQ: Mettre dans estCoherent ?
//            Etiquette( "Status CoreData" , valeur: !groupe.isFault)
            }
        Section {
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
//                    .border(Color.secondary, width: 0.5) //.border(.)
                }
             if voirDétailsCollaboration {
                 Section(header: Etiquette( "Collaborateurs", valeur: Int(groupe.nombre)) ) {
     //                ForEach(Array(groupe.lesItems).sorted()    ) { item in
                     ForEach(Array(groupe.tableauItemsTrié) ) { item in
                         Etiquette("   ⚬ \(item.principal?.nom ?? "RIEN")  (\(item.leTitre)   \(item.leMessage)" , valeur : Int(item.valeur))//.equatable()
                         Etiquette("   . \(item.leTitre) CK " , valeur : persistance.estPartagé(objet: item) )
                         
                         if let _partageTmp = persistance.obtenirPartage(item) {
                             ForEach(_partageTmp.participants, id: \.self) { participant in
                               VStack(alignment: .leading) {
                                    Text(" * \(item.leTitre) |\(participant.userIdentity.nameComponents?.formatted(.name(style: .short)) ?? "anonyme")| ")
                                    }
                               .padding(.bottom, 8)
                              } // for each partage
                            } // partage existe
                         else {Text(" * \(item.leTitre) non partagé CK.") }
                         
                         
                         }
                     }
                 Etiquette( "Valeur globale", valeur: groupe.valeur)
                 
//                 ForEach(Array(groupe.tableauItemsTrié) ) { item in
//                     Etiquette("   ⚬ \(item.principal?.nom ?? "RIEN")  (\(item.leTitre)   \(item.leMessage)" , valeur : true    )
//                     }
                 
//                 }
                
                 
                 Section(header: Etiquette( "Chefs", valeur: Int(groupe.nombre)) ) {

                     }
             }
            }
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
//            viewModel.definirGroupe(groupe: leGroupe)
            Logger.interfaceUtilisateur.info("régionEnglobante ###### GET ONAPPEAR 2")
//            régionEnglobante = groupe.régionEnglobante
            Logger.interfaceUtilisateur.info("onAppear ###### régionEnglobante")//, régionEnglobante)
            lesAnnotations   = groupe.lesAnnotations
            estFavoris       = configUtilisateur.estFavoris(groupe)
            estCoherent      = groupe.estCoherent
            coherenceGroupe  = Coherence( err: groupe.verifierCohérence(depuis: "OnAppear de vueDetailGroupe") )
            
            partageEnCours = persistance.obtenirPartage(groupe.lePrincipal)
            }

        .sheet(isPresented: $feuilleModificationPresentée) {
//            laCarteEstVisible.toggle()
            // Cannot convert value of type 'ObservedObject<Groupe>.Wrapper' to expected argument type 'ObservedObject<Groupe>'
            // groupe : Groupe
            // $groupe : ObservedObject<Groupe>.Wrapper
            // _groupe : StateObject<Groupe>
            // ObservedObject<Groupe>
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
            // 5 avril  // .objectWillChange.send()
//                .onDisappear() {groupe.integration.toggle()}
            }
//            .transition(.opacity) //.move(edge: .top))
        
        .sheet(isPresented: $feuillePartageAffichée) { //}, content: {
          let _ = print("〽️〽️ - Appel de VuePartageCloudKit depuis VueDetailGroupe")
          if let __share = partageEnCours {
//              let _ = print("〽️〽️ Création du coordinateur de partage de", item.leTitre)
//              let coord = CoordinateurDePartageCloudKit(item: item)
              let _ = print("〽️〽️ Controleur de vue et son coordianateur", coordinateurPartage, "sont utilisés pour le groupe", groupe.leNom, "item:", groupe.lePrincipal.leTitre)
              
              //MARK: Controleur de vue de partage   et    son délégué à la coordination
              VuePartageCloudKit(
                // CloudSharingView(share: share, container: stack.ckContainer, destination: destination)
                partage: __share,
                conteneurCK: persistance.conteneurCK, //  . stack.ckContainer,
                itemAPartager: groupe.lePrincipal,
                coordinateur: coordinateurPartage) //CoordinateurDePartageCloudKit(item: item))
              .border( .red, width: 0.3)
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
    } // body
        
    
    
    var barreMenu: some View {
        HStack {
            Spacer()
            //  Button("Alert") {
            //self.coherenceGroupe = Coherence(groupe.verifierCohérence()) //text: "Hi!")
//                      }
//            Button(action: {
//                self.coherenceGroupe = Coherence(err: groupe.verifierCohérence(depuis : "Bouton"))
//            }) {Image(systemName: "heart")}
            
            

            Button(action: {
                configUtilisateur.inverserFavoris(groupe, jeSuisFavoris: &estFavoris)
            }) {
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(estFavoris ? .red : .secondary)
                    Text("Favoris").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
                .help("bouton")
            
            
            
            Button(action: {
                Recruter(pourLe : groupe)
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
                groupe.supprimerAdhérences(mode: .simulation)
                persistance.supprimerObjets([groupe], mode: .simulation)
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
    
    func Recruter(pourLe groupe : Groupe) {
        let referenceRecrue = "\(groupe.id?.uuidString ?? "...")_\(UUID().uuidString)"
        print("🔱 REFERENCE A RECRUTER :", referenceRecrue, "pour le groupe" , groupe.leNom)
        print("🔱 LES ITEMS avant :" , groupe.lesItems.count)
//        let nouvelleRecrue:Item = creer(contexte: contexte, titre: "\(referenceRecrue)")
        let nouvelleRecrue = Item.fournirNouveau(contexte:contexte , titre: "\(referenceRecrue)")

//        groupe.enrôler(contexte: contexte, titre: "\(referenceRecrue)")
//        nouvelleRecrue.principal=groupe // NON
        nouvelleRecrue.titre = "TMP \(groupe.leNom) \(Date())"
        nouvelleRecrue.addToGroupes(groupe)
        groupe.addToItems(nouvelleRecrue)
        persistance.sauverContexte()
        print("🔱 LES ITEMS apres :" , groupe.lesItems.count)
//        Task { await self.partageEnCours = persistance.creerUnPartageCK(nouvelleRecrue)  }
        let _ = print("🔱 Elaboration du partage", persistance.estPartagé(objet: nouvelleRecrue).voyant)
//                 !persistance.isShared(object: item)
        if !persistance.estPartagé(objet: nouvelleRecrue) {
            let _ = print("🔱 \(nouvelleRecrue.leTitre) n'est (EVIDEMENT) pas déjà partagé, donc création du partage.")
            //MARK: Création du partage
            let message = "Participation à l'évenement\n \(groupe.leNom) \n \(groupe.lesItems.count)"
            Task { await self.partageEnCours = persistance.creerUnPartageCK(nouvelleRecrue, message: message)  }

            }
        feuillePartageAffichée = true

    }

}
