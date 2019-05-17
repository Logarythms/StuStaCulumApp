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
        
        notificationCenter.addObserver(self, selector: #selector(updateLocations), name: Notification.Name("fetchComplete"), object: nil)
        
        mapView.delegate = self
        
        centerMapOnLocation(initialLocation)
        
//        updateLocations()
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
    
    @objc
    func updateLocations() {
        self.locations = dataManager.getLocations()
        addLocationsToMap()
    }
    
    func addLocationsToMap() {
        var annotations = [SSCAnnotation]()
        for location in locations {
            let annotation = SSCAnnotation(title: location.shortName, coordinate: Util.getCoordinatesFor(location))
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let sscAnnotation = annotation as? SSCAnnotation else { return nil }
        let identifier = "marker"
        
        if #available(iOS 11, *) {
            var view: MKMarkerAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = sscAnnotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: sscAnnotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return view
        } else {
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = sscAnnotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: sscAnnotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! SSCAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        annotation.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is SSCMapOverlay {
            return SSCMapOverlayView(overlay: overlay)
        }
        
        return MKOverlayRenderer()
    }
    
}
