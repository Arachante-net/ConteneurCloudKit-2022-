//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit
import os.log

/// Afficher  sur une carte un groupe d'item representés par des annotations
struct VueCarteGroupe: View {
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    @ObservedObject var groupe: Groupe

    
    
    init(_ unGroupe: Groupe)  {
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        }
    
  var body: some View {
      GeometryReader { geometrie in

      Map(coordinateRegion: $groupe.régionEnglobante, annotationItems: groupe.lesAnnotations ) { annotation in
          MapAnnotation(coordinate: annotation.coordonnées, anchorPoint: CGPoint(x: 0.5, y: 1)) {
              // Ceci est l'annotation de mon item principal
              let moi  = annotation.itemID == groupe.principal?.id
//              GeometryReader { geometrie in
              let _ = Logger.interfaceUtilisateur.debug("Géo \(geometrie.size.width) \(geometrie.size.height)")
                  VStack {
                      HStack {
                          Text(annotation.libellé)
                              .font(.caption2)
                              .lineLimit(1)
                              .truncationMode(.tail)
                              .foregroundColor( Color(annotation.couleur.inverser) )
                          }
                      Text(annotation.message)
                          .font(.system(size: 8, weight: .light, design: .rounded))
                          .lineLimit(1)
                          .truncationMode(.tail)
                          .background(RoundedRectangle(cornerRadius: 4).fill(Color(UIColor.systemBackground).opacity(0.75)))
                          .foregroundColor( Color(UIColor.systemBackground.inverser) )
                      HStack {
                          Text("\(annotation.valeur)").fontWeight(.heavy)
                          + Text(" /\(groupe.valeur)").fontWeight(.thin)
                          }
                          .lineLimit(1)
                          .truncationMode(.tail)
                          .font(.body).foregroundColor(.accentColor).padding(.bottom)
                  }
//              }// geometrie
                  .padding(5)
                  .foregroundColor(.primary)
                  .frame(minWidth: 50, idealWidth: 100, maxWidth: 200, alignment: .center)
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
          }
      .onAppear() {
          Logger.interfaceUtilisateur.info("onAppear ###### Map")
          Logger.interfaceUtilisateur.info("M&M \(groupe.lesAnnotations.map(\.message) )")
          }
//    .aspectRatio(16/9, contentMode: .fill) //.fit)

      
  }
}


//struct Blason_: Shape {
//    func path(in rect: CGRect) -> Path {
//        let d = rect.height / 3
//        var path = Path()
//            path.move(   to: CGPoint(x: rect.minX, y: rect.minY))
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-d))
//            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
//            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY-d))
//            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//
//     return path
//    }
//}
