//
//  MapViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var locationCategories = [LocationCategory]()
    var locations = [Location]()
    
    let initialLocation = CLLocation(latitude: 48.18311, longitude: 11.611556)
    let regionRadius: CLLocationDistance = 400

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        centerMapOnLocation(initialLocation)
        NetworkingManager.getLocationCategories(completion: locationCategoriesLoaded)
        NetworkingManager.getLocations(completion: locationsLoaded)
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationCategoriesLoaded(categories: [LocationCategory]) {
        self.locationCategories = categories
    }
    
    func locationsLoaded(locations: [Location]) {
        self.locations = locations
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
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let sscAnnotation = annotation as? SSCAnnotation else { return nil }
        let identifier = "marker"
        
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
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! SSCAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        annotation.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}
