//
//  LogoCell.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 16.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class LogoCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    
    func loadLogo(_ url: URL) {
        guard let httpsURL = Util.httpsURLfor(url) else { return }
        
        Alamofire.request(httpsURL).responseImage { (response) in
            if let image = response.result.value {
                let size = self.logoImageView.bounds.size
                let scaledImage = image.af_imageAspectScaled(toFit: size)
                self.logoImageView.image = scaledImage
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}