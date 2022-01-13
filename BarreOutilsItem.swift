//Arachante
// michel  le 18/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI

//
//var favoritesButton: some View {
//    Button(action: toggleFavorites) {
//        if showingFavorites {
//            Text("Show all locations")
//        } else {
//            Text("Show only favorites")
//        }
//    }
//}
// pas (encore ?) utilisée

var barreOutilsItem: some View {
//    @Binding var feuilleModificationItemPresentée:Bool //= false
    return HStack {
        Text("MD")
//            Button(action: { print("")}) {
//                VStack {
//                    Image(systemName: "tray.and.arrow.down.fill")
//                    Text("Rallier").font(.caption)
//                    }
//                }
//
//
//            Spacer()
//
//            Button(action: {
//              print("")
//                }
//                ) { Text("Sauver") }
//                .buttonStyle(.borderedProminent)
//        }
    
    
                    Spacer()
    
                    Button(action: {
//                        feuilleModificationItemPresentée.toggle()
                        
                    }) {
    //                  Label("Modifier", systemImage: "square.and.pencil").labelStyle(.titleAndIcon)
                        VStack {
                            Image(systemName: "square.and.pencil")
                            Text("Modifier").font(.caption)
                            }
                      }.buttonStyle(.borderedProminent)
    
                    Button(role: .destructive, action: {  }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("Supprimer").font(.caption)
                            }
                      }.buttonStyle(.borderedProminent)
    
                    Spacer()
    
                    }

    
    
    }



