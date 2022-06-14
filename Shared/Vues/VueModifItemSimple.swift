//
//
//  Created by me
//  Copyright © 2021 Arachante
//

import SwiftUI
import MapKit
import os.log


/// Vue permettant d'éditer les propriétées d'un Item
/// -  `VueModifItem(item) { valeur in ...` code à éxecuter afin de retourner des infos à la vue appelante }
/// -  `VueModifItem(groupe) { ... }`
/// 
///
/// - Si l'appel s'effectue sur un groupe, la vue édite l'item principal de ce groupe
///
/// - Deux modes de validation sont envisageables :
///     - global : toutes les évolutions de proprieté sont validées ensemble par le bouton "VALIDER"
///     - individuel : proprieté par proprieté, le bouton global s'appele plutôt "TERMINER"

struct VueModifItemSimple: View {
    
    @EnvironmentObject private var persistance : ControleurPersistance

  
    /// L'Iten cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var item: Item
    /// Groupe en cours d'edition, propriété de VueDetailGroupe
    @ObservedObject var groupeParent: Groupe
    
    /// La région géographique ou se situe l'Item,
    /// elle sera eventuellement modifiée par  la  vue Map (et par l'utilisateur)
    @State var laRégion: MKCoordinateRegion
    
    typealias RetourInfoItemAchevée = (Bool, Item) -> Void
    /// Code à effectuer lorsque terminée afin de retourner des info à la vue mère
    ///  true si l'item à évolué,  aussi la nouvelle valeur de l'item
    let reponseAmaMère : RetourInfoItemAchevée
    

    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation
    
    // Rejet de la présentation actuelle //pas utilisée
    @Environment(\.dismiss) var cloreLaVueActuelle


        
    @FocusState var champTexteActif: Bool
    
    @State var saisieMessageTerminée:Bool = false
    
    private enum ChampTexte: Int, CaseIterable { case message, signature }
     
        @State private var message  : String = ""
        @State private var signature: String = ""
     
        @FocusState private var champAvecFocus: ChampTexte?
    
    
    /// Modifier/Editer l'Item passé passé en argument
    init(_ unItem: Item, achevée: @escaping  RetourInfoItemAchevée) {

        _item = ObservedObject<Item>(wrappedValue : unItem)
        
        // retrouver le groupe principal parent de cet item
        if let parent = unItem.principal {
            _groupeParent   = ObservedObject<Groupe>(wrappedValue : parent)
            }
        // ou un nouveau groupe s'il n'existe pas
        else {
            _groupeParent = ObservedObject<Groupe>(wrappedValue : Groupe() )
            }

        _laRégion = State(wrappedValue : unItem.région)
        
        reponseAmaMère = achevée
        }
    
    
    /// Modifier l'Item Principal du Groupe passé en argument
    init(_ unGroupe: Groupe, achevée: @escaping  RetourInfoItemAchevée) {

        _groupeParent   = ObservedObject<Groupe>(wrappedValue : unGroupe)
        
        if let principal = unGroupe.principal {
            _item     = ObservedObject<Item>(wrappedValue : principal)
            _laRégion = State(wrappedValue : principal.région)
            }
        else {
            _item     = ObservedObject<Item>(wrappedValue : Item() )
            _laRégion = State(wrappedValue : MKCoordinateRegion.init() )
            }
        
        reponseAmaMère = achevée
        
        Logger.interfaceUtilisateur.info("🌐 Init de VueModifItemSimple pour le groupe \(unGroupe.leNom), positioné en  \(unGroupe.principal!.longitude) \(unGroupe.principal!.latitude) ")

        }

    var body: some View {
//        NavigationView {
        VStack(alignment: .leading , spacing: 2) {
            VStack {
                VStack {
                    TextField("Titre carte :",
                              text: $item.leTitre
                              )
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.secondary)
                        .border(.secondary)
                        .focused($champTexteActif)
                        .submitLabel(.done)
                        .onSubmit {Logger.interfaceUtilisateur.info("Submit")}
                    // 15 mars
//                        .toolbar {
//                            ToolbarItemGroup(placement: .keyboard) {
//                                Button("Clic") { champTexteActif = false }
//                                }
//                            }

                    Stepper("\(item.valeur) points", value: $item.valeur, in: 0...10, step: 1)
                        .padding(.horizontal)
                    
                    Text("item.valeur : \(item.valeur) ") //  valeurLocale : \(valeurLocale)")

                    Toggle("Valide", isOn: $item.valide)
                    HStack {
                        ColorPicker("Couleur", selection: $item.coloris, supportsOpacity: false)
                            .onChange(of: item.coloris) { [weak item] nouvelleCouleur in
//                                persistance.sauverContexte("Item")
                                Logger.interfaceUtilisateur.info("☑️ Nouvele couleur \(nouvelleCouleur) -- \(String(describing: item?.coloris))")
                                //FIXME: !! Y-a vraiment besoin de cette bidouille ??
                                // Comment avoir la valeur du Stepper affichée en direct (et sauvegardée)
                                // Honte sur moi, je ne trouve pas le mecanisme élegant pour réamiser cela
//                                groupeParent.integration.toggle()
                                // 5 Avril
                                groupeParent.objectWillChange.send()
                                
                                }
                      

                        }
                        .frame(maxWidth: .infinity , maxHeight: 30)
                        .background(item.coloris)

                    }
                    .border(.secondary)
                
                }
                .padding(.horizontal)
//                .onChange(of: item.coordonnées) { nouvelItem in
//                    persistance.sauverContexte("Item")
//                    print("☑️ Nouvel Item coordonnées \(nouvelItem) ")
//                    groupeParent.integration.toggle()
//                    }
            HStack {
                Text("Message : ") //\(item.leMessage)")
                TextField("Message", text: $item.leMessage) {
                        Logger.interfaceUtilisateur.debug("DIRECT Soumission du message \(item.leMessage)")
                        saisieMessageTerminée = true
                        }
                    .onSubmit(of: .text) {
                        Logger.interfaceUtilisateur.debug("Soumission du message \(item.leMessage)")
                        saisieMessageTerminée = true
                      }
                    .onChange(of: item.leMessage) { message in // item.leMessage
                        Logger.interfaceUtilisateur.debug("Évolution du message \(message) \(item.leMessage)")
                        saisieMessageTerminée = false
                        }
                
                    .foregroundColor(saisieMessageTerminée ? .accentColor : .gray)
//                        print("FLASH", message)
////                        groupeParent.integration.toggle()
////                        item.principal?.objectWillChange.send()
////                        groupeParent.objectWillChange.send()
////
////                        Array(item.lesGroupes).forEach {
//////                            $0.objectWillChange.send()
////                            $0.integration.toggle()
//                            }
//                        // Signaler aux groupes qui m'utilisent que quelque chose à changé
//                        item.lesGroupes.forEach { $0.integration.toggle() }
//                        persistance.sauverContexte()
//                        }
                
                /// Validation locale du message
                Button(action: {
                    // Faire des choses plus pertinentes (cf les modes de validation individuelle ou globale)
                    // pourait éviter un flux à chaque nouvelle lettre saisie
                    Logger.interfaceUtilisateur.info("Message à envoyer : '\(item.leMessage)'")
                    //FIXME: Danger !
                    item.principal?.objectWillChange.send()
                    saisieMessageTerminée = true
                    }) {
                        Label("OK", systemImage: "chevron.forward.circle.fill")
                        }
                
                Spacer()
                }
            
            
            Text("Signature : \(item.signature)")
            
            Form {
                TextField("Message", text: $item.leMessage) {
                    print("DIRECT")
                    saisieMessageTerminée = true
                } .foregroundColor(saisieMessageTerminée ? .accentColor : .gray)
                    .focused($champAvecFocus, equals: .message)
//                TextField("Signature", text: $signature)
//                    .focused($champAvecFocus, equals: .signature)
                }
//                .toolbar {
//                    ToolbarItem(placement: .keyboard) {
//                        Button("OK") {}
//                        }
//                    }
//                                 }
            
            /// Définir le lieu de l'item sur la carte, l'utilisateur peut déplacer la région pour désigner une  autre position
            VueCarteEditionItem(item, uneRégion: $laRégion)
//                .onChange(of: item.coordonnées) { nouvelItem in
//                    Logger.interfaceUtilisateur.debug("🌐 Coord Actu \(item.coordonnées.longitude) \(item.coordonnées.latitude),\t Nouv \(nouvelItem.longitude) \(nouvelItem.latitude) ")
//                   ///////////////////: item.centrerSur(laRégion)    non !!
//                    ////persistance.sauverContexte("Item", depuis:"ModifItem.CarteEditionItem") //"#function) // centraliser ?
//                    groupeParent.integration.toggle()
//                    }
            
                .onChange(of: item.région) { nouvelleRégion in
                    // évolue si l'item est mis à jour
                    Logger.interfaceUtilisateur.debug("🌐🌐 carte item.région Actu \(item.région.center.longitude) \(item.région.center.latitude),\t Nouv \(nouvelleRégion.center.longitude) \(nouvelleRégion.center.latitude) ")
                    // item = f( nouvelleRégion )
                    item.centrerSur(nouvelleRégion)   // non !! ///////////////: 21 mars
                    ////persistance.sauverContexte("Item", depuis:"ModifItem.CarteEditionItem") //"#function) // centraliser ?
//                    groupeParent.integration.toggle()
                    // 5 avril
                    groupeParent.objectWillChange.send()
                    }
            
                .onChange(of: laRégion) { nouvelleRégion in
                    // évolue en permance
                    Logger.interfaceUtilisateur.debug("🌐🌐 carte laRégion Actu \(item.région.center.longitude) \(item.région.center.latitude),\t Nouv \(nouvelleRégion.center.longitude) \(nouvelleRégion.center.latitude) ")
                    }
            
                .aspectRatio(16/9, contentMode: .fit)

        }
        .isHidden(item.isDeleted || item.isFault ? true : false)
        .opacity(item.valide ? 1.0 : 0.1)
//        } // Nav
        
        
        
        
        .toolbar {
            
//            ToolbarItemGroup(placement: .keyboard) {
//                Button("OK") {
//                    champAvecFocus = nil
//                    print("DIRECT OK")
//                }
//                }
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    Logger.interfaceUtilisateur.debug("Abandonner les modifs de l'Item (A ENRICHIR ?)")
                    //FIXME: Danger !
                    item.principal?.objectWillChange.send()
                    /// Dire à ma vue mère que rien n'a changé
                    reponseAmaMère(false, item)
                }) {
                    VStack {
                        Icones.abandoner.imageSystéme
                        Text("Abandonner").font(.caption)
                        }
                  }.buttonStyle(.borderedProminent)

            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button(action: { feuilleAffectationGroupesPresentée.toggle() }) {
//                    VStack {
//                        Image(systemName: "tray.and.arrow.down.fill")
//                        Text("Rallier").font(.caption)
//                        }
//                    }
//                .buttonStyle(.borderless)
                
                Button(action: {
                    Logger.interfaceUtilisateur.debug("🌐 Terminer (Valider ?) les modifs de l'Item (A ENRICHIR ?)")
                    Logger.interfaceUtilisateur.debug("🌐 Région \(laRégion.center.longitude)  \(laRégion.center.latitude) ")
                    Logger.interfaceUtilisateur.debug("🌐 Item \(item.longitude)  \(item.latitude) ")

                    /// Validation globale, modifier la position de l'item avec le centre de la région actuellement affichée
                    item.centrerSur(laRégion)
                    // Rafraichir le Groupe
                    //FIXME: Danger !
                    item.principal?.objectWillChange.send()
                    reponseAmaMère(true, item)
                }) {
                    VStack {
                        Icones.valider.imageSystéme
                        Text("Terminer").font(.caption)
                        }
                  }.buttonStyle(.borderedProminent)
                
                Spacer()
                }
            }

        // Signaler aux groupes qui m'utilisent que quelque chose à changé
        // et qu'il faut rafraichier l'écran en direct
        .onChange(of: item.valeur)    { _ in rafraichirLesGroupes() }
        .onChange(of: item.leMessage) { _ in rafraichirLesGroupes() }

        .onChange(of: item.titre)     { _ in rafraichirLesGroupes() }
        .onChange(of: item.coloris)   { _ in rafraichirLesGroupes() }

        .onChange(of: item.latitude)  { _ in
            Logger.interfaceUtilisateur.debug("🌐 lat chang")
            rafraichirLesGroupes()
            }
        .onChange(of: item.longitude) { _ in
            Logger.interfaceUtilisateur.debug("🌐 long chang")
            rafraichirLesGroupes()
            }
        
        .onChange(of: item.région) { _ in
            Logger.interfaceUtilisateur.debug("🌐🌐 VueModif région chang")
//          rafraichirLesGroupes()
            }

        
        .onDisappear() {let _ = item.verifierCohérence(depuis: #function)}
        
        .onAppear(perform: {
            Logger.interfaceUtilisateur.info("onAppear VueModifItem")
            let _ = item.verifierCohérence(depuis: #function)
            })
        
    }


    
    
//MARK: -

    private func rafraichirLesGroupes() {
        Logger.interfaceUtilisateur.debug("♻️ Rafraichir les groupes")
        //FIXME: le !  5 Avril
//        item.principal!.objectWillChange.send()
        item.lesGroupes.forEach {
//            $0.integration.toggle()
            // 5 Avril
            $0.objectWillChange.send()
        }
        }
    
    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            item.rallier(contexte:contexte, communauté: groupes )
            }
        }
    
}

