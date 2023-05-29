//
//  SSCMapOverlayView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 17.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit
import MapKit

class SSCMapOverlayView: MKOverlayRenderer {
    let overlayImage = UIImage(named: "mapOverlay2023")
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let imageReference = overlayImage?.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
    }
}
