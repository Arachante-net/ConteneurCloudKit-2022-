//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import Foundation
import CoreData
import MapKit



//MARK: - Requêtes -
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
}


//MARK: - Manipulation -
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

    /// Création d'un nouveau couple Groupe/Item
    /// - Parameters:
    ///   - titre: du groupe et du premier Item
    ///   - collaboratif: ou individuel par défaut
    static func creer(contexte:NSManagedObjectContext , titre:String="⚡︎⚡︎⚡︎", collaboratif:Bool=false) {
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
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }


    /// Créer un nouvel Item et le faire participer  à ce groupe collaboratif
    /// - Parameters:
    ///   - contexte: <#contexte description#>
    ///   - titre: de l'item
    func enrôler(contexte:NSManagedObjectContext , titre:String) {
        guard self.collaboratif else {
//            appError = ErrorType(error: .trucQuiVaPas(num: 666))
            print("ERREUR le groupe", self.nom ?? "?" , "n'est pas collaboratif")
            return
            }
        let nouvelItem = Item.fournirNouveau(
            contexte: contexte ,
            titre: "\(self.nom!) \(items?.count ?? 0) \(titre)"   )
        
        nouvelItem.addToGroupes(self)
        self.addToItems(nouvelItem)

        // sauver le contexte
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
            print("Le groupe", self.nom ?? "" , "n'est pas collaboratif")
            return
            }

        self.items = (self.items as! Set<Item>).union(recrues) as NSSet
        recrues.forEach {nouvelleRecrue in
            print ("⚾︎ Traitement item", nouvelleRecrue.titre ?? "...")
            var lesGroupesDeLaNouvelleRecrue = nouvelleRecrue.groupes as! Set<Groupe>
            let (inséré,  aprèsInsertion) = lesGroupesDeLaNouvelleRecrue.insert(self)
            print("⚾︎ Inséré :" , inséré,
                  "après :"  , aprèsInsertion,
                  "les"      , lesGroupesDeLaNouvelleRecrue.count,
                  "groupes :", lesGroupesDeLaNouvelleRecrue)
            }
        }
    
    func supprimerAdhérences(mode:modeSuppression = .simulation) {
        
        switch mode {
            case .brut:
                removeFromItems(lePrincipal)
                if items != nil {removeFromItems(items!)}
            case .avecPrincipal:
                print("P:", lePrincipal)
            case .accordCollaborateurs:
                print("? ", collaborateurs)
            case .forceCollaborateurs:
                print("! ", collaborateurs)
            case .simulation:
                print("\t🔘colaborateurs :", collaborateurs)
                print("\t🔘principal :", lePrincipal)
                print("\t🔘moi :", leNom)
        }
    }
    
    enum modeSuppression {
        case brut, avecPrincipal, accordCollaborateurs, forceCollaborateurs, simulation
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
                fatalError("🔴 ERREUR le principal de \( nom ?? "") n'existe pas !!")
//              print("🔴 ERREUR le principal de", nom ?? "" , "n'existe pas !!")
//              return Item.bidon() }
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
    
    /// La valeur d'un groupe, c'est la somme (Int) des valeurs (Int64) de ses participants
    var valeur:Int { Int(
        (items as? Set<Item>)? .reduce(principal?.valeur ?? 0) {$0 + $1.valeur} ?? 0)
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
                print("☑️❌ ERREUR sur Item", $0.leTitre)
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

    
    
    
    func estMonPrincipal(groupe:Groupe) -> Bool {
        groupe.lePrincipal == self.lePrincipal
        }
    
    //MARK: Manipulation du double lien entre Groupes collaborateurs
    // 1️⃣ De ma liste d'items vers l'item principal de l'autre        et
    // 2️⃣ De la liste de groupes de l'item principal de l'autre vers moi
    
    /// Recruter un autre `Groupe`,  c'est à dire recruter l'`Item Principal` de ce `Groupe`
    func enroler(recrue:Groupe) {
//        guard recrue.principal != nil else {return}
        guard let recruePrincipal = recrue.principal else {return}

//        print(">>> LES ITEMS AVANT", lesItems)
//        print(">>> LES GROUPES AVANT", recruePrincipal.lesGroupes)

        // Ajouter à ma liste d'Items, l'Item Principal de la recrue
        self.lesItems.insert(recruePrincipal)
        // M'ajouter aux groupes de l'Item Principal de la recrue
//        recrue.principal?.lesGroupes.insert(self)
        recruePrincipal.lesGroupes.insert(self)

        
//        print(">>> LES ITEMS APRES", lesItems)
//        print(">>> LES APRES", recruePrincipal.lesGroupes)
        }
    
    func enroler_(recrue:Groupe) {
        guard recrue.principal != nil else {return}
        print(">>> PRINCIPAL", recrue.principal!.leTitre)
        print(">>> LES ITEMS", lesItems)
        print(">>> LES GROUPES", recrue.principal!.lesGroupes)
        }
    
    /// Révoquer un `Groupe` recruté, c'est à dire révoquer l'`Item Principal` de ce `Groupe`
    func révoquer(recrue:Groupe) {
        // Enlever l'Item Principal de la recrue, de ma liste d'Items.
        self.lesItems.remove(recrue.principal!)
        // M'enlever des groupes de l'Item Principal de la recrue
        recrue.principal?.lesGroupes.remove(self)
        }
    
    /// Rejoindre et collaborer à un  `Groupe` leader, c'est à dire que mon  `Item Principal` participera  au Groupe leader
    func rallier(groupeLeader:Groupe) {
        guard principal != nil else {return}
        // Ajouter mon item principal à l'ensemble d'item du groupe leader
        groupeLeader.lesItems.insert(self.principal!) // ou lePrincipal)
        // Ajouter le groupe leader à l'ensemble de groupes auquels mon item principal participe
        self.principal!.lesGroupes.insert(groupeLeader)
        }
        
        
// Equivalent à :
//        self.principal?.rallier(groupeLeader: groupeLeader)
        
//        if Groupe.tousCollaboratifs(self.lesGroupes) {print("OK")}
//        groupeLeader.lesItems.insert(self)
//        // et la réciproque ajouter le patron à ma liste de Groupe
//        self.lesGroupes.insert(groupeLeader)
       
 
          
    func demissioner(groupeLeader:Groupe) {
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
            print("régionEnglobante ###### GET")
            var toutesLesCoordonnées = lesCoordonnées
            if let lePrincipal = principal?.coordonnées {
                toutesLesCoordonnées.append(lePrincipal)
                }
                    
            // Aucun point : on affiche le monde
            if toutesLesCoordonnées.isEmpty {
                return  MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude:  0,
                            longitude: 0),
                        span: Lieu.étendueMax
                        )
                }
            
            // Un seul point (normalement le Principal)
            if toutesLesCoordonnées.count == 1 {
                return  MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude:  toutesLesCoordonnées.first?.latitude  ?? 0,
                        longitude: toutesLesCoordonnées.first?.longitude ?? 0),
                    span: Lieu.étendueParDéfaut
                    )
                }
            
            // Sinon on fait un peu de trigonométrie
            return MKCoordinateRegion.englobante(lesCoordonnées: toutesLesCoordonnées)
            }
        set {
            print("régionEnglobante ###### SET")
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
        print ("Nous avons", toutesLesAnnotations.count, "annotations")
        return toutesLesAnnotations
        }

    /// Vrai si ce Groupe est contenu dans l'ensemble des Groupes en argument
    func estContenu(dans groupes : Set<Groupe>) -> Bool { groupes.contains(self)}
    
    
//    override public func prepareForDeletion() {
//        super.prepareForDeletion()
//        print("🔘 Suppresion imminente du groupe ", nom ?? "...",
//              ", maitre de l'item principal", principal?.titre,
//              "et de", items?.count, "autres items.")
//        }

    
    

    
}
    
    


//MARK: - Pour Tests -
    
extension Groupe {

    var estCoherent:Bool {verifierCohérence(depuis: "Propriété estCoherent Groupe").isEmpty}
    
    func verifierCohérence(depuis:String="␀" ) -> [ErrorType]   {
        var lesErreurs = [ErrorType]()
        print("☑️ Cohérence du groupe", nom ?? "␀" , ", depuis" , depuis, terminator: " :")
        
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
        
//        lesItems.forEach() {$0.verifierCohérence()}
//        if !lesItems.isEmpty {
//
//        }
        
//        if lesErreurs.isEmpty {print(" ✅")}
//        else {
//            print("")
//            lesErreurs.forEach() {print("☑️❌" , $0.error.localizedDescription)}
//            }
        
        return lesErreurs
        }
    
    
    public override var description: String {
        "\(leNom), valeur: \(valeur), collaborateurs : \(lesItems.map {$0.principal?.leNom as! String}.joined(separator: ", "))."
      }
    
//    override public var debugDescription: String {
//        ""
//       }
    
    
    }






