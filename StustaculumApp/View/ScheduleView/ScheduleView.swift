//
//  ScheduleHostView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI
import PagerTabStripView

struct ScheduleView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            PagerTabStripView {
                ForEach(dataManager.days) { day in
                    DayView(day: day)
                        .pagerTabItem {
                            Text(day.getShortWeekDay())
                        }
                        .background(Color("TimeCell"))
                        
                }
            }
            .pagerTabStripViewStyle(.segmentedControl(backgroundColor: .accentColor, padding: EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)))
            .navigationTitle("Zeitplan")
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}

class ScheduleHostingViewController: UIHostingController<ScheduleView> {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ScheduleView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
