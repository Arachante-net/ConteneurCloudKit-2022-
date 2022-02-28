//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit

/// Afficher  sur une carte un groupe d'item representés par des annotations
struct VueCarteGroupe: View {
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    @ObservedObject var groupe: Groupe

    
    
    init(_ unGroupe: Groupe)  {
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        }
    
  var body: some View {
  
      Map(coordinateRegion: $groupe.régionEnglobante, annotationItems: groupe.lesAnnotations ) { annotation in
          MapAnnotation(coordinate: annotation.coordonnées, anchorPoint: CGPoint(x: 0.5, y: 1)) {
              // Ceci est l'annotation de mon item principal
              let moi  = annotation.itemID == groupe.principal?.id
              VStack {
                  HStack {
                      Text(annotation.libellé)
                          .fixedSize(horizontal: false, vertical: true)
//                          .multilineTextAlignment(.center)
                          .font(.caption2)
                          .foregroundColor( Color(annotation.couleur.inverser) )
                      }
                  Text(annotation.message)
                      .font(.system(size: 8, weight: .light, design: .rounded))
//                      .frame(maxWidth: 100)
                      .fixedSize(horizontal: false, vertical: true)
                      .lineLimit(2)
                      .truncationMode(.tail)
//                      .multilineTextAlignment(.center)
                      .background(RoundedRectangle(cornerRadius: 4).fill(Color(UIColor.systemBackground).opacity(0.75)))
//                      .background(Color(UIColor.systemBackground).opacity(0.75)) //    Color.gray.opacity(0.75))
                      .foregroundColor( Color(UIColor.systemBackground.inverser) )
                  HStack {
                      Text("\(annotation.valeur)").fontWeight(.heavy)
                      + Text(" /\(groupe.valeur)").fontWeight(.thin)
                      } .font(.body).foregroundColor(.accentColor).padding(.bottom)
                  }
                  .padding(5)
                  .foregroundColor(.primary)
                  .background(
                        Blason()
                            .stroke(moi ? .primary : .secondary, lineWidth: moi ? 1.7 : 1).opacity(0.75)
                            .background(
                                Blason()
                                    .fill(Color(annotation.couleur).opacity(0.85))
                                    .shadow(color: .black, radius: moi ? 5 : 0.5, x: moi ? 4 : 0,y: moi ? 2 :0)
                                )
                        )
          }
      }//.isHidden(!visible, remove: false)
      .onAppear() { print("onAppear ###### Map")}
      
  }
}


struct Blason_: Shape {
    func path(in rect: CGRect) -> Path {
        let d = rect.height / 3
        var path = Path()
            path.move(   to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-d))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY-d))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

     return path
    }
}
