//
//  ScheduleView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct ScheduleMainView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScheduleMasterViewController
    
    func makeUIViewController(context: Context) -> ScheduleMasterViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "scheduleMainView") as! ScheduleMasterViewController
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScheduleMasterViewController, context: Context) {
        
    }
    
}

struct ScheduleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScheduleDayViewController
    
    let day: SSCDay
    
    func makeUIViewController(context: Context) -> ScheduleDayViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "dayViewController") as! ScheduleDayViewController
        
        viewController.day = day
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScheduleDayViewController, context: Context) {
        
    }
}
