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
        set {items =  newValue as NSSet } // adding(newValue)
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
    
    var collaborateursSansLePrincipal : Set<Groupe> {
        guard items?.count ?? 0 > 0 else { return Set<Groupe>() }

        lesItems.remove(lePrincipal)
        return Set( ((items as? Set<Item>)?.map {$0.principal!})! )
        }

    func estMonPrincipal(groupe:Groupe) -> Bool {
        groupe.lePrincipal == self.lePrincipal
        }
    
    //MARK: Manipulation du double lien entre Groupes collaborateurs
    // 1️⃣ De ma liste d'items vers l'item principal de l'autre        et
    // 2️⃣ De la liste de groupes de l'item principal de l'autre vers moi
    
    /// Recruter un autre `Groupe`,  c'est à dire recruter l'`Item Principal` de ce `Groupe`
    func enroler(recrue:Groupe) {
        guard recrue.principal != nil else {return}
        print(">>> LES ITEMS AVANT", lesItems)
        print(">>> LES GROUPES AVANT", recrue.principal!.lesGroupes)

        // Ajouter à ma liste d'Items, l'Item Principal de la recrue
        self.lesItems.insert(recrue.principal!)
        // M'ajouter aux groupes de l'Item Principal de la recrue
        recrue.principal?.lesGroupes.insert(self)
        
        print(">>> LES ITEMS APRES", lesItems)
        print(">>> LES APRES", recrue.principal!.lesGroupes)
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
        set {régionEnglobante_ = newValue}
        
        }
        //MARK: Géographie
        /// En entrée toutesLesCoordonnées    : [CLLocationCoordinate2D]
        /// En sortie la région: MKCoordinateRegion  englobant toutesLesCoordonnées
        //TODO: Certainement à déplacer (vers Lieu)
        
#warning("Attention ...    ")
//#error("Erreur ! ")
//        let région = MKCoordinateRegion.englobante(lesCoordonnées: toutesLesCoordonnées)
        
//        let lesLongitudes = toutesLesCoordonnées.map {$0.longitude}
//        let lesLatitudes  = toutesLesCoordonnées.map {$0.latitude}
//
//
//        let P1 = CLLocationCoordinate2D(latitude: lesLatitudes.min()!, longitude: lesLongitudes.min()!)
//        let P2 = CLLocationCoordinate2D(latitude: lesLatitudes.max()!, longitude: lesLongitudes.max()!)
//        print("🏁 Min Min", P1.longitude, P1.latitude)
//        print("🏁 Max Max", P2.longitude, P2.latitude)
//
//        let   π = Double.pi
//        let _2π = 2 * π
//        let _3π = 3 * π
//
//        let Rad = π/180
//        let Deg = 180/π
//
//        let φ1 = P1.latitude * Rad
//        let φ2 = P2.latitude * Rad
//
//        let λ1 = P1.longitude * Rad
//        let λ2 = P2.longitude * Rad
//
//        let Δλ = λ2 - λ1 // long
//        let Δφ = φ2 - φ1  // lat
//
//        print("🏁 Delta long", Δλ ,  "lat", Δφ)
//
//
//// https://www.movable-type.co.uk/scripts/latlong.html
////        Bx = cos φ2 ⋅ cos Δλ
////        By = cos φ2 ⋅ sin Δλ
////        φm = atan2( sin φ1 + sin φ2, √(cos φ1 + Bx)² + By² )
////        λm = λ1 + atan2(By, cos(φ1)+Bx)
////--------------------------------------------------------------
//// Voir aussi https://stackoverflow.com/questions/4169459/whats-the-best-way-to-zoom-out-and-fit-all-annotations-in-mapkit
//
//// atan2 returne des valeurs entre -π ... +π ( -180° ... +180°)
//// afin de normaliser en une valeur entre 0° et 360°, with −ve values ttransformées entre 180° ... 360°),
//// convertir en degrees and then use (θ+360) % 360 ( % <=> truncatingRemainder(dividingBy) )
//
////        For final bearing, simply take the initial bearing from the end point to the start point and reverse it (using θ = (θ+180) % 360).
//
//        let Bx = cos(φ2) * cos(Δλ)
//        let By = cos(φ2) * sin(Δλ)
//        let φm = atan2(sin(φ1) + sin(φ2), sqrt( (cos(φ1)+Bx)*(cos(φ1)+Bx) + By*By ) )
//        let λm = λ1 + atan2(By, cos(φ1) + Bx)
//        // Normaliser la longitude entre -180° et +180°
//        let λm_ = (λm + _3π).truncatingRemainder(dividingBy: _2π) -  π
//        // l'ecart de longitude
//        let Δλ_ = abs((Δλ + _3π).truncatingRemainder(dividingBy: _2π) -  π)
//
//        // ??? Normaliser la latitude entre -90° et +90° ?
////        let φm_ = φm * -1 //(φm + (3 * π / 2).truncatingRemainder(dividingBy: π) -  (π / 2))
////        let φm_ = (φm + π) .truncatingRemainder(dividingBy:_2π) - π // INCHANGÉ ...
////        let φm_ = (φm + (3 * π / 2)).truncatingRemainder(dividingBy: π) -  (π / 2) // INCHANGÉ
//        let φm_ = (φm +   (π / 2 ) ).truncatingRemainder(dividingBy: π) -  (π / 2)
////        let φm_ = (φm +   (π / 2 ) ).truncatingRemainder(dividingBy: π) -  (π / 2)
//
//        print("🏁 φm brut", φm * Deg, "normalisé", φm_ * Deg)
//
//        // ???? l'ecart de latitude
//        let Δφ_ = (Δφ + (3 * π / 2).truncatingRemainder(dividingBy: π) -  (π / 2))
//
//
//        let P_milieu = CLLocationCoordinate2D(latitude:φm_ * Deg, longitude: λm_ * Deg)
//        print ("🏁 Le centre de ", P1.longitude, P1.latitude , "  et  ", P2.longitude, P2.latitude)
//        print ("🏁 est", P_milieu.longitude, P_milieu.latitude)
//        print ("🏁 l'écart en longitude est de", Δλ * Deg, Δλ_ * Deg ,"°" )
//        print ("🏁 l'écart en  latitude est de", Δφ * Deg, Δφ_ * Deg ,"°" )
//
//        // normaliser la longitude entre  −180…+180 : (lon+540)%360-180
//        // truncatingRemainder
//        // (λ3+540).truncatingRemainder(dividingBy: 360) - 180
//
//        // Élargir l'envergure de la zone de 5% 0.5
//        // let envergure = MKCoordinateSpan(
//        // latitudeDelta:  (ecartLatitudes  + (ecartLatitudes  * 0.5)).truncatingRemainder(dividingBy: 180),
//        // longitudeDelta: (ecartLongitudes + (ecartLongitudes * 0.5)).truncatingRemainder(dividingBy: 360))
//            let envergure = MKCoordinateSpan(
//                // En degrée et un peu d'espace autour
//                latitudeDelta:  Δφ_ * Deg * 1.5,
//                longitudeDelta: Δλ_ * Deg * 1.5
//                )
//
//            // MapKit ne peut pas afficher l'ensemble du globe,
//            // pour la région ci dessous il faut faire defiler la carte.
//            // Detecter et prévenir que l'on depasse le facteur de zoom MapKit.  C'est lequel ??
//            // max latitudeDelta : 180
//            // cf regionThatFits
//           _ = Lieu.étendueMax
//
////        MKCoordinateSpan(
////                latitudeDelta:  180,
////                longitudeDelta: 360
////                )
//
//            print ("🏁 Carte Milieu", P_milieu.longitude, P_milieu.latitude )
//            print ("🏁 Carte Envergure long", envergure.longitudeDelta , "lat", envergure.latitudeDelta)
//
//            let région = MKCoordinateRegion(center: P_milieu, span: envergure) //envergureMondiale)
////            let régionAdaptée = regionThatFits(région)
////        MapKit.MKCoordinateRegion.   regionThatFits(région)
//        }
    
    
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

    
    func verifierCohérence(depuis:String="␀" ) -> [ErrorType]   {
        var lesErreurs = [ErrorType]()
        print("☑️ Cohérence du groupe", nom ?? "␀" , ", depuis" , depuis, terminator: " :")
        
        if !valide
            {lesErreurs.append(ErrorType(.groupeInvalide ))}
        
        if (nom == nil || nom!.isEmpty || nom == "")
            {lesErreurs.append(ErrorType(.groupeSansNom ))}
        
        if (id == nil )
            { lesErreurs.append(ErrorType(.groupeSansID )) }
        
        if principal == nil
            { lesErreurs.append(ErrorType(.itemSansPrincipal ))}
        
        
        
        if lesErreurs.isEmpty {print(" ✅")}
        else {
            print("")
            lesErreurs.forEach() {print("☑️❌" , $0.error.localizedDescription)}}
        
        return lesErreurs
        }
    }






