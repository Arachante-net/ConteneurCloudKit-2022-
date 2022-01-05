//Arachante
// michel  le 18/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI

// pas (encore ?) utilisée
struct BarreOutilsItem: View {
    var body: some View {
        Text("")
            Button(action: { print("")}) {
                VStack {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Rallier").font(.caption)
                    }
                }


            Spacer()

            Button(action: {
              print("")
                }
                ) { Text("Sauver") }
                .buttonStyle(.borderedProminent)
    }
}

struct BarreOutilsItem_Previews: PreviewProvider {
    static var previews: some View {
        BarreOutilsItem()
    }
}
