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

  

struct VueDetailGroupe: View {
    
    @Environment(\.managedObjectContext) var contexte
    
//    @ObservedObject var chronomètre = Horloge()
    
    @EnvironmentObject private var persistance : ControleurPersistance
    @Environment(\.managedObjectContext) private var viewContext
    
    // Pas utilisé, cf aussi init() //////////////////////////
//    @FetchRequest private var items:   FetchedResults<Item>

//    var groupe: Groupe
    @ObservedObject var groupe:    Groupe
    @ObservedObject var item: Item
//    @State var principal: Item



    @State var collaboration = false
    @State var nom           = ""
//    @State var rafraichir    = false
            
//    @State var valeurLocale:    Int    = 0
//
//    var chaineDécorée:AttributedString {
//        var nom = AttributedString("Michel")
//        var boite = AttributeContainer()
//            boite.foregroundColor = .blue
//            boite.underlineStyle  = .double
//            boite.underlineColor  = .red
//        nom.mergeAttributes(boite)
//        return "Bonjour " + nom
//       }
   

  var régionGéographique: MKCoordinateRegion {
    let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)

    guard let itemQuelconque = groupe.items?.anyObject() as? Item else {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(), span: span)
        }

    let coordonnées = CLLocationCoordinate2D(latitude: itemQuelconque.latitude, longitude: itemQuelconque.longitude)
    return MKCoordinateRegion(center: coordonnées, span: span)
  }

  var annotationsCartographiques: [AnnotationGeographique] {
    guard let items = groupe.items else {
      return []
      }

    return items.compactMap {
      guard let item = $0 as? Item else {
        return nil
        }

      return AnnotationGeographique(
        libellé: item.titre ?? "",
        coordonnées: CLLocationCoordinate2D(
            latitude: item.latitude,
            longitude: item.longitude),
        couleur: UIColor(item.coloris)
      )
    }
  }
    


    @State var feuilleModificationPresentée = false
    
////////////////////////////////////////////////////:
//    init(_ unGroupe: Groupe, principal:Item) {
////
//        groupe = unGroupe
//        self.principal = groupe.principal!
////
////      /// obtenir les items du groupe
////      // Rq: le souligné au début de _items, indique que nous n'adressons pas les propriétés de la demande de récupération item,
////      // nous la remplacons par une toute nouvelle demande de récupération.
////        _items = FetchRequest<Item>(
////             entity: Item.entity(),
////             sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
////             predicate: NSPredicate(format: "ANY groupes.nom = %@", unGroupe.nom!),
////             animation: .default)
////        // cf https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui
//         }

    @ViewBuilder
    var body: some View {
    let _ = assert(groupe.principal != nil, "❌ Groupe isolé")
    VStack(alignment: .leading, spacing: 2) {
//        Text("\(rafraichir.description)").font(.system(size: 1)).hidden()
        VStack(alignment: .leading, spacing: 2)  {
//            Etiquette( "Item principal", valeur: groupe.principal?.titre).padding(.leading)
            Etiquette( "Item principal", valeur : (groupe.principal != nil) ? groupe.principal!.titre ?? "..." : "❌").padding(.leading)
            Etiquette( "Collaboratif"  , valeur: groupe.collaboratif).padding(.leading)
            Etiquette( "Collaborateurs", valeur: Int(groupe.nombre)).padding(.leading)
            ForEach(Array(groupe.lesItems)) { item in
                Etiquette("⚬ \(item.titre ?? "..")" , valeur : Int(item.valeur)).padding(.leading)
                }
            Etiquette( "Valeur globale", valeur: groupe.valeur).padding(.leading)
            Etiquette( "Créateur"      , valeur: groupe.createur).padding(.leading)
            Etiquette( "Identifiant"   , valeur: groupe.id?.uuidString).padding(.leading)
            Etiquette( "Valide"        , valeur: groupe.valide).padding(.leading)
//            Etiquette( "Suppression"   , valeur: groupe.isDeleted).padding(.leading)
            Etiquette( "En erreur"     , valeur: groupe.isFault).padding(.leading)
            }
        
//        Stepper("Valeur locale : \(groupe.valeurPrincipale)", value: $groupe.valeurPrincipale)
//            .padding(.leading)


//        Stepper(value: 0) { Etiquette( "Valeur" , valeur: $groupe.valeurPrincipale) } //principal?.valeur ) } //valeurLocale) }
////                onIncrement: { incrementer(max:10) }
////                onDecrement: { decrementer(min: 0) }
//                .padding(.leading)
        
        
        
        VueCartographique(
            région: groupe.régionEnglobante,
            annotations: groupe.lesAnnotations_)
        }
    .isHidden(groupe.isDeleted || groupe.isFault ? true : false)
    .opacity(groupe.valide ? 1 : 0.1)
    .disabled(groupe.valide ? false : true)
        
    .onAppear() {
//        valeurLocale    = Int(groupe.principal?.valeur ?? 0)
        }

    .sheet(isPresented: $feuilleModificationPresentée) {
        Text("Edition")
        
        
//        let t = self.principal
        VueModifGroupe(groupe: groupe, principal: groupe.lePrincipal) { valeur in
//        VueModifGroupe(groupe: groupe, principal: groupe.principal) { valeur in
                        feuilleModificationPresentée = false
//                        rafraichir.toggle()
//                        ListeGroupe.rafraichir.toggle()
                        }
            .environment(\.managedObjectContext, persistance.conteneur.viewContext)
        
//        VueModifGroupe(groupe) { valeur in
////            print("CLOSURE" , valeur, "... ACTION FORMULAIRE MODIFICATION GROUPE")
//            feuilleModificationPresentée = false
//            }
//            .environment(\.managedObjectContext, persistance.conteneur.viewContext)
    }
    .transition(.move(edge: .top))
        
    .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { feuilleModificationPresentée.toggle() }) {
                Label("Modifier", systemImage: "square.and.pencil").labelStyle(.titleAndIcon)
                }

            }
        }
      .navigationBarTitle(Text(groupe.nom ?? ""))
    }
        
    
    private func enrôlerUnNouvelItem() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : viewContext , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:viewContext, recrues: [nouvelItem])
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

//struct FireballGroupDetails_Previews: PreviewProvider {
//  static var groupe: Groupe {
//    let controller = PersistenceController.preview
//    return controller.makeRandomFireballGroup(context: controller.viewContext)
//  }

//  static var previews: some View {
//      VueDetailGroupe(groupe: groupe)
//  }
//}


