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

//enum ModeAffectationGroupes {
//    case ralliement //= "rallier"
//    case enrôlement //= "enrôler"
//    case test       //= "test"
//    // Enrôler / Révoquer
//    // Rallier / Abandonner
//
//    var description:String? {
//        switch self {
//            case .ralliement:
//                return "Rejoindre ou abandonner l'objectif."
//            case .enrôlement:
//                return "Recruter ou congédier des contributeurs."
//            case .test:
//                return "Tester"
//            }
//        }
//    }


/// Edition et modification des caracteristique du groupe passé en parametre
struct VueModifGroupe: View {
    
    // parametres d'appel de la Vue
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    /// Le groupe en cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var groupe: Groupe
    
    /// Aller chercher d'autres groupes ou integrer un groupe (Enrôler ou rallier)
    @State private var modeAffectation :AffectationGroupes = .test

    /// Closure en parametre, a executer lorsque l'utilisateur quitte cette vue
    var laModificationDuGroupeEstRéalisée: RetourInfoAchevée //(Bool) -> Void
    typealias RetourInfoAchevée = (Bool) -> Void
    
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
    @State private var feuilleAffectationPresentée = false
    @State private var mesCollaborateurs : Set<Groupe>
    @State private var mesChefs          : Set<Groupe>

    @State var mesChefsInitiaux          : Set<Groupe>
    @State var mesCollaborateursInitiaux : Set<Groupe>


    init(_ unGroupe: Groupe, achevée: @escaping  RetourInfoAchevée) {
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        self.laModificationDuGroupeEstRéalisée = achevée
        _mesCollaborateurs = State(wrappedValue : unGroupe.collaborateursSansLePrincipal)
        _mesChefs          = State(wrappedValue : unGroupe.groupesAuxquelsJeParticipe )
        //TODO: déclarer Constant ?
        _mesChefsInitiaux          = State(wrappedValue : unGroupe.groupesAuxquelsJeParticipe )
        _mesCollaborateursInitiaux = State(wrappedValue :unGroupe.collaborateursSansLePrincipal)

        }

    var body: some View {

    NavigationView {
        VStack { //}(alignment: .leading, spacing: 2){
        Group {
            VStack { //(alignment: .leading, spacing: 1) {
                Text(" Nom du groupe :")
                TextField("Nouveau nom du groupe", text: $groupe.leNom)
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.done)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) //.roundedBorder)
//                    .padding()
                    .onSubmit { print("ENREGISTRER ET SAUVER LE CONTEXT") }
            }

            VStack {
                VueValeurItemPrincipal(item: groupe.lePrincipal , groupe: groupe )
                }

            VStack {
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
        .sheet(isPresented: $feuilleAffectationPresentée) {
            VueAffectationGroupe( groupe,

                lesCollaborateursAAffecter: $mesCollaborateurs,
                lesChefsADesigner: $mesChefs,
                                  
                modeAffectation: $modeAffectation) { (lesAffectationsOntChangées, mode) in
                    reattribuer(mode: mode)
                    reaffecter(lesAffectationsOntChangées, mode: mode )
                    }

                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItemGroup(placement: .principal) //.automatic .bottomBar .principal
                { barreMenu }
//
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: abandonerFormulaire) {
                    VStack {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                        Text("Abandon").font(.caption)
                        }
                  }
                }
//
            ToolbarItem(placement: .confirmationAction ) {
                Button( action: validerFormulaire) {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Valider").font(.caption)
                        }
                  }
                .buttonStyle(.borderedProminent) }
 //
        }//.background(Color(.gray))//.border(.gray.opacity(0.5))
        
        .navigationTitle(Text("Edition groupe \(groupe.leNom)"))
    }

        
        .onDisappear() {}// let _ = groupe.verifierCohérence(depuis: #function) }
        .onAppear()    {
            print("onAppear vueModifGroupe")
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
            Button(action: enrôlerUnNouvelItem__)
                { Label("Enrôler", systemImage: "plus.square.on.square") .frame(maxWidth: geo.size.width / 16, alignment: .bottom)   }//.frame(maxWeight: .infinity, alignment: .bottom) }
            
            Button(action: enrôlerUnGroupe) {
                VStack {
                    Image(systemName: "square.and.arrow.down.on.square.fill")  .frame(maxWidth: geo.size.width / 16, alignment: .bottom)//.frame(height:20)
                    Text("Enrôler").font(.caption)
                    }
              }
            
            Button(action: rallierUnGroupe) {
                VStack {
                    Image(systemName: "square.and.arrow.up").frame(maxWidth: geo.size.width / 16, alignment: .bottom)//.frame(height:20)
                    Text("Rallier").font(.caption)
                    }
              }
                        
            Button(action: editerPrincipal) {
                VStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis").frame(maxWidth: geo.size.width / 16, alignment: .bottom)//.frame(height:20)
                    Text("\(groupe.lePrincipal.leTitre)").font(.caption)
                    }
              }
                }
            
//MARK: - THE BUG  ! (sans le point) frame(maxHeight: .infinity, alignment: .bottom).border(.yellow) -
            
        }//.border(.gray.opacity(0.5))
            
            } // fin de geometryReader
        }
    
    
    
    //MARK: -
    
    private func validerFormulaire() {
        persistance.sauverContexte("Groupe Item")
        let _ = groupe.verifierCohérence(depuis: "validation du formulaire" )
        laModificationDuGroupeEstRéalisée(true)
        }
    
    private func abandonerFormulaire() {
        laModificationDuGroupeEstRéalisée(false)
        }
    
    private func editerPrincipal() {}
    
    private func enrôlerUnGroupe() {
        modeAffectation = .enrôlement
        feuilleAffectationPresentée=true
        }
    
    private func rallierUnGroupe() {
        modeAffectation = .ralliement
        feuilleAffectationPresentée=true
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
    
    func reattribuer (mode:AffectationGroupes) -> Void {
        var partiesPrenantes = Set<Groupe>()
        /*
         symmetricDifference(_:) éléments qui se trouvent dans l'un ou l'autre, mais pas dans les deux.
         subtracting(_:)         éléments qui ne sont dans aucun des deux ensembles.
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
        
        print("☑️❌ Je suis", groupe.leNom, "je participe aux groupes", mesChefsInitiaux.map(\.leNom) , "et je suis responsable des groupes", mesCollaborateursInitiaux.map(\.leNom) )
        print("☑️❌", changementsChefs.count        , "changements de chefs,"         , arrivéeChefs.count         , "arrivées (", arrivéeChefs.map(\.leNom)         , "),", departChefs.count,          "départs (" , departChefs.map(\.leNom)         , ").")
        print("☑️❌", changementCollaborateurs.count, "changements de collaborateurs,", arrivéeCollaborateurs.count, "arrivées (", arrivéeCollaborateurs.map(\.leNom), "),", departCollaborateurs.count, "départs (" , departCollaborateurs.map(\.leNom), ").")
        print("☑️❌ Et maintenant, je participe aux groupes", mesChefs.map(\.leNom) , "et je suis responsable des groupes", mesCollaborateurs.map(\.leNom) )

//        switch mode {
//            case .ralliement: partiesPrenantes = mesChefs
//            case .enrôlement: partiesPrenantes = mesCollaborateurs
//            case .test: print("")
//            }
    
        partiesPrenantes.forEach() {
            print("☑️❌ ", mode.rawValue ,"le groupe :", $0.leNom)

        }
        
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
                  print("☑️❌ ", mode.rawValue ,"le groupe :", $0.leNom)
                  
                  switch mode {
                      case .ralliement:
                          groupe.rallier(groupeLeader: $0)
                      case .enrôlement:
                          groupe.enroler(recrue: $0)
                      case .test:
                          print("☑️❌ Affectation test pour", $0.leNom)
                    }
                }
            }
        feuilleAffectationPresentée = false
        }
        
}




