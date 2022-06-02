//
//  LinkButton.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct LinkButton: View {
    
    @Environment(\.openURL) var openURL
    
    let name: String
    let url: URL
    
    var body: some View {
        Button {
            openURL(url)
        } label: {
            HStack {
                Text(name)
                Spacer()
                Image(systemName: "link.circle.fill")
            }
        }
//        .foregroundColor(Color(Util.ssc2022Color))
    }
}

//struct LinkButton_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkButton()
//    }
//}
