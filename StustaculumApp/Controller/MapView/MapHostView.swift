//
//  MapHostView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct MapHostView: View {
    var body: some View {
        NavigationView {
            MapView()
                .navigationTitle("Karte")
        }
    }
}

//struct MapHostView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapHostView()
//    }
//}

class MapViewHostingController: UIHostingController<MapHostView> {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: MapHostView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
