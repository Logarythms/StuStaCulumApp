//
//  ScheduleHostView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI
import PagerTabStripView
struct ScheduleHostView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            PagerTabStripView {
                ForEach(dataManager.days) { day in
                    NewScheduleView(day: day)
                        .pagerTabItem {
                            Text(day.getShortWeekDay())
                        }
                        
                }
            }
            .background(Color("UIColor.secondarySystemGroupedBackground"))
            .pagerTabStripViewStyle(.segmentedControl(backgroundColor: .accentColor))
//            PagerTabStripView {
//                ForEach(dataManager.days) { day in
//                    ScheduleView(day: day)
//                        .pagerTabItem {
//                            Text(day.getShortWeekDay())
//                        }
//                }
//            }
//            .pagerTabStripViewStyle(.segmentedControl(backgroundColor: Color(Util.ssc2022Color)))
            .navigationTitle("Zeitplan")
        }
    }
}

struct TitleNavBarItem: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(Color.gray)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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
