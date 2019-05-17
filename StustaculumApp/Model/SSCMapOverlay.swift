//
//  SSCMapOverlay.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 17.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit
import MapKit

class SSCMapOverlay: NSObject, MKOverlay {
    
    var coordinate = CLLocation(latitude: 48.183145, longitude: 11.611429).coordinate
    var boundingMapRect: MKMapRect
    
    override init() {
        let pointsScale = MKMapPointsPerMeterAtLatitude(48.183145)
        let origin = CLLocationCoordinate2D(latitude: 48.184620, longitude: 11.607792)
        boundingMapRect = MKMapRect(origin: MKMapPoint(origin), size: MKMapSize(width: 535 * pointsScale, height: 337 * pointsScale))
    }
    
}
