//Arachante
// michel  le 11/01/2022
// pour le projet  simple MVVM
// Swift  5.0  sur macOS  12.1
//
//  2022
// Introducing MVVM into your SwiftUI project -
// Bucket List SwiftUI Tutorial 11/12
// Arach

import Foundation
import MapKit


extension VuePrincipale {
    // Abstaction et Etat d'une Vue ou d'une famille de Vue
    // dans la Vue elle même : @StateObject private var viewModel = ViewModel()
    @MainActor class ViewModel: ObservableObject {
        @Published var appError: ErrorType? = nil
        @Published var xxx = Date()
        @Published private (set) var ttt = [String]()

        func addTTT(x:String) {ttt.append(x)}
        }
    }


extension ListeItem {
    @MainActor class ViewModel: ObservableObject {
        @Published  var alerteAffichée = false
        @Published  var itemEnCours: Item?
        @Published  var itemsEnCourDeSuppression: IndexSet? //SetIndex<Item>?
      }
    }
    
extension VueDetailItem {
    @MainActor class ViewModel: ObservableObject {
        init (_ unItem: Item) {
            item = unItem
            latitude = unItem.latitude
            longitude = unItem.longitude
        }
        
        @Published var latitude: Double
        @Published var longitude: Double
        @Published var item : Item
        @Published var feuilleModificationItemPresentée   = false
        }
    }

extension VueModifItem {
    @MainActor class ViewModel: ObservableObject {
        
        init (_ unItem: Item) { item = unItem }
        @Published var item : Item
        
        @Published var feuilleAffectationGroupesPresentée = false
        /// La région géographique entourant l'item en cours d'édition
        @Published  var régionItem = MKCoordinateRegion (
            center: CLLocationCoordinate2D (
                latitude: Lieu.exemple.latitude,
                longitude: Lieu.exemple.longitude),
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5)
            )
        /// Les lieux éditables (ici on en utilise qu'un seul)
        @Published  var locations = [Lieu]()
        /// Le lieu en cours d'édition
        @Published  var leLieuÉdité: Lieu?
        }
    }

extension VueModifItemTest {
    @MainActor class ViewModel: ObservableObject {
        
        init (_ unItem: Item) { item = unItem }
        @Published var item : Item
        
        @Published var feuilleAffectationGroupesPresentée = false
        /// La région géographique entourant l'item en cours d'édition
        @Published  var régionItem = MKCoordinateRegion (
            center: CLLocationCoordinate2D (
                latitude: Lieu.exemple.latitude,
                longitude: Lieu.exemple.longitude),
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5)
            )
        /// Les lieux éditables (ici on en utilise qu'un seul)
        @Published  var locations = [Lieu]()
        /// Le lieu en cours d'édition
        @Published  var leLieuÉdité: Lieu?
        }
    }

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

extension VueEditionCarte {
    @MainActor class ViewModel: ObservableObject {
        init (_ unItem: Item,
              sectionGéographique : MKCoordinateRegion,
              lesLieux : [Lieu],
              lieuEnCoursEdition : Lieu?
            ) {
            item = unItem
            self.sectionGéographique = sectionGéographique
            self.lesLieux = lesLieux
            self.lieuEnCoursEdition = lieuEnCoursEdition
        }
        
        @Published var item : Item
        
        @Published  var sectionGéographique : MKCoordinateRegion
        @Published  var lesLieux : [Lieu]
        @Published  var lieuEnCoursEdition : Lieu?

        }
    }

extension VueTestItem {
    @MainActor class ViewModel: ObservableObject {
//        init (_ unItem: Item) {
//            item = unItem
//            latitude = unItem.latitude
//            longitude = unItem.longitude
//        }
        
//        @Published var latitude: Double
//        @Published var longitude: Double
//        @Published var item : Item
        @Published var feuilleModificationItemPresentée   = false
        }
}

extension VueTestItemNew {
    @MainActor class ViewModel: ObservableObject {

        @Published var feuilleModificationItemPresentée   = false
        }
}
