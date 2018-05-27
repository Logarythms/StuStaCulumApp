//
//  AboutViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class AboutMasterViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Util.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aboutCell: UITableViewCell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell") {
            aboutCell = cell
        } else {
            aboutCell = UITableViewCell(style: .default, reuseIdentifier: "aboutCell")
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                aboutCell.textLabel?.text = "AGBs"
            } else {
                aboutCell.textLabel?.text = "Über die App"
            }
        } else {
            if indexPath.row == 0 {
                aboutCell.textLabel?.text = "Website"
            } else if indexPath.row == 1 {
                aboutCell.textLabel?.text = "Facebook-Seite"
            } else {
                aboutCell.textLabel?.text = "Twitter-Seite"
            }
        }
        return aboutCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "agbSegue", sender: self)
            } else {
                self.performSegue(withIdentifier: "aboutSegue", sender: self)
            }
        } else {
            if indexPath.row == 0 {
                UIApplication.shared.open(URL(string: "https://www.stustaculum.de")!, options: [:]) { (_) in
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else if indexPath.row == 1 {
                UIApplication.shared.open(URL(string: "https://www.facebook.com/StuStaCulum/")!, options: [:]) { (_) in
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                UIApplication.shared.open(URL(string: "https://twitter.com/stustaculum")!, options: [:]) { (_) in
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Infos"
        } else {
            return "Links"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = Util.backgroundColor
            view.textLabel?.backgroundColor = .clear
            view.textLabel?.textColor = .white
        }
    }


}
