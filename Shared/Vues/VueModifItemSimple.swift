//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import MapKit
import os.log


/// Vue permettant d'éditer les propriétées d'un Item
///     VueModifItem(item) { valeur in ... code à éxecuter afin de retourner des infos à la vue appelante }
/// Deux modes de validation sont envisageables :
///     global : toutes les évolutions de proprieté sont valider ensemble par le bouton "VALIDER"
///     individuel : proprieté par proprieté, le bouton global s'appele plutôt "TERMINER"

struct VueModifItemSimple: View {
    
    @EnvironmentObject private var persistance : ControleurPersistance

    // La Source de vérité est la Vue ............;
//    /// Item en cours d'édition, propiété de VueDetailItem
//    @Binding var item:Item
//    
    /// L'Iten cour d'édition, ( il est la propriété de  la vue mère)
    @ObservedObject var item: Item
    /// Groupe en cours d'edition, propriété de VueDetailGroupe
    @ObservedObject var groupeParent: Groupe
    
    /// Région géographique ou se situe l'Item
    @State var laRégion: MKCoordinateRegion
    
    typealias RetourInfoItemAchevée = (Bool, Item) -> Void
    /// Code à effectuer lorsque terminée afin de retourner des info
    let reponseAmaMère : RetourInfoItemAchevée
    

    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle


        
    @FocusState var champTexteActif: Bool
    
    // Modifier l'Item passé passé en argument
    init(_ unItem: Item, achevée: @escaping  RetourInfoItemAchevée) {

        _item = ObservedObject<Item>(wrappedValue : unItem)
        
        if let parent = unItem.principal {
            _groupeParent   = ObservedObject<Groupe>(wrappedValue : parent)
            }
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
        
        Logger.interfaceUtilisateur.info("🌐 Init de VUE MODIF ITEM SIMPLE \(unGroupe.leNom) Position  \(unGroupe.principal!.longitude) \(unGroupe.principal!.latitude) ")

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
                                groupeParent.integration.toggle()
                                
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
                TextField("Message", text: $item.leMessage)
                    .onSubmit(of: .text) { Logger.interfaceUtilisateur.debug("Soumission du message \(item.leMessage)") }
//                    .onChange(of: item.leMessage) { message in // item.leMessage
//                        print("FLASH", message)
////                        groupeParent.integration.toggle()
////                        item.principal?.objectWillChange.send()
////                        groupeParent.objectWillChange.send()
////
////                        Array(item.lesGroupes).forEach {
//////                            $0.objectWillChange.send()
////                            $0.integration.toggle()
////                            }
//                        // Signaler aux groupes qui m'utilisent que quelque chose à changé
//                        item.lesGroupes.forEach { $0.integration.toggle() }
//                        persistance.sauverContexte()
//                        }
                Button(action: {
                    // Faire des choses plus pertinentes
                    Logger.interfaceUtilisateur.info("Message à envoyer : '\(item.leMessage)'")
                    }) {
                        Label("Envoyer", systemImage: "chevron.forward.circle.fill")
                        }
                
                Spacer()
                }
            
            Text("Signature : \(item.signature)")
            
            
            
            // Définir le lieu de l'item sur la carte
            // 22 mars
            VueCarteEditionItem(item, uneRégion: $laRégion) //, laRégion: laRégion)
//                .onChange(of: item.coordonnées) { nouvelItem in
//                    Logger.interfaceUtilisateur.debug("🌐 Coord Actu \(item.coordonnées.longitude) \(item.coordonnées.latitude),\t Nouv \(nouvelItem.longitude) \(nouvelItem.latitude) ")
//                   ///////////////////: item.centrerSur(laRégion)    non !!
//                    ////persistance.sauverContexte("Item", depuis:"ModifItem.CarteEditionItem") //"#function) // centraliser ?
//                    groupeParent.integration.toggle()
//                    }
                .onChange(of: item.région) { nouvelleRégion in
                    Logger.interfaceUtilisateur.debug("🌐 Région Actu \(item.région.center.longitude) \(item.région.center.latitude),\t Nouv \(nouvelleRégion.center.longitude) \(nouvelleRégion.center.latitude) ")
                    item.centrerSur(nouvelleRégion)   // non !! ///////////////: 21 mars
                    ////persistance.sauverContexte("Item", depuis:"ModifItem.CarteEditionItem") //"#function) // centraliser ?
                    groupeParent.integration.toggle()
                    }
                .aspectRatio(16/9, contentMode: .fit)

        }
        .isHidden(item.isDeleted || item.isFault ? true : false)
        .opacity(item.valide ? 1.0 : 0.1)
        
        
        
        
//        .sheet(isPresented: $feuilleAffectationGroupesPresentée) {
//            Text("Rallier les groupes")
//
////            VueAffectationItemGroupe(groupe: groupe, lesGroupesARetenir: item.lesGroupes ) {
////                rallierGroupes($0)
////                feuilleAffectationGroupesPresentée = false
////                }
//                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
//            }
        
        
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    Logger.interfaceUtilisateur.debug("Abandonner les modifs de l'Item (A ENRICHIR ?)")
//                    laRégion.centrerSur(item)
                    reponseAmaMère(false, item)
                }) {
                    VStack {
                        Icones.abandoner.imageSystéme
                        Text("Abandonner ??").font(.caption)
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

//                    laRégion.centrerSur(item)
                    ////////// 21 mars
//                    item.centrerSur(laRégion)
                    // 22 mars
                    item.centrerSur(laRégion)
                    reponseAmaMère(true, item)
                }) {
                    VStack {
                        Icones.valider.imageSystéme
                        Text("Terminer").font(.caption)
                        }
                  }.buttonStyle(.borderedProminent)
                
                Spacer()
//                Button(role: .cancel, action: {
//                    print("BOF")
//                    cloreLaVueActuelle()
//                } ) {
//                    VStack {
//                        Image(systemName: "backward")
//                        Text("Annuler").font(.caption)
//                        }
//                }
                
//                Button(action: {
//                    item.centrerSur(laRégion)
//
//                    persistance.sauverContexte("Item")
//
//                    // Executer le code (closure) fourni à cette Vue (VueModifItem) en parametre d'entrée
//                    // par la vue appelante. (permet une remontée d'information)
//                    laModificationDeItemEstRéalisée(item)
//                    }
//                    ) { Text("VALIDER ?") }
//                    .buttonStyle(.borderedProminent)

               //////////////////:  Button("Rejet") { feuilleAffectationGroupesPresentée=false}
                }
            }

        // Signaler aux groupes qui m'utilisent que quelque chose à changé
        // et qu'il faut rafraichier l'écran en direct
        .onChange(of: item.valeur)    { _ in rafraichirLesGroupes() }
        .onChange(of: item.leMessage) { _ in rafraichirLesGroupes() }
//        .onSubmit {
//            Logger.interfaceUtilisateur.debug("SUBMIT")
//        }

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
            Logger.interfaceUtilisateur.debug("🌐 région chang")
//          rafraichirLesGroupes()
            }

        
        .onDisappear() {let _ = item.verifierCohérence(depuis: #function)}
        
        .onAppear(perform: {
            Logger.interfaceUtilisateur.info("onAppear VueModifItem")
            let _ = item.verifierCohérence(depuis: #function)
            })
        
//        } // navigation

    }


    
    
//MARK: -

    private func rafraichirLesGroupes() {
        Logger.interfaceUtilisateur.debug("♻️ Rafraichir les groupes")
        /////////////persistance.sauverContexte(depuis:#function)
        item.lesGroupes.forEach { $0.integration.toggle() }
        }
    
    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            item.rallier(contexte:contexte, communauté: groupes )
            }
//        persistance.sauverContexte("Groupe")
        }
    
}

