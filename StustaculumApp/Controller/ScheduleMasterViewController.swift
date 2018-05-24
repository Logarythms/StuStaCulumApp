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
    
    var performances = [Performance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkingManager.getPerformances(completion: performancesLoaded)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return [] }
        guard let vc2 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return [] }
        guard let vc3 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return [] }
        guard let vc4 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return [] }

        let sscDays = Util.getSSCDays()

        vc1.day = sscDays[0]
        vc1.performances = performances

        vc2.day = sscDays[1]
        vc2.performances = performances

        vc3.day = sscDays[2]
        vc3.performances = performances

        vc4.day = sscDays[3]
        vc4.performances = performances

        return [vc1, vc2, vc3, vc4]
    }
    
    func performancesLoaded(performances: [Performance]) {
        self.performances = performances.filter({$0.show})
    }
    
}
