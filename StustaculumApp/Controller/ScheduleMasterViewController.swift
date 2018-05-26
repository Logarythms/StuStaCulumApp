//
//  ScheduleMasterViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ScheduleMasterViewController: ButtonBarPagerTabStripViewController {
    
    weak var vc1: ScheduleDayViewController!
    weak var vc2: ScheduleDayViewController!
    weak var vc3: ScheduleDayViewController!
    weak var vc4: ScheduleDayViewController!
    
    override func viewDidLoad() {
        loadViewControllers()
        super.viewDidLoad()
        containerView.isScrollEnabled = false
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [self.vc1, self.vc2, self.vc3, self.vc4]
    }
    
    func loadViewControllers() {
        guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc2 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc3 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc4 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        
        let sscDays = Util.getSSCDays()
        vc1.day = sscDays[0]
        vc2.day = sscDays[1]
        vc3.day = sscDays[2]
        vc4.day = sscDays[3]
        
        self.vc1 = vc1
        self.vc2 = vc2
        self.vc3 = vc3
        self.vc4 = vc4
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        if progressPercentage >= 1.0 && !indexWasChanged {
            let leftIndex = self.currentIndex - 1
            let rightIndex = self.currentIndex + 1
            if leftIndex >= 0 {
                let c = viewControllers[leftIndex]
                if !c.isViewLoaded {
                    c.loadViewIfNeeded()
                }
            }
            if rightIndex < self.viewControllers.count {
                let c = viewControllers[rightIndex]
                if !c.isViewLoaded {
                    c.loadViewIfNeeded()
                }
            }
        }
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
    }
    
}
