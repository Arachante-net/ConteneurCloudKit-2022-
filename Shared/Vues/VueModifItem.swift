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
    
//    @State var item:Item
    @ObservedObject var item: Item
//FIXME: c'est quoi un  @StateObject  ?
    
    let achevée: (Bool) -> Void
    
    @Environment(\.managedObjectContext) var contexte
    @Environment(\.presentationMode)     var modePresentation
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle

    @EnvironmentObject private var persistance: ControleurPersistance
    
    // si @ObservedObject pas besoin de State ?
//    @State var titre:     String = ""
//    @State var valeurLocale:    Int    = 0     /////////
//    @State var ordre:     Int    = 0
//    @State var latitude:  Double = 0 //////////
//    @State var longitude: Double = 0
//
//    @State var couleur  = Color.secondary
//    @State var instant  = Date()
//    @State var valide   = false

    /// La région géographique entourant l'item en cours d'édition
    @State private var régionItem = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Lieu.exemple.latitude, longitude: Lieu.exemple.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    /// Les lieux éditables (ici on en utilise qu'un seul)
    @State private var locations = [Lieu]()
    /// Le lieu en cours d'édition
    @State private var leLieuÉdité: Lieu?
    


    @FocusState var estEntréeActive: Bool

    let formatDate: DateFormatter = {
       let formateur = DateFormatter()
          formateur.dateStyle = .long
          formateur.locale    = Locale(identifier: "fr_FR") //FR-fr")

      return formateur
    }()
    
    var mapRegion: MKCoordinateRegion {
      print("🟦 map Région", item.latitude, item.longitude )
      let coordonnées = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
      // Dimension de la section à afficher en °
        let section = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
      return MKCoordinateRegion(center: coordonnées, span: section)
    }
    
    
    

    @State var feuilleAffectationGroupesPresentée = false
    
    init(_ unItem: Item, onSave: @escaping (Bool) -> Void ) {
//        _item = State(initialValue: unItem) /////:
        item = unItem /////////:
        self.achevée = onSave
        }


    var body: some View {
        NavigationView {
        VStack(alignment: .leading , spacing: 2) {
            VStack { // (alignment: .leading , spacing: 2)
                VStack { // (alignment: .leading , spacing: 2)
                    
                    TextField("Titre carte :",
                              text: $item.leTitre  //,
//                              format: .name(style: .medium)
                              )
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.secondary)
                        .border(.secondary)
                        .focused($estEntréeActive)
                        .submitLabel(.done)
                        .onSubmit {print("Submit")}
                        .toolbar {
                            ToolbarItemGroup(placement:   .keyboard) {
                                Button("Clic") { estEntréeActive = false }
                                }
                            }

                    Stepper("\(item.valeur) points", value: $item.valeur, in: 0...10, step: 1)
                        .padding(.horizontal)
//                    let valeurLocale = item.valeur
                    Text("item.valeur : \(item.valeur) ") //  valeurLocale : \(valeurLocale)")
//                    + Text( item.valeur == valeurLocale ? "🆗" : "〰️")
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
            
            // Définir un lieu sur la carte
            VueEditionCarte(
                item: item,
                sectionGéographique: $régionItem,
                lesLieux: $locations,
                lieuEnCoursEdition: $leLieuÉdité
                )

        

             
        }
        .isHidden(item.isDeleted || item.isFault ? true : false)
        .opacity(item.valide ? 1.0 : 0.1)
        
        
        
        
        .sheet(isPresented: $feuilleAffectationGroupesPresentée) {
            Text("Rallier les groupes")
            
            VueAffectationItemGroupe(lesGroupesChoisis: item.lesGroupes ) {
//              print("⚾︎⚾︎⚾︎⚾︎⚾︎⚾︎ Les groupes retenus sont :", $0)
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
                    
                    if !locations.isEmpty {
                        item.longitude = (locations.last?.coordonnées.longitude)! //?? 0
                        item.latitude  = (locations.last?.coordonnées.latitude)! // ?? 0
                        }
                     
                        persistance.sauverContexte("Item")
                        
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
            item.rallier(contexte:contexte, communauté: groupes )
            }
        persistance.sauverContexte("Groupe")
        }
    
}

