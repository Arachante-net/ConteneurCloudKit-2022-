//
//  ListItemView.swift
//  OrderedList
//
//  Created by SchwiftyUI on 9/2/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import MapKit


/// Vue permettant d'éditer les propriétées d'un Item
///     VueModifItem(item) { valeur in ... code à éxecuter afin de retourner des infos à la vue appelante }
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
    
    typealias RetourInfoItemAchevée = (Item) -> Void
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
                        .onSubmit {print("Submit")}
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("Clic") { champTexteActif = false }
                                }
                            }

                    Stepper("\(item.valeur) points", value: $item.valeur, in: 0...10, step: 1)
                        .padding(.horizontal)
                    
                    Text("item.valeur : \(item.valeur) ") //  valeurLocale : \(valeurLocale)")

                    Toggle("Valide", isOn: $item.valide)
                    HStack {
                        ColorPicker("Couleur", selection: $item.coloris, supportsOpacity: false)
                            .onChange(of: item.coloris) { [weak item] nouvelleCouleur in
//                                persistance.sauverContexte("Item")
                                print("☑️ Nouvele couleur \(nouvelleCouleur) -- \(String(describing: item?.coloris))")
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
            
            // Définir le lieu de l'item sur la carte
            VueCarteEditionItem(item) //, laRégion: laRégion)
                .onChange(of: item.coordonnées) { nouvelItem in
//                    persistance.sauverContexte("Item")
                    print("☑️ Nouvelles coordonnées \(nouvelItem) ")
                    groupeParent.integration.toggle()
                    }
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button(action: { feuilleAffectationGroupesPresentée.toggle() }) {
//                    VStack {
//                        Image(systemName: "tray.and.arrow.down.fill")
//                        Text("Rallier").font(.caption)
//                        }
//                    }
//                .buttonStyle(.borderless)
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

        
     
        
        .onDisappear() {let _ = item.verifierCohérence(depuis: #function)}
        
        .onAppear(perform: {
            print("onAppear VueModifItem")
            let _ = item.verifierCohérence(depuis: #function)
            })
        
//        } // navigation

    }


    
    
//MARK: -

    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            item.rallier(contexte:contexte, communauté: groupes )
            }
//        persistance.sauverContexte("Groupe")
        }
    
}

