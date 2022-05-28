//
//  FavouritesMasterViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FavouritesMasterViewController: ButtonBarPagerTabStripViewController {
    
    weak var vc1: ScheduleDayViewController!
    weak var vc2: ScheduleDayViewController!
    weak var vc3: ScheduleDayViewController!
    weak var vc4: ScheduleDayViewController!
    
    var selectedIndex = 0
    var initialLoad = true
    
    override func viewDidLoad() {
        loadViewControllers()
        super.viewDidLoad()
        //        containerView.isScrollEnabled = false
        
        buttonBarView.backgroundColor = Util.backgroundColor
        buttonBarView.tintColor = .white
        
        buttonBarView.selectedBar.backgroundColor = UIColor(red:0.67, green:0.04, blue:0.20, alpha:1.0)
        settings.style.buttonBarHeight = 5
        
        settings.style.buttonBarItemBackgroundColor = Util.backgroundColor
        
        containerView.backgroundColor = Util.backgroundColor
        self.view.backgroundColor = Util.backgroundColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if initialLoad {
            self.moveToViewController(at: selectedIndex, animated: false)
            initialLoad = false
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [self.vc1, self.vc2, self.vc3, self.vc4]
    }
    
    func loadViewControllers() {
        guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc2 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc3 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        guard let vc4 = storyboard?.instantiateViewController(withIdentifier: "dayViewController") as? ScheduleDayViewController else { return }
        
        let sscDays = DataManager.shared.days
        guard !sscDays.isEmpty && sscDays.count == 4 else { return }
        
        vc1.day = sscDays[0]
        vc1.isFavouritesController = true
        
        vc2.day = sscDays[1]
        vc2.isFavouritesController = true
        
        vc3.day = sscDays[2]
        vc3.isFavouritesController = true
        
        vc4.day = sscDays[3]
        vc4.isFavouritesController = true
        
        self.vc1 = vc1
        self.vc2 = vc2
        self.vc3 = vc3
        self.vc4 = vc4
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        if progressPercentage >= 1.0 && !indexWasChanged {
            for index in 0..<4 {
                let c = viewControllers[index]
                if !c.isViewLoaded {
                    c.loadViewIfNeeded()
                }
            }
        }
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
    }

}
