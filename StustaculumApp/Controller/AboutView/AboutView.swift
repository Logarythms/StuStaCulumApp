//
//  AboutView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("AGBs") {
                        AGBView()
                    }
                    NavigationLink("Über diese App") {
                        EmptyView()
                    }
                }
                Section {
                    ForEach(dataManager.aboutURLs, id: \.0) { (name, url) in
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
//        .tint(Color(Util.ssc2022Color))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

class AboutViewHostingController: UIHostingController<AboutView> {

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AboutView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
