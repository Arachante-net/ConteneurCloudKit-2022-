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
import os.log



/// Edition et modification des caracteristique du groupe passé en parametre
struct VueModifGroupe: View {
    
    // parametres d'appel de la Vue
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    /// Le groupe en cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var groupe: Groupe
        
    /// Aller chercher d'autres groupes ou integrer un groupe (Enrôler ou rallier)
    @State private var modeAffectation :AffectationGroupes = .test

    /// Bout de code (Closure) en parametre, a executer lorsque l'utilisateur quitte cette vue
    /// afin de signifier à la vue appelante la fin de cette vue et lui fournir des informations en retour
    var reponseAmaMère:    ReponseAmaMère
//    var laModificationDuPrincipalEstRéalisée: RetourInfoItemAchevé

    typealias ReponseAmaMère    = (Bool) -> Void

    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle
    
    @Environment(\.managedObjectContext) var contexte
    @EnvironmentObject private var persistance : ControleurPersistance
    
    /// Les données resultant de la requête  Groupe.extractionCollaboratifs
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs, // extraction, //ListeGroupeItem.extraction,
      animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
    
    /// Etats locaux
    ///
    @State  private var itemPrincipal : Item
    @State  private var laRégion : MKCoordinateRegion


    @State private var feuilleAffectationPrésentée      = false
    @State private var feuilleEditionPrincipalPrésentée = false
    @State private var feuilleAffichée: Feuilleaffichée? = nil

    
    @State private var mesCollaborateurs : Set<Groupe>
    @State private var mesChefs          : Set<Groupe>

    var mesChefsInitiaux          =  Set<Groupe>()
    var mesCollaborateursInitiaux =  Set<Groupe>()

//    @Binding var laRegion: MKCoordinateRegion
    /// Code à effectuer lorsque terminée afin de retourner des info
//    let achevée: (Item) -> Void
    
    
    init(_ unGroupe: Groupe, achevée: @escaping  ReponseAmaMère) {
        
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        
         reponseAmaMère    = achevée
//         self.laModificationDuPrincipalEstRéalisée = achevée
        
        _mesCollaborateurs = State(wrappedValue : unGroupe.collaborateursSansLePrincipal)
        _mesChefs          = State(wrappedValue : unGroupe.groupesAuxquelsJeParticipe )
        
        _itemPrincipal     = State(wrappedValue : unGroupe.lePrincipal)
        _laRégion          = State(wrappedValue : unGroupe.régionEnglobante)

        //TODO: déclarer ici dans l'init ou lors de onAppear ? ?
        mesChefsInitiaux          = unGroupe.groupesAuxquelsJeParticipe
        mesCollaborateursInitiaux = unGroupe.collaborateursSansLePrincipal
        }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack { //}(alignment: .leading, spacing: 2){
                Group {
                    VStack { //(alignment: .leading, spacing: 1) {
                        Text(" Nom du groupe :")
                        TextField("Nouveau nom du groupe", text: $groupe.leNom)
                            .foregroundColor(Color.accentColor)
                            .submitLabel(.done)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) //.roundedBorder)
        //                    .padding()
                            .onSubmit { Logger.interfaceUtilisateur.info("ENREGISTRER ET SAUVER LE CONTEXT") }
                        }

                    VStack {
                        VueValeurItemPrincipal(item: groupe.lePrincipal , groupe: groupe )
                        VueModifItemSimple(groupe) { itemEnRetour in
                            Logger.interfaceUtilisateur.debug("INFO EN RETOUR DE VUE MODIF ITEM \(itemEnRetour.leTitre) \(itemEnRetour.longitude) \(itemEnRetour.latitude) ")
                            
                            feuilleEditionPrincipalPrésentée = false
                            }
                        }

                    VStack {// Indicateurs binaires
                        Toggle("Collaboratif", isOn: $groupe.collaboratif)
                            .toggleStyle(.switch)  //.toggleStyle(.button)

                        Toggle("Valide",       isOn: $groupe.valide)
                            .toggleStyle(.switch) //.checkbox)
                        }
                    }
                    .padding()
                    .overlay( RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.secondary, lineWidth: 0.5)
                        )
                    .padding()


                }
                .sheet(isPresented: $feuilleEditionPrincipalPrésentée) {
                    Text("Bientôt ici : EDITION DU PRINCIPAL")
                    Button("OK") { feuilleEditionPrincipalPrésentée = false}
                    }
                
                .sheet(isPresented: $feuilleAffectationPrésentée) {
                    VueAffectationGroupe( groupe,

                        lesCollaborateursAAffecter: $mesCollaborateurs,
                        lesChefsADesigner: $mesChefs,
                                          
                        modeAffectation: $modeAffectation) { (lesAffectationsOntChangées, mode) in
                        Logger.interfaceUtilisateur.info("☑️ retour de feuille")
                                if lesAffectationsOntChangées {
                                    reattribuer()
                                   }
                            // C'est fini masquer la feuille
                            feuilleAffectationPrésentée = false
                            }

                        .environment(\.managedObjectContext, persistance.conteneur.viewContext)
                    }
                // 15 mars
                //.navigationBarTitleDisplayMode(.inline)
                .toolbar {

                    ToolbarItemGroup(placement: .principal) //.automatic .bottomBar .principal
                        { barreMenu }
        //
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel, action: abandonerFormulaire) {
                            VStack {
                                Icones.abandoner.imageSystéme
                                Text("Abandon").font(.caption)
                                }
                          }
                        }
        //
                    ToolbarItem(placement: .confirmationAction ) {
                        Button( action: validerFormulaire) {
                            VStack {
                                Icones.valider.imageSystéme
                                Text("Valider").font(.caption)
                                }
                          }
                        .buttonStyle(.borderedProminent) }
         //
                }//.background(Color(.gray))//.border(.gray.opacity(0.5))
                // 15 mars
                //.navigationTitle(Text("Edition groupe \(groupe.leNom)"))
            }
        }
        
        .onDisappear() {}// let _ = groupe.verifierCohérence(depuis: #function) }
        .onAppear()    {
            Logger.interfaceUtilisateur.info("onAppear vueModifGroupe")
//            mesChefsInitiaux = mesChefs
//            mesCollaborateursInitiaux = mesCollaborateurs

//            let mesChefsInitiaux = mesChefs
//            let mesCollaborateursInitiaux = mesCollaborateurs

//            let _ = groupe.verifierCohérence(depuis: #function)
            }
                    
        
    }
        
    
    
    
    
//MARK: -
    
    
    var barreMenu: some View {
        GeometryReader { geo in

        HStack {
//            GeometryReader { geo in
//                let _ = print("GEO", geo.size.height, geo.size.width)
            // enroler dock.arrow.down.rectangle  square.and.arrow.down square.and.arrow.down.on.square.fill
            // rallier menubar.arrow.up.rectangle square.and.arrow.up
            // TODO: Utiliser PreferenceKey ?
            Group {
//                Button(action: enrôlerUnNouvelItem__)
//                    { Label("Enrôler", systemImage: "plus.square.on.square")
//                        .frame(maxWidth: geo.size.width / 16, alignment: .bottom)
//                        .foregroundColor(.secondary)
//                    }
                
                Button(action: affecterUnGroupe) {
                    VStack {
                        Icones.affecter.imageSystéme
                            .frame(maxWidth: geo.size.width / 16, alignment: .bottom)
                        Text("Affecter").font(.caption)
                        }
                  }
                
                
//                Button(action: enrôlerUnGroupe) {
//                    VStack {
//                        Icones.enroler.imageSystéme
//                            .frame(maxWidth: geo.size.width / 16, alignment: .bottom)
//                        Text("Enrôler").font(.caption)
//                        }.foregroundColor(.secondary)
//                    }
//
//                Button(action: rallierUnGroupe) {
//                    VStack {
//                        Icones.rallier.imageSystéme
//                            .frame(maxWidth: geo.size.width / 16, alignment: .bottom)
//                        Text("Rallier").font(.caption)
//                        }.foregroundColor(.secondary)
//
//                  }
                            
                Button(action: editerPrincipal) {
                    VStack {
                        Icones.éditerP.imageSystéme
                            .frame(maxWidth: geo.size.width / 16, alignment: .bottom)
                        Text("\(groupe.lePrincipal.leTitre)")
                            .font(.caption)
                        }
                  }
                }
            
//MARK: - THE BUG  ! (sans le point) frame(maxHeight: .infinity, alignment: .bottom).border(.yellow) -
            
        }//.border(.gray.opacity(0.5))
            
            } // fin de geometryReader
        }
    
    
    
    //MARK: -
    
    private func validerFormulaire() {
//        itemPrincipal.centrerSur(laRégion)
             
        // Executer le code (closure) fourni à cette Vue (VueModifItem) en parametre d'entrée
        // par la vue appelante. (permet une remontée d'information)
        persistance.sauverContexte("Groupe Item")
        let _ = groupe.verifierCohérence(depuis: "validation du formulaire" )
        // Informer la vue appelante qu'il y a eu des modifications du Groupe
        reponseAmaMère(true)
        }
    
    private func abandonerFormulaire() {
        // Informer la vue appelante qu'il n'y a pas eu de modification
        // et effectuer un rollback (un reset ?)
        persistance.retourArriereContexte()
        reponseAmaMère(false)
        }
    
    private func editerPrincipal() {
        feuilleEditionPrincipalPrésentée=true
        }
    
    private func affecterUnGroupe() {
        modeAffectation = .enrôlement
        feuilleAffectationPrésentée=true
        }
    
    private func rallierUnGroupe() {
        modeAffectation = .ralliement
        feuilleAffectationPrésentée=true
        }

    
    //RQ: Cela correspond à quoi d'enrôler directement un Item ?
    private func enrôlerUnNouvelItem__() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : contexte , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:contexte, recrues: [nouvelItem])
            }
        }
    
    private func enrôlerDesItems_() {
        withAnimation {
            let nouveaux: Set<Item> = []
            groupe.enrôler(contexte:contexte, recrues: nouveaux)
            }
        }
    
    func reattribuer () -> Void { //_ lesAffectationsOntChangées:Bool, mode:AffectationGroupes) -> Void {
        /* RAPPELS :
         symmetricDifference(_:) éléments qui se trouvent dans l'un ou l'autre, mais pas dans les deux.
         subtracting(_:)         éléments qui ne sont dans aucun des deux ensembles.
         
         Les collaborateurs sont les groupe dont je suis le Chef/Leader/Referent et qui partage le même objectif que moi.
         Je les ai enrolés ou ils m'ont rallier.
         Cette collaboration peut etre rompue si je révoque un groupe ou s'il demissione.
         
         Les chefs sont les groupes Leaders/Referents auxquels je participe.
         En les ayant rallier ou en ayant été enrolé par eux. demissioner révoquer
         Cette collaboration peut etre rompue si je démissione ou si le chef me révoque.
         */
        
        
        /// les chefs en plus ou en moins
        let changementsChefs         = mesChefs.symmetricDifference(mesChefsInitiaux)
        /// les chefs qui arrivent
        let arrivéeChefs             = changementsChefs.intersection(mesChefs)
        /// les chefs qui partent
        let departChefs              = changementsChefs.intersection(mesChefsInitiaux)
        /// les collaborateurs en plus ou en moins
        let changementCollaborateurs = mesCollaborateurs.symmetricDifference(mesCollaborateursInitiaux)
        /// les collaborateurs qui arrivent
        let arrivéeCollaborateurs    = changementCollaborateurs.intersection(mesCollaborateurs)
        /// les collaborateurs qui partent
        let departCollaborateurs     = changementCollaborateurs.intersection(mesCollaborateursInitiaux)
        
        //TODO: Voir si cela represete un rique et s'il faut statuer sur une stratégie de résolution
        /// les groupes qui sont simultanement chef et collaborateur
        let chefsEtCollaborateurs = mesChefs.intersection(mesCollaborateurs)
        /// vrai si je suis dans les deux camps
        let doublejeu = chefsEtCollaborateurs.contains(groupe)
        
        Logger.interfaceUtilisateur.info("☑️❌ Je suis \(groupe.leNom) je participe aux groupes \(mesChefsInitiaux.map(\.leNom)) et je suis responsable des groupes \(mesCollaborateursInitiaux.map(\.leNom)) ")
        Logger.interfaceUtilisateur.info("☑️❌ \(changementsChefs.count        ) changements de chefs, \(arrivéeChefs.count) arrivées ( \(arrivéeChefs.map(\.leNom))), \(departChefs.count) départs ( \(departChefs.map(\.leNom))) ")
        Logger.interfaceUtilisateur.info("☑️❌ \(changementCollaborateurs.count) changements de collaborateurs, \(arrivéeCollaborateurs.count) arrivées ( \(arrivéeCollaborateurs.map(\.leNom))), \(departCollaborateurs.count) départs ( \(departCollaborateurs.map(\.leNom))).")
        Logger.interfaceUtilisateur.info("☑️❌ Et desormais, je participerais aux groupes \(mesChefs.map(\.leNom)) et serais responsable des groupes \(mesCollaborateurs.map(\.leNom) ) ")
        Logger.interfaceUtilisateur.info("☑️❌ \(chefsEtCollaborateurs.map(\.leNom)) sont à la fois mes chefs et mes collaborateurs")
        Logger.interfaceUtilisateur.info("☑️❌ Je suis chef et grouillot ? : \(doublejeu.voyant)")
        
        // Je démissione (résultat équivalent à ce qu'il me révoque)
        departChefs.forEach { groupe.démissionner(groupeLeader: $0) }
        
        // je me rallie (ou il m'enrôle)
        arrivéeChefs.forEach {groupe.rallier(groupeLeader: $0)}
        
        // je révoque cette ancienne recrue (ou elle démissione)
        departCollaborateurs.forEach {groupe.révoquer(recrue: $0)}
        
        // Je l'enrôle (ou elle me rallie)
        arrivéeCollaborateurs.forEach { groupe.enrôler(recrue: $0) }
    

        // C'est fini
//        feuilleAffectationPrésentée = false
        }
    
    /// Enroler ou Rallier
    func reaffecter(_ lesAffectationsOntChangées:Bool, mode:AffectationGroupes) -> Void {
        if lesAffectationsOntChangées {
            // Si évolution
            // Vider la liste correspondante //des items
//            #error("pas les mêmes listes, on ne les a pas ici")
            groupe.items = NSSet()
            // Et la recréer avec les nouveaux groupes
              mesCollaborateurs.forEach() {
                  Logger.interfaceUtilisateur.info("☑️❌ \(mode.rawValue) le groupe : \($0.leNom) ")
                  
                  switch mode {
                      case .ralliement:
                          groupe.rallier(groupeLeader: $0)
                      case .enrôlement:
                          groupe.enrôler(recrue: $0)
                      case .test:
                          Logger.interfaceUtilisateur.info("☑️❌ Affectation test pour \($0.leNom)")
                    }
                }
            }
        feuilleAffectationPrésentée = false
        }
        
}



enum Feuilleaffichée: Identifiable {
    var id:UUID {UUID()}
    /// Gestion des collaborations entres groupes (enrôler, rallier ...)
    /// correspond à VueAffectationGroupe
    case affectation
    /// Modification des 'détails' du groupe stocké dans son Item Principal
    case principal
    /// un exemple avec paramètre
    case feuilleA(_ arg: Any)
    /// un exemple avec paramètre
    case feuilleB(_ arg: Any)
    
    }


