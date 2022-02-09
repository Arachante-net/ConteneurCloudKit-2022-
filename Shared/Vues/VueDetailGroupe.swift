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

  
/// Affiche les propriétés du Groupe passé en argument
struct VueDetailGroupe: View {
    
    @Environment(\.managedObjectContext) private var contexte

    @EnvironmentObject private var persistance       : ControleurPersistance
    @EnvironmentObject private var configUtilisateur : Utilisateur
    
    
    //MARK: - ♔ Source de veritée, c'est cette Vue qui est proprietaire et créatrive de `groupe`
    // Rq: avec @State l'etat n'est pas MàJ immediatement
    // https://stackoverflow.com/questions/60111947/swiftui-prevent-view-from-refreshing-when-presenting-a-sheet?rq=1
    /// Argument, Le groupe en cours d'édition, propriétée de  la Vue  VuedetailGroupe
    /// // 1er Février 1
    @StateObject private var groupe: Groupe //= Groupe()
    // le groupe est fourni par ListeGroupe, il est instancié plus bas, dans l'init()
    //MARK: -
    //TODO: ? Faire un StateObject Groupe accedé directement par toutes les sous-vues ou le passer par argument
   
    @StateObject private var viewModel = ViewModel()
    
    
//    @State var appError: ErrorType? = nil
//    @State var coherenceGroupe: Coherence? = nil //[ErrorType]? = nil
    
    @State private var coherenceGroupe: Coherence? = nil
    @State private var estCoherent:Bool? = nil

////////////////   6 février
    @State private var régionEnglobante: MKCoordinateRegion //= nil
    @State private var lesAnnotations: [AnnotationGeographique]? = nil


    // Etats 'locaux' de la Vue
    @State private var collaboration = false
    @State private var nom           = ""

    @State private var feuilleModificationPresentée = false
//    @State var laCarteEstVisible = true
    
    /// Le groupe édité fait partie des favoris de l'utilisateur
    @State private var estFavoris = false
    
    
    @State private var voirDétailsCollaboration = false
    
    /// Passer l'argument groupe sans étiquette `ET` le déclarer private sans pour autant générer  l'erreur  "Vue initializer is inaccessible due to 'private' protection level" lors de la compilation
    init (_ leGroupe:Groupe) {
        _groupe = StateObject<Groupe>(wrappedValue: leGroupe)
//        _groupe = ObservedObject<Groupe>(wrappedValue: leGroupe)
//        _estCoherent = State(wrappedValue: groupe.estCoherent)
//        coherenceGroupe = Coherence( erreurs: groupe.verifierCohérence() )
        print("VueDetailGroupe ######  INIT", leGroupe.leNom)
 ////////////////////   6 février
        _régionEnglobante = State(wrappedValue: leGroupe.régionEnglobante)    //régionEnglobante)
        _lesAnnotations   = State(wrappedValue: lesAnnotations ?? [])
        }
    
    
    // configUtilisateur.estFavoris(groupe) //TODO: comment faire ça ?
    //TODO: essayer estFavoris? = nil

//    static func == (lhs: VueDetailGroupe, rhs: VueDetailGroupe) -> Bool {
//        // propriétés qui identifient que la vue est égale et ne doit pas être réactualisée
//        
//           // << return yes on view properties which identifies that the
//           // view is equal and should not be refreshed (ie. `body` is not rebuilt)
//        false
//       }
    
    
    var body: some View {
    let _ = assert(groupe.principal != nil, "❌ Groupe isolé")
//    let appError = ErrorType( .trucQuiVaPas(num: 666))
//       let coherenceGroupe = Coherence( erreurs: groupe.verifierCohérence() )
//      self.coherenceGroupe = Coherence( erreurs: groupe.verifierCohérence() )


    VStack {
    Form { //}(alignment: .leading, spacing: 2) {
        Section { //}(alignment: .leading, spacing: 2)  {
            Etiquette( "Item principal", valeur: (groupe.principal != nil) ? groupe.principal!.titre ?? "␀" : "❌")
            Etiquette( "Valeur locale" , valeur: Int(groupe.principal?.valeur ?? 0))
            Etiquette( "Créateur"      , valeur: groupe.createur).help("créateur")
            Etiquette( "Identifiant"   , valeur: groupe.id?.uuidString)
//            Etiquette( "Valide"        , valeur: groupe.valide)
//            Etiquette( "Cohérent"      , valeur: groupe.estCoherent)

//            Etiquette( "Suppression"   , valeur: groupe.isDeleted) //TODO: Mettre dans estCoherent ?
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
                         Etiquette("   ⚬ \(item.principal?.nom ?? "RIEN")  (\(item.leTitre))" , valeur : Int(item.valeur))//.equatable()
                         }
                     }
                 Etiquette( "Valeur globale", valeur: groupe.valeur)
             }
            }
        }
        VStack {
            VueCarteGroupe(
                // ?? La vue carte groupe ne modifie pas la région et les annotations
//                région:      $groupe.régionEnglobante,
//                annotations: $lesAnnotations
//                visible: !feuilleModificationPresentée
                groupe).frame( alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(  RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary, lineWidth: 0.5)
                        )
                .padding()
                .onAppear() {
                    print("régionEnglobante ###### GET ONAPPEAR 1")
//                    régionEnglobante = groupe.régionEnglobante
                    print("onAppear ###### VueCarteGroupe depuis détail")//, régionEnglobante)
                    }
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
            print("régionEnglobante ###### GET ONAPPEAR 2")
//            régionEnglobante = groupe.régionEnglobante
            print("onAppear ###### régionEnglobante")//, régionEnglobante)
            lesAnnotations   = groupe.lesAnnotations
            estFavoris       = configUtilisateur.estFavoris(groupe)
            estCoherent      = groupe.estCoherent
            coherenceGroupe  = Coherence( err: groupe.verifierCohérence(depuis: "OnAppear de vueDetailGroupe") )
            }

        .sheet(isPresented: $feuilleModificationPresentée) {
//            laCarteEstVisible.toggle()
            // Cannot convert value of type 'ObservedObject<Groupe>.Wrapper' to expected argument type 'ObservedObject<Groupe>'
            // groupe : Groupe
            // $groupe : ObservedObject<Groupe>.Wrapper
            // _groupe : StateObject<Groupe>
            // ObservedObject<Groupe>
            VueModifGroupe(groupe) { quiterLaVue in
                            print("Retour de VueModifGroupe avec", quiterLaVue )
                            feuilleModificationPresentée = false
//                            laCarteEstVisible=true
//                self.  refresh()
                            }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
//            .transition(.opacity) //.move(edge: .top))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup() //placement: .navigationBarTrailing)
                { barreMenu }
            }
          .navigationTitle(Text("Détails du groupe \(groupe.leNom)"))
    } // body
        
    
    
    var barreMenu: some View {
        HStack {
            Spacer()
            //  Button("Alert") {
            //self.coherenceGroupe = Coherence(groupe.verifierCohérence()) //text: "Hi!")
//                      }
            Button(action: {
                self.coherenceGroupe = Coherence(err: groupe.verifierCohérence(depuis : "Bouton"))
            }) {Image(systemName: "heart")}
            
            

            Button(action: {
                configUtilisateur.inverserFavoris(groupe, jeSuisFavoris: &estFavoris)
            }) {
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(estFavoris ? .red : .secondary)
                    Text("Favoris").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
                .help("bouton")
            
            
            
            Button(action: { feuilleModificationPresentée.toggle()  }) {
                VStack {
                    Image(systemName: "square.and.pencil")
                    Text("Modifier").font(.caption)
                    }
              }.buttonStyle(.borderedProminent)

            Button(role: .destructive, action: { print ("NON IMPLEMENTÉ") }) {
                //TODO: A implementer (cf. ListeItem)
                VStack {
                    Image(systemName: "trash")
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
    
}




