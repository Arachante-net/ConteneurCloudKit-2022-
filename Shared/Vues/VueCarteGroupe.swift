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
    // 1er Février 3
//  @State
//    @Binding  var
    
//  @State private var région: MKCoordinateRegion
//  let annotations: [AnnotationGeographique]
    
   // 9 février
//    @Binding private var région: MKCoordinateRegion
//    @Binding var annotations: [AnnotationGeographique]?
    
    //MARK: La source de verité de groupe est VueDetailGroupe
    @ObservedObject var groupe: Groupe

    
//  let visible: Bool
//    var région:Binding<MKCoordinateRegion> {return Binding(projectedValue: groupe.régionEnglobante)}
   
//    init(région: Binding<MKCoordinateRegion> /*région:Binding<MKCoordinateRegion>*/, annotations: Binding<[AnnotationGeographique]?>) {
//    /////// 6 février /  _région =  région  //wrappedValue: région)
////      self.région      = région
//        // 9 février
////      _région = State(wrappedValue: région)
////      _région      = région //Binding<MKCoordinateRegion>(initialValue: région)
////      _annotations = annotations
//      }
    
    
    init(_ unGroupe: Groupe)  {
        _groupe = ObservedObject<Groupe>(wrappedValue : unGroupe)
        }
    
  var body: some View {
  
      Map(coordinateRegion: $groupe.régionEnglobante, annotationItems: groupe.lesAnnotations ) { annotation in
        MapAnnotation(coordinate: annotation.coordonnées) {
            Text(annotation.libellé)
                .foregroundColor(.black)
                .background(Color(red: 1, green: 1, blue: 0) )
            RoundedRectangle(cornerRadius: 7.0)
                .stroke(.red, lineWidth: 4.0)
                .background(Color(annotation.couleur)) //      Color(red: 1, green: 1, blue: 0).opacity(0.5) )
                .frame(width: 30, height: 30)
                .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
            }
      }//.isHidden(!visible, remove: false)
      .onAppear() { print("onAppear ###### Map")}
      
  }
}


