//
//  ScheduleHostView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI
import PagerTabStripView
import AlertToast

struct ScheduleView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            PagerTabStripView {
                ForEach(dataManager.dayslots) { dayslot in
                    DayView(dayslot: dayslot)
                        .pagerTabItem {
                            Text(dayslot.day.getShortWeekDay())
                        }
                        .background(Color("TimeCell"))
                        
                }
            }
            .pagerTabStripViewStyle(.segmentedControl(backgroundColor: .accentColor, padding: EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)))
            .navigationTitle("Zeitplan")
        }
        .navigationViewStyle(.stack)
        .toast(isPresenting: $dataManager.notificationEnabledToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .systemImage("bell.fill", .red), title: "Benachrichtigung An")
        }
        .toast(isPresenting: $dataManager.notificationDisabledToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .systemImage("bell.slash.fill", .red), title: "Benachrichtigung Aus")
        }
        .toast(isPresenting: $dataManager.notificationErrorToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "Fehler")
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
