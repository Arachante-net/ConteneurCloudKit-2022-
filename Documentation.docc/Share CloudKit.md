#  Pour qu'une proposition de partage ouvre l'appli :

positioner CKSharingSupported à true dans le fichier info.plist.
Depuis XCode 13, si ce fichier n'est pas accessible depuis le navigateur , il faut ajouter à la main la ligne :

<key>CKSharingSupported</key> <true/>

à info.plist

au redemarage la modif est visible depuis XCode
