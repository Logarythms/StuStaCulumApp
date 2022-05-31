//
//  AGBView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct AGBView: View {
    var body: some View {
        ScrollView {
            Text(html: Util.agbString, size: 15)
                .padding()
                .navigationTitle("AGBs")
        }
    }
}

struct AGBView_Previews: PreviewProvider {
    static var previews: some View {
        AGBView()
    }
}
