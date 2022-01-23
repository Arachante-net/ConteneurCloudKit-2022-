//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import Foundation
import CoreData
import SwiftUI
import MapKit


#if os(iOS)
import UIKit
#endif
#if os(macOS)
import Foundation
#endif


//MARK: Les requêtes
extension Item {
    
    static var extractionItems: NSFetchRequest<Item> {
        let requette: NSFetchRequest<Item> = Item.fetchRequest()
            requette.sortDescriptors = [NSSortDescriptor(keyPath: \Item.titre, ascending: true)]
        return requette
        }
    
    static var extractionValides: NSFetchRequest<Item> {
           let requette: NSFetchRequest<Item> = Item.fetchRequest()
               requette.sortDescriptors = [NSSortDescriptor(keyPath: \Item.titre, ascending: true)]
               requette.predicate = NSPredicate(format: "valide == true")
        return requette
        }
    
    // https://academy.realm.io/posts/nspredicate-cheatsheet/
    static var extractionOrphelins: NSFetchRequest<Item> {
        let requette: NSFetchRequest<Item> = Item.fetchRequest()
            requette.sortDescriptors = [NSSortDescriptor(keyPath: \Item.titre, ascending: true)]
            requette.predicate = NSPredicate(format: "groupes.@count == 0")

//            requette.predicate = NSPredicate(format: "")

//            requette.predicate = NSPredicate(format: "groupes[SIZE] == 0")
            // "groupes == nil"
            // "groupes[SIZE] == 0"

        return requette
        }
    
    static var extractionIsolés: NSFetchRequest<Item> {
        let requette: NSFetchRequest<Item> = Item.fetchRequest()
            requette.sortDescriptors = [NSSortDescriptor(keyPath: \Item.titre, ascending: true)]
            requette.predicate = NSPredicate(format: "principal.@count == 0")

//            requette.predicate = NSPredicate(format: "")

//            requette.predicate = NSPredicate(format: "groupes[SIZE] == 0")
            // "groupes == nil"
            // "groupes[SIZE] == 0"

        return requette
        }
}



//MARK: Manipulation
extension Item {
    
    
//    static func vide() { Item() }
    
    static func bidon() -> Item {
        let nouvelItem = Item()
            nouvelItem.valide           = true
            nouvelItem.timestamp        = Date(timeIntervalSince1970:0)
            nouvelItem.titre            = "␀"
            nouvelItem.id               = UUID()
            nouvelItem.valeur           = 0
            nouvelItem.latitude         = 0
            nouvelItem.longitude        = 0
            nouvelItem.coloris          = .secondary // => couleur
            nouvelItem.createur         = "␀"
            nouvelItem.caracteristique  = "␀"
            nouvelItem.mode             = .bien
            nouvelItem.ordre            = 0
            nouvelItem.valeur           = 0
     return nouvelItem
        }
    
    /// Creer un nouvel Item et le sauver en coreData
    /// - Parameters:
    ///   - titre: de l'Item
    static func creer(contexte:NSManagedObjectContext , titre:String="⚡︎⚡︎⚡︎") {
        
        _ = fournirNouveau(contexte:contexte , titre:titre) // nouvelItem
//        persistance.sauverContexte("")
            //FIXME: ne sauver que s'il y a des trucs à sauver
            //FIXME: ? écrire ailleur  PERSITANCE
            //FIXME: meilleure gestion des erreurs
                        do {
                            contexte.name = "Item"
                            try contexte.save()
                            contexte.name = nil

                        } catch {
                            //TODO: Peut mieux faire
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
        }
    
    /// Fournir un Item prérempli, sans enregistrer le contexte
    /// - Parameters:
    ///   - contexte: <#contexte description#>
    ///   - titre: de l'Item
    /// - Returns: un Item
    static func fournirNouveau(contexte:NSManagedObjectContext , titre:String="N/A") -> Item {
        
        let nouvelItem = Item(context: contexte)
            nouvelItem.timestamp = Date()
            nouvelItem.titre     = titre
            nouvelItem.id        = UUID()
            nouvelItem.valeur    = 0
            nouvelItem.latitude  = Lieu.coordonnéesParDéfaut.latitude
            nouvelItem.longitude = Lieu.coordonnéesParDéfaut.longitude 
            nouvelItem.coloris   = .secondary // appel le 'setter' qui convertira Color en données binaires pour être stockées en CoreData
            nouvelItem.createur  = UserDefaults.standard.string(forKey: "UID") ?? "anonyme"
            nouvelItem.valide    = true
         return nouvelItem
        }

    
    /// Cet Item participera à  une communauté de  groupes collaboratifs existants
    /// - Parameters:
    ///   - contexte:
    ///   - communauté : un  ou plusieurs groupes collaboratifs
    func rallier(contexte:NSManagedObjectContext , communauté: Set<Groupe>) {
        
        guard // mes groupes actuels sont bien tous collaboratifs
            (lesGroupes.reduce(true) {$0 && $1.collaboratif} ) else {
                print("⚾︎ ERREUR un des groupes actuels de l'item", titre ?? "" ,"n'est pas collaboratif")
//                appError = ErrorType(error: .trucQuiVaPas(num: 666))
                lesGroupes.forEach { print("⚾︎", $0.nom ?? "..." , $0.collaboratif) }
                return
                }
        
        guard // Les groupes que je veux rejoindre sont bien tous collaboratifs
            ( communauté.reduce(true) {$0 && $1.collaboratif} ) else {
            
                print("⚾︎ ERREUR un des groupes visés n'est pas collaboratif")
//                appError = ErrorType(error: .trucQuiVaPas(num: 666))
                communauté.forEach { print("⚾︎", $0.nom ?? "..." , $0.collaboratif) }
                return
                }
        
        self.groupes = (self.groupes as! Set<Groupe>).union(communauté) as NSSet
        communauté.forEach {nouveauGroupe in
            print ("⚾︎ Traitement groupe", nouveauGroupe.nom ?? "...")
            var lesGroupesDeLaNouvelleRecrue = nouveauGroupe.items as! Set<Item>
            let (inséré,  aprèsInsertion) = lesGroupesDeLaNouvelleRecrue.insert(self)
            print("⚾︎ Inséré :" , inséré,
                  "après :"  , aprèsInsertion,
                  "les"      , lesGroupesDeLaNouvelleRecrue.count,
                  "groupes :", lesGroupesDeLaNouvelleRecrue)
            }
        }
    
    func charger() -> (titre:String, valeur:Int, ordre:Int) {
        (titre: titre ?? "", valeur: Int(valeur), ordre: Int(ordre) )
    }
    
    
    
    }

extension Item {
    
    typealias Point = (Int, Int)
    
    typealias Memoire = ItemMemoire
    
    func mémoriser() -> Memoire {
        Memoire(titre: titre ?? "", valeur: Int(valeur), longitude: longitude, latitude:latitude)
    }
    
}

////
//MARK: Adaptation et proprietées supplementaires
extension Item {
    
    /// Pour le Fun
    var signature: String      { return "arach" }
    
//    var vide: <# Type #> {
//        Item()
//        }

    public override var description: String {
//        let tg = Array(groupes
//        let g = lesGroupes.map {$0.nom ?? "..."}.joined(separator: ",")
//        let lg = g.joined(separator: ",") //reduce("Groupes : ", { $0 ?? "" + $1 ?? "" })
//        let lg = groupes?.reduce("G ", {$0 + $1})
        "\(leTitre),  Valeur: \(valeur), Principal: \(principal?.leNom ?? ""), Membre de : \(lesGroupes.map {$0.nom ?? "..."}.joined(separator: ","))."
//        return ""
    }
    
    /// Fourni une valeur par defaut facilement identifiable (1 janvier 1970) si  Item.timestamp n'est pas défini
    var horodatage : Date {
        get { timestamp ?? Date(timeIntervalSince1970:0) }
        }
    
    var leTitre:String {
        get {titre ?? "␀"}
        set {titre = newValue}
        }
    
    private struct Couleur: Codable {
      var rouge: Double
      var vert:  Double
      var bleu:  Double
      var alpha: Double
      }
    
    /// Encode une couleur  independante  de l'origine iOS ou macOS
    var coloris: Color {
      get {
        guard let donnéesBinaires = couleur,
              let décodé = try? JSONDecoder().decode(Couleur.self, from: donnéesBinaires)
          else { return Color.accentColor } //(assetName: .accentColor) }
        return Color(.sRGB, red: décodé.rouge, green: décodé.vert, blue: décodé.bleu, opacity: décodé.alpha)
        }
        
      set(nouvelleCouleur) {
        #if os(iOS)
        let couleurNativeOS = UIColor(nouvelleCouleur)
        #elseif os(macOS)
        let couleurNativeOS = NSColor(nouvelleCouleur)
        #endif
        var (r, v, b, a) = (CGFloat.zero, CGFloat.zero, CGFloat.zero, CGFloat.zero)
        couleurNativeOS.getRed(&r, green: &v, blue: &b, alpha: &a)
        if let encodée = try? JSONEncoder().encode(Couleur(rouge: Double(r), vert: Double(v), bleu: Double(b), alpha: Double(a))) {
          couleur = encodée
          }
      }
    
        
    }



    
    
    
    
    enum Mode: String { case content, bien, triste }
    
    var mode:Mode {
        get {Mode(rawValue: modeBin ?? "bien") ?? .bien}
        set {modeBin = newValue.rawValue}
        }
    
    
    /// Convertion  de .groupes:NSSet? en .lesGroupes:Set<Groupe>
    var lesGroupes:Set<Groupe> {
        get { return groupes as? Set<Groupe> ?? [] }
        set {
            print("CHANGEMENT DES GROUPES", newValue.count)
            groupes = newValue as NSSet
            }
    }
    
    /// Convertir Set<Groupe> en NSSet
    func grouper(   groupes : Set<Groupe>) { self.groupes = groupes as NSSet }
    
    var coordonnées:CLLocationCoordinate2D {
        get {CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)}
        set {
            latitude  = newValue.latitude
            longitude = newValue.longitude
            }
        }
    
    // Un lieu (Lat, Long) et quelques infos descriptions complementaires
    var annotationGeographiques:AnnotationGeographique {
        get {
            
        #if os(iOS)
            let coul = UIColor(self.coloris)
        #elseif os(macOS)
            let coul = NSColor(self.coloris)
        #endif
            return AnnotationGeographique( // id = UUID(),
                libellé:  self.titre ?? "␀",
                coordonnées : self.coordonnées, //: CLLocationCoordinate2D
                couleur : coul
               )
            }
        }
    
    
    // Pas utilisé
    var lieu_:Lieu {
        get {
            
        #if os(iOS)
            let coul = UIColor(self.coloris)
        #elseif os(macOS)
            let coul = NSColor(self.coloris)
        #endif
            return Lieu(
//                id: UUID(),
//                libellé: self.titre ?? "␀",
//                description: "␀",
                latitude: self.latitude,
                longitude: self.longitude
//                coordonnées : self.coordonnées //: CLLocationCoordinate2D
//                couleur : coul
                )
            }
        }
    
//    var spanDefaut : MKCoordinateSpan {
//        MKCoordinateSpan(
//            latitudeDelta:  0.5,
//            longitudeDelta: 0.5)
//        }
    
    /// Coordonnées d'un Item et étendue géographique à considerer
    var région : MKCoordinateRegion {
        get {
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude:  latitude ,
                    longitude: longitude),
                span : Lieu.étendueParDéfaut)
            }
        set {
            latitude  = newValue.center.latitude
            longitude = newValue.center.longitude
//            (latitude, longitude) = pointer(newValue.center)
            }
        }
        
    /// Définir les coordonnées de l'Item en fonction du centre de la Région cartographique
    func centrerSurLaRégion() {
//      longitude = région.center.longitude
//      latitude  = région.center.latitude
        (latitude, longitude) = centrerSur(région)
      }
    
    /// Centrer la Région géographique sur les coordonnées de l'Item
    func centrerSur(_ région: MKCoordinateRegion ) -> (latitude:Double, longitude:Double) {
       (latitude: région.center.latitude, longitude: région.center.longitude)
      }
    
    /// Fournir  les coordonnées en argument sous forme de tuple
    func pointer(_ point: CLLocationCoordinate2D ) -> (latitude:Double, longitude:Double) {
       (latitude: point.latitude, longitude: point.longitude)
      }
    
   // func coordonnées
    override public func prepareForDeletion() {
//        super.prepareForDeletion()
        print("🔘 Suppresion imminente de l'item ", titre ?? "␀",
              "délégué du groupe", principal?.nom ?? "␀",
              "membre de", groupes?.count ?? 0, "autres groupes")
        }

}


//MARK: - Pour Tests -
extension Item {
    func verifierCohérence(depuis:String="␀" ) -> [ErrorType]   {
        var lesErreurs = [ErrorType]()
        print("☑️ Cohérence de l'item", titre ?? "␀" , ", depuis" , depuis, terminator: " :")

//        if (titre == nil || ((titre?.isEmpty) != nil) || titre == "")
        if (titre == nil || titre!.isEmpty || titre == "")
            {lesErreurs.append(ErrorType(.itemSansTitre ))}
        
        if (id == nil )
            { lesErreurs.append(ErrorType(.itemSansID )) }
        if principal == nil
            { lesErreurs.append(ErrorType(.itemSansPrincipal ))}
        
        if lesErreurs.isEmpty {print(" ✅")}
        else {
            print("")
            lesErreurs.forEach() {print("☑️❌" , $0.error.localizedDescription)}}
        
        return lesErreurs
        }
    }








struct ItemMemoire {
    var titre:String
    var valeur:Int
    var longitude:Double
    var latitude:Double
    }
