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
//FIXME:  ou alors  @State var item:Item ou  Ξ.item  (ViewModel)
//FIXME: c'est quoi un  @StateObject  ?
    
    let achevée: (Bool) -> Void
     
    @StateObject private var Ξ:ViewModel // = ViewModel(item)

    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle

    @EnvironmentObject private var persistance: ControleurPersistance
        
    @FocusState var champTexteActif: Bool
    

    
    init(_ unItem: Item, onSave: @escaping (Bool) -> Void ) {
//        _item = State(initialValue: unItem) /////:
//        item = unItem /////////:
//        Ξ.item =  unItem
        _Ξ = StateObject(wrappedValue: ViewModel(unItem))
        self.achevée = onSave
        }


    var body: some View {
        NavigationView {
        VStack(alignment: .leading , spacing: 2) {
            VStack { // (alignment: .leading , spacing: 2)
                VStack { // (alignment: .leading , spacing: 2)
                    
                    TextField("Titre carte :",
                              text: $Ξ.item.leTitre  //,
//                              format: .name(style: .medium)
                              )
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.secondary)
                        .border(.secondary)
                        .focused($champTexteActif)
                        .submitLabel(.done)
                        .onSubmit {print("Submit")}
                        .toolbar {
                            ToolbarItemGroup(placement:   .keyboard) {
                                Button("Clic") { champTexteActif = false }
                                }
                            }

                    Stepper("\(Ξ.item.valeur) points", value: $Ξ.item.valeur, in: 0...10, step: 1)
                        .padding(.horizontal)
                    
                    Text("item.valeur : \(Ξ.item.valeur) ") //  valeurLocale : \(valeurLocale)")

                    Toggle("Valide", isOn: $Ξ.item.valide)
                    HStack {
                        ColorPicker("Couleur", selection: $Ξ.item.coloris, supportsOpacity: false)
                        }
                        .frame(maxWidth: .infinity , maxHeight: 30)
                        .background(Ξ.item.coloris)

                    }
                    .border(.secondary)
                
                }
                .padding(.horizontal)
            
            // Définir le lieu de l'item sur la carte
            VueEditionCarte(
                Ξ.item,
                sectionGéographique: Ξ.régionItem,
                lesLieux:            Ξ.locations, // la position
                lieuEnCoursEdition:  Ξ.leLieuÉdité
            )
                .onChange(of: Ξ.locations) {newValue in
                    let _ = print("ON CHANGE")
                    Ξ.régionItem.center.longitude = newValue.last?.longitude ?? 0
                    Ξ.régionItem.center.latitude  = newValue.last?.latitude  ?? 0
                    }
        }
        .isHidden(Ξ.item.isDeleted || Ξ.item.isFault ? true : false)
        .opacity(Ξ.item.valide ? 1.0 : 0.1)
        
        
        
        
        .sheet(isPresented: $Ξ.feuilleAffectationGroupesPresentée) {
            Text("Rallier les groupes")
            
            VueAffectationItemGroupe(lesGroupesChoisis: Ξ.item.lesGroupes ) {
                rallierGroupes($0)
                Ξ.feuilleAffectationGroupesPresentée = false
                }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
        
        
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { Ξ.feuilleAffectationGroupesPresentée.toggle() }) {
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
                    
                    if !Ξ.locations.isEmpty {
                        Ξ.item.longitude = (Ξ.locations.last?.coordonnées.longitude)! //?? 0
                        Ξ.item.latitude  = (Ξ.locations.last?.coordonnées.latitude)! // ?? 0
                        Ξ.régionItem.center.latitude = Ξ.locations.last?.coordonnées.latitude ?? 0
                        Ξ.régionItem.center.longitude = Ξ.locations.last?.coordonnées.longitude ?? 0
                        }
                     
                        persistance.sauverContexte("Item")
                    
                        // executer la closure fournie à cette Vue (VueModifItem) en parametre d'entrée
                        // par la vue appelante.
                        achevée(true)
                        }
                    ) { Text("VALIDER") }
                    .buttonStyle(.borderedProminent)
                }
            }

        
        
        
        
        
        .onAppear(perform: {
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
        
    }}




    private func rallierGroupes(_ groupes: Set<Groupe>) {
        withAnimation {
            Ξ.item.rallier(contexte:contexte, communauté: groupes )
            }
        persistance.sauverContexte("Groupe")
        }
    
}

