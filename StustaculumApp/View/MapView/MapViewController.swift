//
//  MapViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var locations = [Location]()
    
    let initialLocation = CLLocation(latitude: 48.18311, longitude: 11.611556)
    let regionRadius: CLLocationDistance = 350
    
    var locationManager: CLLocationManager!
    let dataManager = DataManager.shared
    let notificationCenter = NotificationCenter.default

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 16.0, *) {
            let mapConfiguration = MKStandardMapConfiguration()
            mapConfiguration.pointOfInterestFilter = .excludingAll
            
            mapView.preferredConfiguration = mapConfiguration
        } else {
            mapView.pointOfInterestFilter = .excludingAll
        }
        mapView.delegate = self
        
        centerMapOnLocation(initialLocation)
        addOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showUserLocation()
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addOverlay() {
        let overlay = SSCMapOverlay()
        mapView.addOverlay(overlay)
    }
}

extension MapViewController: MKMapViewDelegate {
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is SSCMapOverlay {
            return SSCMapOverlayView(overlay: overlay)
        }
        
        return MKOverlayRenderer()
    }
    
}
