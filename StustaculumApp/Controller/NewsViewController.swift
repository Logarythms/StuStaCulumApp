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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsEntries = dataManager.getNews()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
}
