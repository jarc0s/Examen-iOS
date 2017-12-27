//
//  MapaPlacesViewController.swift
//  Exa_Swift
//
//  Created by Juan on 26/12/17.
//  Copyright © 2017 Arkos. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapaPlacesViewController: UIViewController, CLLocationManagerDelegate {

    
    var likelyPlaces: [GMSPlace] = []
    private let locationManager: CLLocationManager = CLLocationManager()
    private var userLocation: CLLocation = CLLocation()
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        listLikelyPlaces()
        
        
        /*let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 13.0)
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        */
        // Creates a marker in the center of the map.
        /*let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func loadView() {
     // Create a GMSCameraPosition that tells the map to display the
     // coordinate -33.86,151.20 at zoom level 6.
     let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
     let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
     mapView.isMyLocationEnabled = true
     view = mapView
     
     // Creates a marker in the center of the map.
     let marker = GMSMarker()
     marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
     marker.title = "Sydney"
     marker.snippet = "Australia"
     marker.map = mapView
     }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /*let latestLocation: AnyObject = locations[locations.count - 1]
        userLocation = locations.last!
        print(String(format: "%.4f",latestLocation.coordinate.latitude))
        print(String(format: "%.4f",latestLocation.coordinate.longitude))*/
        
        //let userLocation = locations.last
        //let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        /*let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        locationManager.stopUpdatingLocation()
        */
        //listLikelyPlaces()
        //locationManager.stopUpdatingLocation()
        
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func listLikelyPlaces() {
        print(likelyPlaces)
        for myPlace:GMSPlace in likelyPlaces {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: myPlace.coordinate.latitude, longitude: myPlace.coordinate.longitude)
            marker.title = myPlace.name
            marker.map = mapView
        }
        
    }

}

// Delegates to handle events for the location manager.
/*extension MapaPlacesViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        //listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}*/
