# Provisioning

 Le \"*Provisioning*\" permet de présenter un couple matériel/appli unique.
 

## Inscription :

-   **Individual** : autorise le déploiement :

    -   App Store,

    -   Apple (Business\|School) Manager (via l\'App Store, donc validation Apple, tout en restant privée),

    -   Ad Hoc (limité à 100 par type de matériel).

-   **Organization** : déploiement sans passer par l\'Apple Store ( sans validation Apple )
     Déploiement possible sur un nombre illimité d\'appareils Apple.
     
    
## Déployer l\'application sur un matériel (Device) via :


-   **App Store** :
     Application inclue une signature liée au certificat.

-   **Réseau privé** (anciennement déploiement **In-House**) : 

    Distribuer depuis un serveur Web vers un *groupe* d\'utilisateurs faisant partie d\'une entreprise. 
    Nécessite une inscription \"Organization\". 

    Appli inclue la signature liée au certificat mais n'est pas liée à un appareil unique.

-   **Organisation Ad Hoc** :
     Sur une flotte contenant jusqu\'à 100 appareils (de type iPhone ou iPad).
     L\'appli doit être rebuildée recompilée pour la cible en incluant le certificat de la signature et l\'identifiant unique de l\'appareil. 
    Nécessite un serveur **HTTPS** pour la distribution. (ou connexion physique au Mac XCode)
     

## Prérequis :


-   Récupérer les certificats afin d\'authentifier l\'application.

-   Référencer les différents matériels (device) sur lesquels va être
    diffusée votre application.

-   Créer un identifiant pour votre application (bundle).

-   Associer votre application et les matériels cibles.

-   Créer un certificat final. Ce certificat sera installé sur la
    machine qui compile sous Xcode l\'application en mode Release
    (distribuable) afin de pouvoir l\'installer sur les matériels
    prévus.
     


 Le \"*Provisioning*\" permet d'associer les certificats d\'application et les certificats de matériel (device). 
Afin de représenter un couple matériel/appli unique.
     
    ·       Créer un profil.\
    ·       Sélectionner le \"App Id\" de l'appli , cocher le ou les
    matériels cibles.\
    Une fois le profil créé :\
    ·       Télécharger le certificat sur la machine de compilation\
    ·       cliquez sur le certificat pour l\'installer automatiquement
    dans Xcode.
