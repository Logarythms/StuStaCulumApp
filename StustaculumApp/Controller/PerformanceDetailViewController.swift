//
//  PerformanceDetailViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class PerformanceDetailViewController: UIViewController {
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var scheduleDayViewController: ScheduleDayViewController?
    
    var performance: Performance!
    var favourites = [Performance]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArtistImage()
        setLabelTexts()
        
        self.favouriteButton.layer.cornerRadius = 10
        self.favouriteButton.clipsToBounds = true
        
        self.navigationItem.title = performance.artist!
    }
    
    func setLabelTexts() {
        self.genreLabel.text = performance.genre!
        
        self.descriptionLabel.attributedText = performance.description!.htmlAttributed(using: .systemFont(ofSize: 13))
        self.descriptionLabel.textColor = .white
        
        self.startTimeLabel.text = getFormattedDateStringFor(performance.date)
        self.endTimeLabel.text = getFormattedDateStringFor(Util.getEndOfPerformance(performance))
        
        if self.favourites.contains(where: { (p) -> Bool in
            p == self.performance
        }) {
            favouriteButton.setTitle("Von Favoriten entfernen", for: .normal)
        } else {
            favouriteButton.setTitle("Zu Favoriten hinzufügen", for: .normal)
        }
    }
    
    func getFormattedDateStringFor(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func loadArtistImage() {
        guard let imageURL = performance.imageURL else { return }
        guard let httpsURL = Util.httpsURLfor(imageURL) else { return }
        
//        Alamofire.request(httpsURL).responseImage { (response) in
//            if let image = response.result.value {
//                let size = self.artistImageView.bounds.size
//                let scaledImage = image.af_imageAspectScaled(toFit: size)
//                self.artistImageView.image = scaledImage
//            }
//        }
        
    }
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        if let index = self.favourites.firstIndex(where: { (p) -> Bool in
            p == self.performance
        }) {
            self.favourites.remove(at: index)
            favouriteButton.setTitle("Zu Favoriten hinzufügen", for: .normal)
        } else {
            self.favourites.append(self.performance)
            favouriteButton.setTitle("Von Favoriten entfernen", for: .normal)
        }
        self.scheduleDayViewController?.favouritePerformances = self.favourites
        self.scheduleDayViewController?.saveFavourites()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
