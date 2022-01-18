//Arachante
// michel  le 18/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI


// pas (encore ?) utilisée en tant que fichier séparé

var barreOutilsGroupe: some View {
    
    
    
    HStack {
        Spacer()

        Button(action: { }) {
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



