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
    var newsEntries = [NewsEntry]()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Util.backgroundColor
        
        self.newsEntries = dataManager.getNews()
        tableView.reloadData()
    }
    
    func newsUpdated() {
        self.newsEntries = dataManager.getNews()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
            cell.loadLogo(dataManager.getCurrentSSC().logoURL)
            return cell
        }
        
        if indexPath.section == 1 {
            let newsEntry = newsEntries[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
            cell.textLabel?.text = newsEntry.title
            cell.detailTextLabel?.text = newsEntry.description
            
            return cell
        }
        return UITableViewCell()
    }
    
}
