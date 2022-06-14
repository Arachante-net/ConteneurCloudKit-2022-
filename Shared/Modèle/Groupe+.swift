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
import os.log



//MARK: - Requêtes -
/// Coin, coin
extension Groupe {
    static var signature:String { "Arachante" }
    
    /// Fournir un groupe prérempli sans contexte
    /// - Parameters:
    ///   - nom: du groupe
    /// - Returns: un Groupe
//    static func fournir(nom:String="␀") -> Groupe {
//        let contexteDeTest = NSManagedObjectContext(.mainQueue)
//
//        let    nouveauGroupe = Groupe(context: contexteDeTest)
//        print("OOO XXX")
//               nouveauGroupe.id = UUID()
//               nouveauGroupe.nom = nom
//        print("OOO XXX", nouveauGroupe.nom ?? "...")
//               nouveauGroupe.createur = "testeur"
//               nouveauGroupe.collaboratif = false
//               nouveauGroupe.valide = true
////        let t = nouveauGroupe.managedObjectContext // NSManagedObjectContext?
//        return nouveauGroupe
//       }
    }

extension Groupe {
    
    //MARK: Critères d'extraction depuis le stockage permanent -

    static var extractionGroupes: NSFetchRequest<Groupe> {
      let request: NSFetchRequest<Groupe> = Groupe.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \Groupe.nom, ascending: true)]
      return request
      }
    
    static var extractionCollaboratifs: NSFetchRequest<Groupe> {
        let requette: NSFetchRequest<Groupe> = Groupe.fetchRequest()
            requette.sortDescriptors = [NSSortDescriptor(keyPath: \Groupe.nom, ascending: true)]
            requette.predicate = NSPredicate(format: "collaboratif == true")
        return requette
        }
    
    static public func obtenirGroupes(contexte:NSManagedObjectContext) -> [Groupe]? {
      let requête: NSFetchRequest<Groupe> = Groupe.fetchRequest()
      do {
          let results = try contexte.fetch(requête) //managedObjectContext?.fetch(requête)
        return results
      } catch let error as NSError {
        print("Fetch error: \(error) description: \(error.userInfo)")
      }
      return nil
    }
}


//MARK: - Cycle de vie -
extension Groupe {

    
    /// Fournir un groupe prérempli sans sauver le contexte
    /// - Parameters:
    ///   - contexte:
    ///   - nom: du groupe
    /// - Returns: un Groupe
    static func fournirNouveau(contexte:NSManagedObjectContext , nom:String="␀") -> Groupe {
        
        let    nouveauGroupe = Groupe(context: contexte)
               nouveauGroupe.id = UUID()
               nouveauGroupe.nom = nom
               nouveauGroupe.createur = UserDefaults.standard.string(forKey: "UID") ?? "anonyme"
               nouveauGroupe.collaboratif = false
               nouveauGroupe.valide = true
        return nouveauGroupe
       }
    
    static func exemple(contexte:NSManagedObjectContext) -> Groupe {
        Logger.modélisationDonnées.info("💢\(#function)")
        let nouveauGroupe = fournirNouveau(contexte:contexte) // nouvelItem
//        let nouvelItem = Item.exemple(contexte:contexte) // nouvelItem

//        let nouvelItem = Item()
            nouveauGroupe.icone            = "rectangle"
            nouveauGroupe.nom              = "Exemple de groupe"
            nouveauGroupe.objectif         = "Voyage avec notre vaisseau spatial dans l'Espace, cette frontière de l'infini. Notre mission de cinq ans : explorer de nouveaux mondes étranges, découvrir de nouvelles vies, d'autres civilisations, et au mépris du danger avancer vers l'inconnu..."
            nouveauGroupe.id               = UUID()
            nouveauGroupe.ordre            = 0
            nouveauGroupe.valide           = true
//            nouveauGroupe.principal        = nouvelItem
     return nouveauGroupe
        }

    /// Création d'un nouveau couple Groupe/Item
    /// - Parameters:
    ///   - titre: du groupe et du premier Item
    ///   - collaboratif: ou individuel par défaut
    @discardableResult
    static func creer(contexte:NSManagedObjectContext , titre:String="⚡︎⚡︎⚡︎", collaboratif:Bool=false) -> Groupe {
        // Créer un Groupe
        let nouveauGroupe = fournirNouveau(contexte: contexte, nom:titre)
            nouveauGroupe.collaboratif = collaboratif
//            nouveauGroupe.createur = UserDefaults.standard.string(forKey: "UID") ?? "anonyme"
//            nouveauGroupe.valide = true
        
        // Créer l'Item principal
        let nouvelItem    = Item.fournirNouveau(
            contexte: contexte ,
            titre: "\(titre)_\(nouveauGroupe.items?.count ?? 0)"   )
            
        nouvelItem.principal    = nouveauGroupe
        nouveauGroupe.principal = nouvelItem

        // sauver le contexte
        // persistance
//        persistance.sauverContexte(nom:"Groupe")
//        print("♻️")
        Logger.modélisationDonnées.info("💰")
        do {
            contexte.name = "Groupe"
            try contexte.save()
            contexte.name = nil

//            try persistance.sauverContexte()
//            contexte.transactionAuthor = nil
            }
        catch {
            //TODO: Peut mieux faire
            let nsError = error as NSError
            if nsError.code == 0,
                  nsError.domain == "Foundation._GenericObjCError" {
                  print("Erreur invalide depuis Objective-C ?")
              }
              else {
                  fatalError("Erreur lors du '.save' du contexte \(nsError),\t \(nsError.userInfo) ! \(contexte.debugDescription) !!")
                }
            }
        return nouveauGroupe
        }


    /// Créer un nouvel Item et le faire participer  à ce groupe collaboratif
    /// - Parameters:
    ///   - contexte: <#contexte description#>
    ///   - titre: de l'item
    func enrôler(contexte:NSManagedObjectContext , titre:String) {
        guard self.collaboratif else {
//            appError = ErrorType(error: .trucQuiVaPas(num: 666))
            Logger.modélisationDonnées.error("ERREUR le groupe \(self.leNom) n'est pas collaboratif")
            return
            }
        let nouvelItem = Item.fournirNouveau(
            contexte: contexte ,
            titre: "\(self.nom!) \(items?.count ?? 0) \(titre)"   )
        
        //nouvelItem.principal=self   /////////////////////// 13 juin 2022
        
        nouvelItem.addToGroupes(self)
        self.addToItems(nouvelItem)

        // sauver le contexte
//        persistance.sauverContexte(nom:"Groupe")
        Logger.modélisationDonnées.info("💰")
        do {
            contexte.name = "Groupe"
            try contexte.save()
            contexte.name = nil
            }
        catch {
            //TODO: Peut mieux faire
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }


    /// Ce groupe incluera un  ou plusieurs items  existants
    /// - Parameters:
    ///   - contexte:
    func enrôler(contexte:NSManagedObjectContext , recrues: Set<Item>) {
        guard self.collaboratif else {
            Logger.modélisationDonnées.info("Le groupe \(self.leNom) n'est pas collaboratif.")
            return
            }

        self.items = (self.items as! Set<Item>).union(recrues) as NSSet
        recrues.forEach {nouvelleRecrue in
            Logger.modélisationDonnées.info ("⚾︎ Enrôler \(nouvelleRecrue.leTitre) ...")
            var lesGroupesDeLaNouvelleRecrue = nouvelleRecrue.groupes as! Set<Groupe>
            let (inséré,  aprèsInsertion) = lesGroupesDeLaNouvelleRecrue.insert(self)
            Logger.modélisationDonnées.info("⚾︎ Inséré : \(inséré) après : \(aprèsInsertion) les \(lesGroupesDeLaNouvelleRecrue.count) groupes : \(lesGroupesDeLaNouvelleRecrue) ")
            }
        }
//    
//    public enum modeSuppression {
//        /// Comportement par défaut
//        case défaut
//        /// Suppression uniquement du groupe sans réfléchir
//        case brut
//        /// Suppression du groupe et de son item Principal
//        case avecPrincipal
//        /// Informer collaborateurs et autres parties prenantes
//        case informer
//        ///  supprimer (quoi ?) sans demander l'avis des parties prenantes
//        case forcer
//        /// Faire seulement semblant
//        case simulation
//        }
    
    func demanderAccordSuppression() {
        Logger.modélisationDonnées.info("\t🔘accord de suppression pour : \(self.leNom)")
        }
    
    func notifierDemission(_ groupe:Groupe, mode: Suppression) {
        Logger.modélisationDonnées.info("\t🔘 Le groupe \(self.leNom) recoit une notification ( \(mode.hashValue) de la démission de : \(groupe.leNom)")
        }
    
    func notifierAbdication(_ groupe:Groupe, mode: Suppression) {
        Logger.modélisationDonnées.info("\t🔘 Le groupe \(self.leNom) recoit une notification ( \(mode.hashValue) de l'abdication de : \(groupe.leNom)")
        }
    
    func supprimerAdhérences(mode: Suppression = .simulation) {
        
        switch mode {
            case .brut:
                // Enlever de son item principal la reference a ce groupe
                removeFromItems(lePrincipal)
                // Enlever aussi la referene, de la listes des items qui collaborent
                if items != nil {removeFromItems(items!)}
//                persistance.supprimerObjets(self)  // NON CAR UNIQUEMENT LES ADHERENCES
            case .avecPrincipal, .défaut:
                Logger.modélisationDonnées.info("P: \(self.lePrincipal)")
                lePrincipal.notifierDemission(self, mode: mode)
            case .informer:
                Logger.modélisationDonnées.info("? \(self.collaborateurs)")
                collaborateurs.forEach() {$0.demanderAccordSuppression()}
            case .forcer:
                Logger.modélisationDonnées.info("! \(self.collaborateurs)")
                collaborateurs.forEach() {$0.demanderAccordSuppression()}
            case .simulation:
//                print("🔘Les colaborateurs de", leNom, "sont :", collaborateurs.map {$0.leNom}.joined(separator: ", ") )
                collaborateurs.forEach() {$0.notifierAbdication(self, mode: mode)}
//                print("🔘L'item principal de", leNom, "est :", lePrincipal.leTitre)
                lePrincipal.notifierDemission(self, mode: mode)
//                print("🔘", leNom, "Démissione des groupes :", lePrincipal.lesGroupes.map {$0.nom ?? "..."}.joined(separator: ", "), "auxquels il participe.")
                lePrincipal.lesGroupes.forEach() {$0.notifierDemission(self, mode: mode)}
        }
    }
    

    
    static func supprimerAdhérences(groupes: [Groupe], mode: Suppression = .simulation) {
        Logger.modélisationDonnées.info("🔘 Suppression adhérences (\(mode.hashValue)) de : \(groupes.map {$0.leNom}) ") //positions.map { groupes[$0].leNom} )
        
        groupes.forEach { leGroupe in
            Logger.modélisationDonnées.info("\t🔘 Suppression (\(mode.hashValue)) des adhérences du groupe : \(leGroupe.leNom)") //groupes[$0].leNom )
            leGroupe.supprimerAdhérences(mode: mode) //mode: .brut)
    //        persistance.sauverContexte()
            }

        }
    
    override public func prepareForDeletion() {
        super.prepareForDeletion()
        Logger.modélisationDonnées.info("🔘 Suppresion imminente du groupe \(self.leNom), maitre de l'item principal \(self.lePrincipal.leTitre) et de \(self.lesItems.count) autres items.")
        }

    static public func supprimer(contexte:NSManagedObjectContext , _ groupe: Groupe) {
        contexte.delete(groupe)
//      coreDataStack.saveContext(managedObjectContext)
//        persistance.sauverContexte(nom:"Groupe")

        do {
            contexte.name = "Groupe"
            try contexte.save()
            contexte.name = nil

//            try persistance.sauverContexte()
//            contexte.transactionAuthor = nil
            }
        catch {
            //TODO: Peut mieux faire
            let nsError = error as NSError
            if nsError.code == 0,
                  nsError.domain == "Foundation._GenericObjCError" {
                  print("Erreur invalide depuis Objective-C ?")
              }
              else {
                  fatalError("Erreur lors du '.save' du contexte apres une suppression \(nsError),\t \(nsError.userInfo) ! \(contexte.debugDescription) !!")
                }
            }
        
        
    }
    
   }



//MARK: - Propriétés -

extension Groupe {
    
    var vide:Groupe {
        Groupe()
        }
    
    // principal: Item?
    var lePrincipal:Item  {
        get  {
            if principal != nil { return principal! }
            else {
                // plutot generer une erreur ?
                // appError = ErrorType(error: .groupeSansPrincipal)
                // throw Nimbus.groupeSansPrincipal
                // donc la suite n'est pas executée

//                fatalError("🔴 ERREUR le principal de \( nom ?? "") n'existe pas !!") ////
//              print("🔴 ERREUR le principal de", nom ?? "" , "n'existe pas !!")
                Logger.modélisationDonnées.error("💢 Le principal de \(self.leNom) n'existe pas !!")
                return Item.bidon(contexte: NSManagedObjectContext() )
                }
            }
        }
    
    /// Convertir .items:NSSet? en .lesItems:Set<Item> et reciproquement
    var lesItems:Set<Item> {
        get {return items as? Set<Item> ?? []}
        set {items =  newValue as NSSet } //FIXME: DANGEREUX set lesItems fait boucler collaborateursSansLePrincipal_ !?

        //adding(newValue)
    }
    
    /// Pas utilisé
    var tableauItemsTrié: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted {
            $0.leTitre < $1.leTitre
            }
        }
    
    /// Le nom  non optionel du groupe
    var leNom:String {
        get {nom ?? "␀"}
        set {nom = newValue}
        }
    
    /// L'objectif non optionel du groupe
    var lObjectif:String {
        get {objectif ?? "␀"}
        set {objectif = newValue}
        }
    
    /// L'icône non optionel du groupe
    var lIcone:String {
        get {icone ?? "rectangle"}
        set {icone = newValue}
        }
    
    var image:Image { Image(systemName: lIcone) }
    
    /// La valeur d'un groupe, c'est la somme (Int) des valeurs (Int64) de ses participants
    var valeur:Int { Int(
        (items as? Set<Item>)? .reduce(principal?.valeur ?? 0) {$0 + $1.valeur} ?? 0)
        }
    
//    /// Le message d'un groupe, c'est le dernier message de ses participants
//    var message:String { String(
//        (items as? Set<Item>)? .reduce(principal?.leMessage) {$0.timestamp >  $1.timestamp  ? $0.leMessage : $1.leMessage}
//        ) }
    
/// Le message d'un groupe, c'est le dernier message de ses participants
/// pour l'intant c'est plutot ,le message du dernier créé (c'est pas pareil)
var message:String {
//    print("📶")
    var messagesTriés = items?.allObjects as? Array<Item> ?? []
    
    messagesTriés.append(lePrincipal)
//    print("📶", messagesTriés.map{"\($0.leTitre) \($0.horodatage)"})
    messagesTriés.sort { (gauche:Item, droite:Item) in
//        return gauche.timestamp?.timeIntervalSince1970 ?? 0 < droite.timestamp?.timeIntervalSince1970 ?? 0
//        return
        gauche.horodatage < droite.horodatage
        }
//    print("📶")
//    print("📶", messagesTriés.map{"\($0.leTitre) \($0.horodatage)"} , "      ", messagesTriés.last?.horodatage ?? "...")
    return messagesTriés.last?.leMessage ?? "..."
    }
    
    
    
    /// La valeur de l'Item Principal de ce groupe
    var valeurPrincipale: Int {
        get { Int(principal?.valeur ?? 0) }
        set { principal?.valeur = Int64(newValue) }
        }
    
    /// Vrai si l'ensemble des groupes sont collaboratifs
    static func tousCollaboratifs(_ lesGroupes: Set<Groupe> ) -> Bool {
        lesGroupes.reduce(true) {$0 && $1.collaboratif}
        }
    
    /// Liste des groupes en adhérence
    func collaborateurs_() -> Set<Groupe> {
        guard items?.count ?? 0 > 0 else { return Set<Groupe>() }
        return Set( ((items as? Set<Item>)?.map {$0.principal!})! )
        }
    
    /// L'ensemble des groupes  principaux des Items liés à ce Groupe
    var collaborateurs : Set<Groupe> {
        guard items?.count ?? 0 > 0 else { return Set<Groupe>() }
        return Set( ((items as? Set<Item>)?.map {$0.principal!})! )
        }
    
    var collaborateursSansLePrincipal__ : Set<Groupe> {
        guard items?.count ?? 0 > 0 else { return Set<Groupe>() }
        
        lesItems.remove(lePrincipal)
        return Set( ((items as? Set<Item>)?.map {
            if let pr = $0.principal {
                // Si l'item a un groupe principal, on l'inclu
                return pr}
            else {
                // Sinon on retourne un groupe vide
                Logger.modélisationDonnées.error("ERREUR sur Item \($0.leTitre)")
                return Groupe()}
                })! )
        }
    
    var collaborateursSansLePrincipal : Set<Groupe> {
        // Garantir qu'il y a des iems sinon retourner un ensemble vide
        guard items?.count ?? 0 > 0 else { return Set<Groupe>() }
        
        //MARK: DANGER set lesItems fait boucler (lesItems.remove ça plante)
        //TODO: donc à corriger (probablement écrire le remove)
        // en attendant on doit passer par une variable temporaire intermédiaire
        var tmp = lesItems
        
        // Enlever ce groupe du résultat, cela ne devrait pas arriver !
        tmp.remove(self.lePrincipal)
        
        // Convertir les items en un ensemble de Groupes principaux
        let résultatGroupes = Set(tmp.compactMap { $0.principal  })
            
        return résultatGroupes
        }

    
    var groupesAuxquelsJeParticipe: Set<Groupe> {
        // Garantir que j'ai des maîtres sinon retourner un ensemble vide
        guard (principal != nil) else { return Set<Groupe>() }
        guard principal!.groupes?.count ?? 0 > 0 else { return Set<Groupe>() }
        let mesChefs = principal?.groupes
        let set = mesChefs as! Set<Groupe>
        Logger.modélisationDonnées.info("Mes \(set.count) chefs : \(set.map() {$0.leNom})")
        return set
    }
    
    
    func estMonPrincipal(groupe:Groupe) -> Bool {
        groupe.lePrincipal == self.lePrincipal
        }
    
    //MARK: Service Ressources Humaines
    // Manipulation du double lien entre Groupes collaborateurs
    //  1️⃣ De ma liste d'items vers l'item principal de l'autre        et
    //  2️⃣ De la liste de groupes de l'item principal de l'autre vers moi
    
    /// Recruter un autre `Groupe`,  c'est à dire recruter l'`Item Principal` de ce `Groupe`
    /// - Ajouter la recrue a ma liste et  m'ajouter a la liste de la recrue
    func enrôler(recrue:Groupe) {
        Logger.modélisationDonnées.info("\(self.leNom) enrôle la recrue \(recrue.leNom)")
//        guard recrue.principal != nil else {return}
        guard let recruePrincipal = recrue.principal else {return}

        // Ajouter à ma liste d'Items, l'Item Principal de la recrue
        self.lesItems.insert(recruePrincipal)
        // M'ajouter aux groupes de l'Item Principal de la recrue
        recruePrincipal.lesGroupes.insert(self)
        }
    
    
    /// Révoquer un `Groupe` recruté, c'est à dire révoquer l'`Item Principal` de ce `Groupe`
    /// - Enlever la recrue de ma liste  et m'enlever de la liste de la recrue
    func révoquer(recrue:Groupe) {
        Logger.modélisationDonnées.info("\(self.leNom) révoque la recrue \(recrue.leNom)")
        // Enlever l'Item Principal de la recrue, de ma liste d'Items.
        self.lesItems.remove(recrue.principal!)
        // M'enlever des groupes de l'Item Principal de la recrue
        recrue.principal?.lesGroupes.remove(self)
        }
    
    /// Rejoindre et collaborer à un  `Groupe` leader, c'est à dire que mon  `Item Principal` participera  au Groupe leader
    /// - M'ajouter a la liste des groupes du leader et  ajouter le leader à la liste de mes groupes
    func rallier(groupeLeader:Groupe) {
        Logger.modélisationDonnées.info("\(self.leNom) se rallie à \(groupeLeader.leNom)")

        guard principal != nil else {return}
        // Ajouter mon item principal à l'ensemble d'item du groupe leader
        groupeLeader.lesItems.insert(self.principal!) // ou lePrincipal)
        // Ajouter le groupe leader à l'ensemble de groupes auquels mon item principal participe
        self.principal!.lesGroupes.insert(groupeLeader)
        }
        
    /// - M'enlever de la liste  des participants du groupe leader et  enlever le groupe leader des groupes auxquels je participe
    func démissionner(groupeLeader:Groupe) {
        Logger.modélisationDonnées.info("\(self.leNom) démissione de \(groupeLeader.leNom)")

        guard principal != nil else {return}
        // Elever mon item principal de l'ensemble d'item du groupe leader
        groupeLeader.lesItems.remove(self.principal!)
//        groupeLeader.removeFromItems(self.principal!)

        // Enlever le groupe leader de l'ensemble de groupes auquels mon item principal participe
        self.principal!.lesGroupes.remove(groupeLeader)
//        groupeLeader.removeFromItems(self.principal!.items)
        }

    /*
     Groupe
        addToItems(     _ value:  Item )
        removeFromItems(_ value:  Item )
        addToItems(     _ values: NSSet)
        removeFromItems(_ values: NSSet)
     
     Item
        addToGroupes(     _ value: Groupe)
        removeFromGroupes(_ value: Groupe)
        addToGroupes(     _ values: NSSet)
        removeFromGroupes(_ values: NSSet)
     */
    
    
    //MARK: Géographie
    
    /// Le tableau des coordonnées des Items liés à ce groupe
    var lesCoordonnées:[CLLocationCoordinate2D] {
        lesItems.map {$0.coordonnées}
        }
    
    var régionEnglobante_: MKCoordinateRegion {
        set {} //self.régionEnglobante_ = newValue}
        get {MKCoordinateRegion()}
    }
    
    /// La région géographique qui  englobe  l'ensemble des Items du Groupe
    var régionEnglobante: MKCoordinateRegion  {

        get {
            Logger.modélisationDonnées.info("régionEnglobante ###### GET")
            var toutesLesCoordonnées = lesCoordonnées
            if let lePrincipal = principal?.coordonnées {
                Logger.modélisationDonnées.info("régionEnglobante (\(toutesLesCoordonnées.count)), on ajoute les coordonnées du Principal")
                toutesLesCoordonnées.append(lePrincipal)
                Logger.modélisationDonnées.info("régionEnglobante (\(toutesLesCoordonnées.count))")
                }
                    
            // Aucun point : on affiche le monde
            if toutesLesCoordonnées.isEmpty {
                Logger.modélisationDonnées.info("régionEnglobante (vide : \(toutesLesCoordonnées.count)) retourne (0,0)")
                return  MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude:  0,
                            longitude: 0),
                        span: Lieu.étendueMax
                        )
                }
            
            // Un seul point (normalement le Principal)
            if toutesLesCoordonnées.count == 1 {
                Logger.modélisationDonnées.info("régionEnglobante (un seul point : \(toutesLesCoordonnées.count)) retourne ce point ou (0,0)")
                return  MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude:  toutesLesCoordonnées.first?.latitude  ?? 0,
                        longitude: toutesLesCoordonnées.first?.longitude ?? 0),
                    span: Lieu.étendueParDéfaut
                    )
                }
            
            // Sinon on fait un peu de trigonométrie
            Logger.modélisationDonnées.info("régionEnglobante on calcule sur \(toutesLesCoordonnées.count) points ==")
            return MKCoordinateRegion.englobante(lesCoordonnées: toutesLesCoordonnées)
            }
        set {
            Logger.modélisationDonnées.info("régionEnglobante ###### SET")
            régionEnglobante_ = newValue}
        
        }
        //MARK: Géographie
        /// En entrée toutesLesCoordonnées    : [CLLocationCoordinate2D]
        /// En sortie la région: MKCoordinateRegion  englobant toutesLesCoordonnées
        //TODO: Certainement à déplacer (vers Lieu)
        
#warning("Attention ...    ")
//#error("Erreur ! ")
    
    
    /// Regroupe les descriptions des lieux des membres du groupe (sans celle du principal)
    var lesAnnotations_:[AnnotationGeographique] {
        lesItems.map {$0.annotationGeographiques}
        }
    
    /// Regroupe les descriptions des lieux des membres du groupe
    /// ET celle de l'item principal du groupe
    var lesAnnotations:[AnnotationGeographique] {
        var toutesLesAnnotations:[AnnotationGeographique]
        
        if let lePrincipal:AnnotationGeographique = principal?.annotationGeographiques {
            toutesLesAnnotations = [lePrincipal]
            toutesLesAnnotations.append(contentsOf: lesAnnotations_)
            }
        else {
            
            toutesLesAnnotations = lesAnnotations_
            }
        Logger.modélisationDonnées.info ("Nous avons \(toutesLesAnnotations.count) annotations")
        return toutesLesAnnotations
        }

    /// Vrai si ce Groupe est contenu dans l'ensemble des Groupes en argument
    func estContenu(dans groupes : Set<Groupe>) -> Bool { groupes.contains(self)}
    
    

    
    

    
}
    
    


//MARK: - Pour Tests -
    
extension Groupe {

    var estCoherent:Bool {verifierCohérence(depuis: "Propriété estCoherent Groupe").isEmpty}
    
    func verifierCohérence(depuis:String="␀" ) -> [ErrorType]   {
        var lesErreurs = [ErrorType]()
        Logger.modélisationDonnées.info("☑️ Cohérence du groupe \(self.leNom), depuis \(depuis) ")  //, terminator: " :")
        
        if !valide
            {lesErreurs.append(ErrorType(.groupeInvalide ))}
        
        if (nom == nil || nom!.isEmpty || nom == "")
            {lesErreurs.append(ErrorType(.groupeSansNom ))}
        
        if (id == nil )
            { lesErreurs.append(ErrorType(.groupeSansID )) }
        
        if isFault { lesErreurs.append(ErrorType(.objetCoreDataenDéfaut)) }
        
        
        if principal == nil
            { lesErreurs.append(ErrorType(.groupeSansPrincipal )) }
        
        else {
            if self != principal?.principal
                // Le lien double entre principaux
                { lesErreurs.append(ErrorType(.incoherenceDesPrincipaux ))}
            
            // Ajouter les incoherences de l'Item Principal
            lesErreurs.append(contentsOf: principal?.verifierCohérence(depuis:depuis) ?? [])
            
            if principal!.isFault { lesErreurs.append(ErrorType(.objetCoreDataenDéfaut)) }

            }
        
        // Ajouter les incoherences des Items liés à ce Groupe
        lesErreurs.append(contentsOf: lesItems.flatMap{$0.verifierCohérence(depuis : (depuis + "les items") )})
                
        return lesErreurs
        }
    
    
    public override var description: String {
        "\(leNom), valeur: \(valeur), collaborateurs : \(lesItems.map {$0.principal?.leNom as! String}.joined(separator: ", "))."
      }
    
//    override public var debugDescription: String {
//        ""
//       }
     func identifiant() -> NSManagedObjectID {
         print("objectID", self.value(forKey: "nom") ,
               self.primitiveValue(forKey: "modifiedAt"),
               "----",
               self.primitiveValue(forKey: "entityName"), //createdAt"),
               self.primitiveValue(forKey: "entitiNom"),
               "----",
               self.objectID.persistentStore?.url, self.entity)
         return  self.objectID
         }
    }





//extension Groupe {
//
//    static public func obtenirGroupes(contexte:NSManagedObjectContext) -> [Groupe]? {
//      let requête: NSFetchRequest<Groupe> = Groupe.fetchRequest()
//      do {
//          let results = try contexte.fetch(requête) //managedObjectContext?.fetch(requête)
//        return results
//      } catch let error as NSError {
//        print("Fetch error: \(error) description: \(error.userInfo)")
//      }
//      return nil
//    }
//}
