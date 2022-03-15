//Arachante
// michel  le 30/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2022
//

import Foundation
import Combine
//import CloudKit
//import UIKit

class Causeur : ObservableObject {
    
//@Published var message: String

    
static let verbes = [
    "abandonner",
    "accepter",
    "accompagner",
    "acheter",
    "adorer",
    "agir",
    "aider",
    "aimer",
    "ajouter",
    "aller",
    "amener",
    "amuser",
    "annoncer",
    "apercevoir",
    "apparaître",
    "appeler",
    "apporter",
    "apprendre",
    "approcher",
    "arranger",
    "arrêter",
    "arriver",
    "asseoir",
    "assurer",
    "attaquer",
    "atteindre",
    "attendre",
    "avancer",
    "avoir",
    "baisser",
    "battre",
    "boire",
    "bouger",
    "brûler",
    "cacher",
    "calmer",
    "casser",
    "cesser",
    "changer",
    "chanter",
    "charger",
    "chercher",
    "choisir",
    "commencer",
    "comprendre",
    "compter",
    "conduire",
    "connaître",
    "continuer",
    "coucher",
    "couper",
    "courir",
    "couvrir",
    "craindre",
    "crier",
    "croire",
    "danser",
    "décider",
    "découvrir",
    "dégager",
    "demander",
    "descendre",
    "désoler",
    "détester",
    "détruire",
    "devenir",
    "deviner",
    "devoir",
    "dire",
    "disparaître",
    "donner",
    "dormir",
    "échapper",
    "écouter",
    "écrire",
    "éloigner",
    "embrasser",
    "emmener",
    "empêcher",
    "emporter",
    "enlever",
    "entendre",
    "entrer",
    "envoyer",
    "espérer",
    "essayer",
    "être",
    "éviter",
    "excuser",
    "exister",
    "expliquer",
    "faire",
    "falloir",
    "fermer",
    "filer",
    "finir",
    "foutre",
    "frapper",
    "gagner",
    "garder",
    "glisser",
    "habiter",
    "ignorer",
    "imaginer",
    "importer",
    "inquiéter",
    "installer",
    "intéresser",
    "inviter",
    "jeter",
    "jouer",
    "jurer",
    "lâcher",
    "laisser",
    "lancer",
    "lever",
    "lire",
    "maintenir",
    "manger",
    "manquer",
    "marcher",
    "marier",
    "mener",
    "mentir",
    "mettre",
    "monter",
    "montrer",
    "mourir",
    "naître",
    "obliger",
    "occuper",
    "offrir",
    "oser",
    "oublier",
    "ouvrir",
    "paraître",
    "parler",
    "partir",
    "passer",
    "payer",
    "penser",
    "perdre",
    "permettre",
    "plaire",
    "pleurer",
    "porter",
    "poser",
    "pousser",
    "pouvoir",
    "préférer",
    "prendre",
    "préparer",
    "présenter",
    "prévenir",
    "prier",
    "promettre",
    "proposer",
    "protéger",
    "quitter",
    "raconter",
    "ramener",
    "rappeler",
    "recevoir",
    "reconnaître",
    "réfléchir",
    "refuser",
    "regarder",
    "rejoindre",
    "remarquer",
    "remettre",
    "remonter",
    "rencontrer",
    "rendre",
    "rentrer",
    "répéter",
    "répondre",
    "reposer",
    "reprendre",
    "ressembler",
    "rester",
    "retenir",
    "retirer",
    "retourner",
    "retrouver",
    "réussir",
    "réveiller",
    "revenir",
    "rêver",
    "revoir",
    "rire",
    "risquer",
    "rouler",
    "sauter",
    "sauver",
    "savoir",
    "sembler",
    "sentir",
    "séparer",
    "serrer",
    "servir",
    "sortir",
    "souffrir",
    "sourire",
    "souvenir",
    "suffire",
    "suivre",
    "taire",
    "tendre",
    "tenir",
    "tenter",
    "terminer",
    "tirer",
    "tomber",
    "toucher",
    "tourner",
    "traîner",
    "traiter",
    "travailler",
    "traverser",
    "tromper",
    "trouver",
    "tuer",
    "utiliser",
    "valoir",
    "vendre",
    "venir",
    "vivre",
    "voir",
    "voler",
    "vouloir"]
    
    let items:[Item]=[]
    
    init() {
        print("TIC TAC")
//        let timer = Timer.publish(every: 1, on: .main, in:.common).autoconnect()
//        let publisher = NotificationCenter.Publisher(center: .default, name: Notification.Name("bloup"), object:nil)
//        let delayedValuesPublisher = Publishers.Zip(verbes.publisher, timer)
//        let subscription = delayedValuesPublisher.sink {
//            print("TIC", $0.0)
//            }
//        var counter = 0
//
//        while true {
//            print("TIC")
//            counter += 1
////            sleep(UInt32.random(in: 5..<100))
//            print("TOC", counter, causer()) //item: items.randomElement() ?? Item())
//            if counter == 100 {
//                print("TAC")
//                break
//            }
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTime(UInt64(Int.random(in: 1...10)))) {
//        let pas = Date() + 1
//        let ns:UInt64 = Date().timeIntervalSinceNow
//        let interval = Date().timeIntervalSince1970
        // 1 seconde = 1_000_000_000 ns   (1 ns = 10-9 s)
//        let ns = 1_000_000_000.0
//        var intervalNanoSecondes = UInt64(Date().timeIntervalSince1970 * ns)
//        var pas = intervalNanoSecondes + UInt64(Int.random(in: Int(ns)...10*Int(ns)))
//        var maintenantSecondes = Date().timeIntervalSince1970
//        var prochainSecondes = maintenantSecondes + 10 //Double.random(in: 10...60)
//        var prochain:DispatchTime
        
//        items.forEach() {item in
//            let prochain:DispatchTime = .now() + Double.random(in: 10...60)
//            DispatchQueue.main.asyncAfter(deadline: prochain  ) {
//                print("TIC-TOC", item.leTitre,   self.causer())
//                }
//            }
      
        
//        maintenantSecondes = Date().timeIntervalSince1970
//        prochainSecondes = maintenantSecondes + Double.random(in: 10...60)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(prochainSecondes * ns) )) {
//            print("TIC-TOC", self.causer())
//            }
//
//        maintenantSecondes = Date().timeIntervalSince1970
//        prochainSecondes = maintenantSecondes + Double.random(in: 10...60)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(prochainSecondes * ns) )) {
//            print("TIC-TOC", self.causer())
//            }
        
        
    }
    
    static func causer() -> String {
        verbes.randomElement() ?? "bavasser"
        }
    
    static func causer(item:Item) {
        item.message=causer()
        }
    
    static func causer(items:[Item]) {
        print("TIC-TOC", items.count)
        items.forEach() {item in
            // en secondes,  précision à la nanoseconde
            let s10 = DispatchTimeInterval.seconds(10)    //.milliseconds(Int(time * 1000))

            let prochain:DispatchTime = .now() + s10 //Double.random(in: 10...60)
            DispatchQueue.main.asyncAfter(deadline: prochain  ) {
                print("\tTIC-TOC", item.leTitre, "|", self.causer(item:item))
                }
            }
        }
}
