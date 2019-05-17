//
//  HowToMasterViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class HowToMasterViewController: UITableViewController {

    var howTos = [HowTo]()
    let dataManager = DataManager.shared
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(updateHowTos), name: Notification.Name("fetchComplete"), object: nil)
        
        tableView.backgroundColor = Util.backgroundColor
        
        updateHowTos()
    }
    
    @objc
    func updateHowTos() {
        self.howTos = dataManager.getHowTos()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howTos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let howToCell: UITableViewCell
        guard let howTo = howTos[safe: indexPath.row] else { fatalError("This should not happen") }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "howToCell") {
            howToCell = cell
        } else {
            howToCell = UITableViewCell(style: .default, reuseIdentifier: "howToCell")
        }
        howToCell.textLabel?.text = howTo.title
        
        return howToCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showHowTo" else { return }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        guard let howTo = howTos[safe: selectedIndexPath.row] else { return }
        guard let detailVC = segue.destination as? HowToDetailViewController else { return }
        
        detailVC.howTo = howTo
    }

}
