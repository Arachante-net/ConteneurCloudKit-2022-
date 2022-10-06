//Arachante
// michel  le 10/08/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

//import Foundation
import Network
let moniteur = NWPathMonitor()
 
func surveillerAccèsInternet() {
    moniteur.pathUpdateHandler = { accesRéseau in
        if accesRéseau.status == .satisfied {
            print("⚡️ On est connecté !")
            }
        else {
            print("⚡️ Pas de connection")
            }
        print("", accesRéseau.isExpensive)
        // isExpensive Utilisation de données cellulaires ou du WiFi acheminé via la connexion cellulaire d'un iPhone.
    }
    print("⚡️ Activation surveillance de l'accès Internet")
    
    let queue = DispatchQueue(label: "Moniteur")
    moniteur.start(queue: queue)

}

// let moniteurCellulaire = NWPathMonitor(requiredInterfaceType: .cellular) // ou .wifi ou .wiredEthernet si on veut affiner le truc

