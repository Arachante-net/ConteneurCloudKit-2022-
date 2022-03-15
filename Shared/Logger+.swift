//Arachante
// michel  le 12/03/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.2
//
//  2022
//

import Foundation
import os


// https://www.avanderlee.com/debugging/oslog-unified-logging/
extension Logger {
    private static var sousSysteme = Bundle.main.bundleIdentifier!

    static let modélisationDonnées  = Logger(subsystem: sousSysteme, category: "modélisation données")
    static let persistance          = Logger(subsystem: sousSysteme, category: "persistance")
    static let historien            = Logger(subsystem: sousSysteme, category: "historien")
    static let cyvleDeVie           = Logger(subsystem: sousSysteme, category: "cycle de vie")
    static let interfaceUtilisateur = Logger(subsystem: sousSysteme, category: "interface utilisateur")
    static let réseau               = Logger(subsystem: sousSysteme, category: "réseau")
    
/*
 Niveau              | Stocké sur disque                          | Remarques
 --------------------+--------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Debug   (gris foncé)| Non                                        | Capture des informations verbeuses pendant le développement qui ne sont utiles que pour déboguer votre code.
 Info    (gris clair)| Si collecté avec l'outil de journalisation | Capture des informations utiles, mais non essentielles, pour résoudre les problèmes.
 Notice (défaut)     | Oui, jusqu'à une limite de stockage        | Capture les informations essentielles pour résoudre les problèmes. Par exemple, capturez des informations qui pourraient entraîner un échec.
 Error        (jaune)| Oui, jusqu'à une limite de stockage        | Capture les erreurs observées lors de l'exécution de votre code.        Si un objet d'activité existe, le système capture des informations pour la chaîne de processus associée.
 Fault        (rouge)| Oui, jusqu'à une limite de stockage        | Capture des informations sur les défauts et les bogues dans votre code. Si un objet d'activité existe, le système capture des informations pour la chaîne de processus associée.
*/
}
