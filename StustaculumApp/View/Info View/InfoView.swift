//
//  AboutView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    
    let dataManager = DataManager.shared
    
    let infoURLs = [("Offizielle Website", URL(string: "https://www.stustaculum.de")!),
                     ("Instagram", URL(string: "https://instagram.com/stustaculum/")!),
                     ("Twitter", URL(string: "https://twitter.com/stustaculum")!),
                     ("Facebook", URL(string: "https://www.facebook.com/StuStaCulum/")!)]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("AGBs") {
                        AGBView()
                    }
                    NavigationLink("Über diese App") {
                        AboutView()
                    }
                }
                Section {
                    ForEach(infoURLs, id: \.0) { (name, url) in
                        LinkButton(name: name, url: url)
                    }
                } header: {
                    Text("Links")
                        .font(.title3)
                        .fontWeight(.heavy)
                }

            }
            .navigationTitle("Infos")
        }
        .navigationViewStyle(.stack)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}

class InfoViewHostingController: UIHostingController<InfoView> {

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: InfoView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
