//Arachante
// michel  le 09/03/2021
// pour le projet  Nimbus
//
//  2022
//
import SwiftUI

struct Blason: Shape {
    func path(in rect: CGRect) -> Path {
        
        // Environnement
        let x       = rect.origin.x
        let y       = rect.origin.y
        let largeur = rect.size.width
        let hauteur = rect.size.height
    
        let milieuHorizontal = x + (largeur / 2)
        let basVertical      = y + hauteur
        
        let pointBas         = CGPoint(x: milieuHorizontal, y: basVertical)
        
        let rayonHaut = 5.0

        // Réglages de la forme de la pointe
        let proportionBase:CGFloat = 3/4
        let courburePointe:CGFloat = 2/3  // petit = pointu
        let courbureBord:CGFloat   = 9/10 //

        let pointBaseGauche = CGPoint(x: x              , y: (y + (hauteur * proportionBase)))
        let pointBaseDroite = CGPoint(x: largeur        , y: (y + (hauteur * proportionBase)))

        let path = Path { p in
            p.move(to: pointBas)
            p.addCurve(to: pointBaseGauche,
                control1: CGPoint(x: milieuHorizontal, y: (y + (hauteur * courburePointe))),
                control2: CGPoint(x: x               , y: (y + (hauteur * courbureBord ))))
            p.addLine(to: CGPoint(x:0      ,y:rayonHaut)) //hauteur))
            p.addArc(center: CGPoint(x:rayonHaut , y:rayonHaut) , radius: rayonHaut, startAngle: .degrees(180), endAngle: .degrees(-90), clockwise: false)
            p.addLine(to: CGPoint(x:largeur-rayonHaut,y:0)) //hauteur))
            p.addArc(center: CGPoint(x:largeur-rayonHaut , y:rayonHaut) , radius: rayonHaut, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: pointBaseDroite)
            p.addCurve(to: pointBas,
                control1: CGPoint(x: (x + largeur)   , y: (y + (hauteur * courbureBord  ))),
                control2: CGPoint(x: milieuHorizontal, y: (y + (hauteur * courburePointe))))
        }
        return path
    }
    
}

