//
//  ScheduleView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct ScheduleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScheduleMasterViewController
    
    func makeUIViewController(context: Context) -> ScheduleMasterViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "scheduleView") as! ScheduleMasterViewController
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScheduleMasterViewController, context: Context) {
        
    }
    
}
