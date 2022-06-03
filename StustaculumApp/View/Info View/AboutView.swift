//
//  AboutView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("Stustaculum App")
            } header: {
                Text("App")
                    .font(.title3)
                    .fontWeight(.heavy)
            }
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Section {
                    Text(appVersion)
                } header: {
                    Text("Version")
                        .font(.title3)
                        .fontWeight(.heavy)
                }
                
            }
            Section {
                Text("Camille Mainz")
            } header: {
                Text("Entwickler")
                    .font(.title3)
                    .fontWeight(.heavy)
            }
            Section {
                Text("Für den Inhalt der App ist alleinig der Verein \"Kulturleben in der Studentenstadt e.V\" verantwortlich.")
            } header: {
                Text("Haftungsausschluss")
                    .font(.title3)
                    .fontWeight(.heavy)
            }
            
        }
        .navigationTitle("Über diese App")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
