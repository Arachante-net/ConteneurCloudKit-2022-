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
//            Text(annotation.libellé)
//                .foregroundColor(.black)
//                .background(Color(red: 1, green: 1, blue: 0) )
//            RoundedRectangle(cornerRadius: 7.0)
//                .stroke(.red, lineWidth: 4.0)
//                .background(Color(annotation.couleur)) //      Color(red: 1, green: 1, blue: 0).opacity(0.5) )
//                .frame(width: 30, height: 30)
//                .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
              VStack {
                  Text(annotation.libellé)
                      .fixedSize(horizontal: false, vertical: true)
                      .multilineTextAlignment(.center)
                      .background(Color.black)
                  Text(annotation.message).font(.caption2)
                  Text("\(annotation.valeur)").bold().font(.body).foregroundColor(.accentColor)
                  }
              .padding(5) //.vertical)
//                .frame(width: 300, height: 200)
                .background(Blason()//.stroke(lineWidth:0.5)
                                .fill(Color(annotation.couleur))
                                .opacity(0.75)
                                .clipShape(Blason())
                                .shadow(radius: 3))


            
            }
      }//.isHidden(!visible, remove: false)
      .onAppear() { print("onAppear ###### Map")}
      
  }
}


struct Blason: Shape {
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
