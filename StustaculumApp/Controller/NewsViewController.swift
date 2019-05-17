//
//  NewsViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 15.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {
    
    let dataManager = DataManager.shared
    let notificationCenter = NotificationCenter.default
    
    var newsEntries = [NewsEntry]()
    var upcomingPerformances: (Performance, Performance, Performance, Performance)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(updateNews), name: Notification.Name("fetchComplete"), object: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        
        tableView.backgroundColor = Util.backgroundColor
        tableView.tableFooterView = UIView()
        
        updateNews()
    }
    
    @objc
    func updateNews() {
        self.newsEntries = dataManager.getNews()
        getUpcomingPerformances()
        tableView.reloadData()
    }
    
    func getUpcomingPerformances() {
        let performances = dataManager.getAllPerformances().filter {
            $0.date >= Date()
        }
        let sortedPerformances = performances.sorted {
            $0.date <= $1.date
        }
        let upcomingDadaPerformance = sortedPerformances.first {
            $0.location == 1
        }
        let upcomingAtriumPerformance = sortedPerformances.first {
            $0.location == 2
        }
        let upcomingHallePerformance = sortedPerformances.first {
            $0.location == 3
        }
        let upcomingZeltPerformance = sortedPerformances.first {
            $0.location == 4
        }
        guard   let p1 = upcomingDadaPerformance,
                let p2 = upcomingAtriumPerformance,
                let p3 = upcomingHallePerformance,
                let p4 = upcomingZeltPerformance else {
                
                return
        }
        self.upcomingPerformances = (p1, p2, p3, p4)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsEntries.isEmpty {
            return 0
        }
        if section == 0 || section == 2 {
            return 1
        } else {
            return newsEntries.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as? LogoCell else {
                return UITableViewCell()
            }
            guard let image = dataManager.getCurrentLogo() else {
                return UITableViewCell()
            }
            
            let size = cell.logoImageView.bounds.size
            let scaledImage = image.af_imageAspectScaled(toFill: size)
            cell.logoImageView.image = scaledImage
            
            return cell
        }
        
        if indexPath.section == 1 {
            let newsEntry = newsEntries[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell else {
                return UITableViewCell()
            }
            cell.titleLabel.text = newsEntry.title
            cell.descriptionLabel.text = newsEntry.description
            
            return cell
        }
        
        if indexPath.section == 2 {
            guard   let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingEventsCell", for: indexPath) as? UpcomingEventsCell,
                    let events = upcomingPerformances else {
                    
                    return UITableViewCell()
            }
            let upcomingString = events.0.getEventDescription() + "\n\n" + events.1.getEventDescription() + "\n\n" + events.2.getEventDescription() + "\n\n" + events.3.getEventDescription()
            cell.upcomingEventsLabel.text = upcomingString
            
            return cell
        }
        return UITableViewCell()
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 250
//        } else {
//            return 200
//        }
//    }
    
}
