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
struct VueModifItem: View {
    
//    @ObservedObject var item: Item
//FIXME :  ou alors  @State var item:Item ou  Ξ.item  (ViewModel)
//FIXME : c'est quoi un  @StateObject  ?
    
     
//    @StateObject private var Ξ:ViewModel // = ViewModel(item)
    
    /// Item en cours d'édition, propiété de VueDetailItem
    @Binding var item:Item
    let achevée: (Item) -> Void //(Bool) -> Void

    @State var feuilleAffectationGroupesPresentée:Bool = false


    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle

    @EnvironmentObject private var persistance: ControleurPersistance
        
    @FocusState var champTexteActif: Bool
    

    
//    init(_ unItem: Item, région:MKCoordinateRegion, onSave: @escaping (Bool) -> Void ) {
////        _item = State(initialValue: unItem) /////:
////        item = unItem /////////:
////        Ξ.item =  unItem
//        _Ξ = StateObject(wrappedValue: ViewModel(unItem))
//        self.achevée = onSave
//        _région = Binding(projectedValue: unItem.région) //région
////        print("🌐 Init de VueModifItem avec longitudes", Ξ.item.longitude,unItem.longitude )
//        }


    var body: some View {
        NavigationView {
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
            VueCarteEditionItem(item: $item, laRegion: $item.région)
            
        }
        .isHidden(item.isDeleted || item.isFault ? true : false)
        .opacity(item.valide ? 1.0 : 0.1)
        
        
        
        
        .sheet(isPresented: $feuilleAffectationGroupesPresentée) {
            Text("Rallier les groupes")
            
            VueAffectationItemGroupe(lesGroupesARetenir: item.lesGroupes ) {
                rallierGroupes($0)
                feuilleAffectationGroupesPresentée = false
                }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        
        
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { feuilleAffectationGroupesPresentée.toggle() }) {
                    VStack {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("Rallier").font(.caption)
                        }
                    }
//                .buttonStyle(.borderless)
                Spacer()
                Button(role: .cancel, action: {
                    print("BOF")
                    cloreLaVueActuelle()
                } ) {
                    VStack {
                        Image(systemName: "backward")
                        Text("Annuler").font(.caption)
                        }
                }
                
                Button(action: {
                    item.centrerSurLaRégion()
                   ////////////:
//                    if !Ξ.locations.isEmpty {
//                        Ξ.item.longitude = (Ξ.locations.last?.coordonnées.longitude)! //?? 0
//                        Ξ.item.latitude  = (Ξ.locations.last?.coordonnées.latitude)! // ?? 0
//                        Ξ.régionItem.center.latitude = Ξ.locations.last?.coordonnées.latitude ?? 0
//                        Ξ.régionItem.center.longitude = Ξ.locations.last?.coordonnées.longitude ?? 0
//                        }
                     
                        persistance.sauverContexte("Item")
                    
                        // executer la closure fournie à cette Vue (VueModifItem) en parametre d'entrée
                        // par la vue appelante.
                        achevée(item) //true)
                        }
                    ) { Text("VALIDER") }
                    .buttonStyle(.borderedProminent)
                }
            }

        
        
        
        .onDisappear() {let _ = item.verifierCohérence(depuis: #function)}
        
        .onAppear(perform: {
            let _ = item.verifierCohérence(depuis: #function)
            // charger un Item en mémoire
//            titre     = item.titre ?? "..."
//            valeurLocale    = Int(item.valeur)
//            ordre     = Int(item.ordre )
//            latitude  = item.latitude
//            longitude = item.longitude
//            instant   = item.horodatage //timestamp!
//            couleur   = item.coloris
//            valide    = item.valide
            })
        
        }

    }


    
    
//MARK: -

    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            item.rallier(contexte:contexte, communauté: groupes )
            }
        persistance.sauverContexte("Groupe")
        }
    
}

