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
                return "Recruter ou congédier des contributeurs."
            case .test:
                return "Tester"
            }
        }
    }


/// Edition et modification des caracteristique du groupe passé en parametre
struct VueModifGroupe: View {
    
    // parametres d'appel de la Vue
    /// Le groupe en cour d'édition, ( il est la propriétée de  la vue mere)
 
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    @ObservedObject var groupe: Groupe
    
    /// Aller chercher d'autres groupes ou integrer un groupe
    @State private var modeAffectation :ModeAffectationGroupes = .test//? = nil // = .test//? = nil

    /// Closure en parametre, a executer lorsque l'utilisateur quitte cette vue
    var laModificationDuGroupeEstRéalisée: (Bool) -> Void
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle
    
    @Environment(\.managedObjectContext) var contexte
    @EnvironmentObject private var persistance : ControleurPersistance
    
    /// Les données resultant de la requete  Groupe.extractionCollaboratifs
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs, // extraction, //ListeGroupeItem.extraction,
      animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
    
    /// Etats locaux
    @State private var feuilleAffectationPresentée = false
    @State private var lesGroupesARetenir  : Set<Groupe> //() //  :  Set<Groupe> //
    
    

    init(_ unGroupe: Groupe, achevée: @escaping  (Bool) -> Void) {
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        self.laModificationDuGroupeEstRéalisée = achevée
        _lesGroupesARetenir = State(wrappedValue : unGroupe.collaborateursSansLePrincipal)
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

                lesGroupesAAffecter: $lesGroupesARetenir,
                modeAffectation: $modeAffectation) { (lesAffectationsOntChangées) in
                    reaffecter(lesAffectationsOntChangées)
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
//        let _ = groupe.verifierCohérence(depuis: "abandon du formulaire" )
        laModificationDuGroupeEstRéalisée(false)
        print("====================================================================")
        }
    
    private func editerPrincipal() {}
    
    private func enrôlerUnGroupe() {
        print("ENROLER")
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
    
    func reaffecter(_ lesAffectationsOntChangées:Bool) -> Void {
        if lesAffectationsOntChangées {
            // Si évolution
            // Vider la liste des items
            groupe.items = NSSet()
            // Et la recréer avec les nouveaux groupes
              lesGroupesARetenir.forEach() {
                print("☑️❌ Enrôler le groupe :", $0.leNom)
                groupe.enroler(recrue: $0)
                }
            }
        feuilleAffectationPresentée = false
        }
        
}




