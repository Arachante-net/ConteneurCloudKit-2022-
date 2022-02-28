//Arachante
// michel  le 11/01/2022

import Foundation
import MapKit

// Abstaction et Etat d'une Vue ou d'une famille de Vue
// dans la Vue elle même : @StateObject private var viewModel = ViewModel()

extension VuePrincipale {
    @MainActor class ViewModel: ObservableObject {
//        @Published var appError: ErrorType? = nil
        @Published var xxx = Date()
        @Published private (set) var ttt = [String]()

        func addTTT(x:String) {ttt.append(x)}
        }
    }

//MARK: - Item -

extension ListeItem {
    @MainActor class ViewModel: ObservableObject {
        @Published  var alerteAffichée = false
        @Published  var itemEnCours: Item?
        @Published  var itemsEnCourDeSuppression: IndexSet? //SetIndex<Item>?
      }
    }
    
extension VueDetailItem {
    @MainActor class ViewModel: ObservableObject {
        @Published var appError: ErrorType? = nil
        @Published var feuilleModificationItemPresentée   = false
        }
}

extension VueModifItemSimple {
    @MainActor class ViewModel: ObservableObject {
        
        init (_ unItem: Item) { item = unItem }
        @Published var item : Item
        
        @Published var feuilleAffectationGroupesPresentée = false
        /// La région géographique entourant l'item en cours d'édition
        @Published  var régionItem = MKCoordinateRegion (
            center: CLLocationCoordinate2D (
                latitude: Lieu.exemple.latitude,
                longitude: Lieu.exemple.longitude),
            span: Lieu.étendueParDéfaut
            )
        /// Les lieux éditables (ici on en utilise qu'un seul)
        @Published  var locations = [Lieu]()
        /// Le lieu en cours d'édition
        @Published  var leLieuÉdité: Lieu?
        }
    }






//MARK: - Groupe -



extension VueDetailGroupe {
    @MainActor class ViewModel: ObservableObject {
//        init () {
////            self.groupe = groupe
//          }
        
        @Published var appError: ErrorType? = nil
//        @Published var feuilleModificationItemPresentée   = false
        @Published var groupe:Groupe? = nil
        
        func definirGroupe(groupe:Groupe) {self.groupe = groupe}
        func obtenirGroupe() -> Groupe {self.groupe!}
        }
}



//MARK: - Autres -

extension VueEditionLieu {
    @MainActor class ViewModel: ObservableObject {
        init (_ lieuAEditer: Lieu) {
            nom         = lieuAEditer.libellé
            description = lieuAEditer.description
          }
        
        @Published  var nom: String
        @Published  var description: String

        }
    
    }
