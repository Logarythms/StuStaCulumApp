//
//  PerformanceDetailViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PerformanceDetailViewController: UIViewController {
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var artistImageView: UIImageView!
    
    var performance: Performance!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArtistImage()
        setLabelTexts()
        self.navigationItem.title = performance.artist!
    }
    
    func setLabelTexts() {
        self.genreLabel.text = performance.genre!
        
        self.descriptionLabel.attributedText = performance.description!.htmlAttributed(using: .systemFont(ofSize: 13))
        
        self.startTimeLabel.text = getFormattedDateStringFor(performance.date)
        self.endTimeLabel.text = getFormattedDateStringFor(Util.getEndOfPerformance(performance))
    }
    
    func getFormattedDateStringFor(_ date: Date) -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func loadArtistImage() {
        guard let imageURL = performance.imageURL else { return }
        guard let httpsURL = Util.httpsURLfor(imageURL) else { return }
        
        Alamofire.request(httpsURL).responseImage { (response) in
            if let image = response.result.value {
                let size = self.artistImageView.bounds.size
                let scaledImage = image.af_imageAspectScaled(toFit: size)
                self.artistImageView.image = scaledImage
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
