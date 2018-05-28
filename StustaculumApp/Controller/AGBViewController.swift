//
//  AGBViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class AGBViewController: UIViewController {

    @IBOutlet weak var agbTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        agbTextView.attributedText = Util.agbString.htmlAttributed(using: .systemFont(ofSize: 13))
        agbTextView.textColor = .white
        agbTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.agbTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
