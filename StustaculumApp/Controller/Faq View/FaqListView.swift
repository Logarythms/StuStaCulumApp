//
//  FAQView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct FaqListView: View {
    
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            List(dataManager.howTos) { howTo in
                NavigationLink(howTo.title) {
                    FaqDetailView(howTo: howTo)
                }
            }
            .navigationTitle("FAQ")
        }
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FaqListView()
    }
}

class FaqViewHostingController: UIHostingController<FaqListView> {

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: FaqListView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
