//
//  ScheduleHostView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct ScheduleHostView: View {
    var body: some View {
        NavigationView {
            ScheduleView()
                .navigationTitle("Zeitplan")
//                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ScheduleHostView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleHostView()
    }
}

class ScheduleHostingViewController: UIHostingController<ScheduleHostView> {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ScheduleHostView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
