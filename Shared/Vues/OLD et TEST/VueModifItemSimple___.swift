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
struct VueModifItemSimple___: View {
    

    // La Source de vérité est la Vue ............;
    /// Item en cours d'édition, propiété de VueDetailItem
    @Binding var item:Item
    
    
    
    /// Région géographique ou se situe l'Item
    @Binding var laRegion: MKCoordinateRegion 
    /// Code à effectuer lorsque terminée afin de retourner des info
    let achevée: (Item) -> Void

    
    @State private var feuilleAffectationGroupesPresentée:Bool = false

    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation  // Button("Rejettez moi") {modePresentation.wrappedValue.dismiss()}
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle


    @EnvironmentObject private var persistance: ControleurPersistance
        
    @FocusState var champTexteActif: Bool
    


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
                        }
                        .frame(maxWidth: .infinity , maxHeight: 30)
                        .background(item.coloris)

                    }
                    .border(.secondary)
                
                }
                .padding(.horizontal)
            
            // Définir le lieu de l'item sur la carte
            VueCarteEditionItem(item: $item, laRégion: $laRegion)
            
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
                
                Button(action: {
                    item.centrerSur(laRegion)
                     
                    persistance.sauverContexte("Item")
                
                    // Executer le code (closure) fourni à cette Vue (VueModifItem) en parametre d'entrée
                    // par la vue appelante. (permet une remontée d'information)
                    achevée(item)
                    }
                    ) { Text("VALIDER") }
                    .buttonStyle(.borderedProminent)

                Button("Rejet") { feuilleAffectationGroupesPresentée=false}
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
        persistance.sauverContexte("Groupe")
        }
    
}

