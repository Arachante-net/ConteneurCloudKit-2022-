//Arachante
// michel  le 18/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI


// Si utilisée en tant que fichier séparé, implique de passer/lier les arguments (feuille, favoris, groupe)

struct BarreOutilsGroupe:  View {

    @Binding var feuilleModificationPresentée:Bool
    @Binding var estFavoris:Bool
    
    //    @ObservedObject var groupe: Groupe // le StateObject est dans VuedetailGroupe
    @Binding var groupe:Groupe
    
    @EnvironmentObject private var configUtilisateur : Utilisateur

    var body: some View {

        HStack {
            Spacer()

            Button(action: {
                configUtilisateur.inverserFavoris(groupe, jeSuisFavoris: &estFavoris)
                print("❤️ MàJ liste des favoris :", configUtilisateur.listeFavoris, "devient", estFavoris)
                
            }) {
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(estFavoris ? .red : .secondary)
                    Text("Favoris").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
            
            
            
            Button(action: { feuilleModificationPresentée.toggle()  }) {
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
    }



