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

enum ModeAffectationGroupes {
    case ralliement //= "rallier"
    case enrôlement //= "enrôler"
    case test       //= "test"
    // Enrôler / Révoquer
    // Rallier / Abandonner

    var description:String? {
        switch self {
            case .ralliement:
                return "Rejoindre ou abandonner l'objectif."
            case .enrôlement:
                return "Recruter ou congédier des participants qui contriburons à l'objectif."
            case .test:
                return "Tester"
            }
        }
    }


/// Edition et modification des caracteristique du groupe passé en parametre
struct VueModifGroupe: View {
    
    // parametres d'appel de la Vue
    /// Le groupe en cour d'édition, ( il est la propriétée de  la vue mere)
//    @ObservedObject var groupe: Groupe
    /// Le groupe en cour d'édition, ( il est la propriétée de  .... moi)
    @State var groupe: Groupe
    
    /// Aller chercher d'autres groupes ou integrer un groupe
    @State var modeAffectation :ModeAffectationGroupes = .test//? = nil // = .test//? = nil

    /// Closure en parametre, a executer lorsque l'utilisateur quitte cette vue
    var laModificationDuGroupeEstRéalisée: (Bool) -> Void
    
    @Environment(\.managedObjectContext) var contexte
    @EnvironmentObject private var persistance : ControleurPersistance
    
    /// Les données resultant de la requete  Groupe.extractionCollaboratifs
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs, // extraction, //ListeGroupeItem.extraction,
      animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
    
    @State var feuilleAffectationPresentée = false
    @State var lesGroupesARetenir  = Set<Groupe>() //  :  Set<Groupe> //
//    @State private var hauteurBoutonMax: CGFloat = .zero

    
    /// ici le seul interet de l'init c'est de passer a la vue le parametre groupe sans le nommé
    /// VueModifGroupe(groupe) { qui...
    init(_ unGroupe: Groupe, achevée: @escaping  (Bool) -> Void) {
        _groupe = State(wrappedValue: unGroupe)
        self.laModificationDuGroupeEstRéalisée = achevée
        // Ca bagote sur la page détail et ca n'apparait pas sur la page d'affectation
//        lesGroupesARetenir = groupe.collaborateursSansLePrincipal
        }

    var body: some View {
    NavigationView {
        VStack(alignment: .leading, spacing: 2){
        Group {
            VStack(alignment: .leading, spacing: 1) {
                Text(" Nom du groupe :")
                TextField("Nouveau nom du groupe", text: $groupe.leNom)
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.done)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) //.roundedBorder)
                    .padding()
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
//        .sheet(item: $modeAffectation) {
            VueAffectationGroupe(
                groupe:$groupe,
                lesGroupesAAffecter: $lesGroupesARetenir,
                modeAffectation: $modeAffectation) { lesGroupesRetenus in
                    lesGroupesRetenus.forEach() {
                        groupe.enroler(recrue: $0)
                        }
                    print(">>> ON SAUVE")
                    feuilleAffectationPresentée = false
                    }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing)
                { barreMenu }
            }
        .navigationTitle(Text("Edition groupe ") + Text("\(groupe.leNom)").bold().foregroundColor(.accentColor))
    }

        
        .onDisappear() { let _ = groupe.verifierCohérence(depuis: #function) }
        .onAppear()    {
            let _ = groupe.verifierCohérence(depuis: #function)
            // initialiser (nb ne peut être dans init() ) la liste des collaborateurs,
            // qui sera eventuellement modifiée par la Vue Affectation Groupe
            lesGroupesARetenir = groupe.collaborateursSansLePrincipal
            }
                    
        
    }
        
    
    
    
    
//MARK: -
    
    
    var barreMenu: some View {
        HStack {
//            GeometryReader { geo in
            // enroler dock.arrow.down.rectangle  square.and.arrow.down square.and.arrow.down.on.square.fill
            // rallier menubar.arrow.up.rectangle square.and.arrow.up
            Button(action: enrôlerUnNouvelItem__)
                { Label("Enrôler", systemImage: "plus.square.on.square") }//.isHidden(!groupe.collaboratif)
                .buttonStyle(.bordered)
//                .background(rectReader($hauteurBoutonMax))
                .frame(minHeight: 50, alignment: .bottom) //geo.size.height)
            
            Button(action: enrôlerUnGroupe) {
                VStack {
                    Image(systemName: "square.and.arrow.down.on.square.fill")
                    Text("Enrôler").font(.caption)
                    }
              }
                    .frame(minHeight: 50) // geo.size.height)
                    .buttonStyle(.bordered)
            
            Button(action: rallierUnGroupe) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Rallier").font(.caption)
                    }
              }
//            .frame(minHeight: 20) //geo.size.height)
            .buttonStyle(.bordered)
                        
            Button(action: editerPrincipal) {
                VStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
//                    Text("Editer le principal : ")
                    Text("\(groupe.lePrincipal.leTitre)").font(.caption)
                    }
              }
            .frame(minHeight: 50) //geo.size.height)
            .buttonStyle(.bordered)
            
            Button(action: validerFormulaire) {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Valider").font(.caption)
                    }
              }
            .frame(minHeight: 50) //geo.size.height)
            .buttonStyle(.borderedProminent)
            
            }
        }
    
    private func validerFormulaire() {
        persistance.sauverContexte("Groupe Item")
        let _ = groupe.verifierCohérence(depuis: "validation du formulaire" )
        laModificationDuGroupeEstRéalisée(true)
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

    
    
    
    private func enrôlerUnNouvelItem__() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : contexte , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:contexte, recrues: [nouvelItem])
            }
        }
    
    private func enrôlerDesItems() {
        withAnimation {
            let nouveaux: Set<Item> = []
            groupe.enrôler(contexte:contexte, recrues: nouveaux)
            }
        }
    
}




