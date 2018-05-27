//
//  HowToDetailViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class HowToDetailViewController: UIViewController {
    
    @IBOutlet weak var howToTextView: UITextView!
    
    var howTo: HowTo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = howTo.title
        
        howToTextView.attributedText = howTo.description.htmlAttributed(using: .systemFont(ofSize: 13))
        howToTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
