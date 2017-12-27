//
//  ViewController.swift
//  Exa_Swift
//
//  Created by Juan on 25/12/17.
//  Copyright © 2017 Arkos. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import SwiftyJSON
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation



class ViewController: UIViewController, LoginButtonDelegate, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var userLocation: CLLocation = CLLocation()
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var placesClient: GMSPlacesClient!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var contentViewFbButton: UIView!
    @IBOutlet weak var btnContinuar: UIButton!
    @IBOutlet weak var lblUserFB: UILabel!
    @IBOutlet weak var imgUserFB: UIImageView!
    @IBOutlet weak var viewContentUserFB: UIView!
    @IBOutlet weak var viewContentInicio: UIView!
    
    var myPlacesDictionary = [Dictionary<String, String>]()
    
    struct FBProfileRequest: GraphRequestProtocol {
        typealias Response = GraphResponse
        
        var graphPath = "/me"
        var parameters: [String : Any]? = ["fields" : "email, first_name, last_name, picture.type(large)"]
        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = 2.7
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        //loginButton.center = contentViewFbButton.center
        loginButton.delegate = self
        loginButton.frame(forAlignmentRect: contentViewFbButton.frame)
        contentViewFbButton.addSubview(loginButton)
        //view.addSubview(loginButton)
        
        
        if let token = AccessToken.current{
            fetchProfile()
        }else{
            self.viewContentInicio.isHidden = false
        }
        
        placesClient = GMSPlacesClient.shared()
        
        // Request authorization for location and configuration of the location manager
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func fetchProfile(){
        print("fetch Profile")
        let request = FBProfileRequest()
        request.start { (httpResponse, result) in
            switch result {
            case .success(let response):
                
                if let responseDictionary = response.dictionaryValue {
                    let json = JSON(responseDictionary)
                    print("json: \(json)")
                    print(json["first_name"].stringValue)
                    self.lblUserFB.text = "\(json["first_name"].stringValue) \(json["last_name"].stringValue)"
                    let url = URL(string: json["picture"]["data"]["url"].stringValue)
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.imgUserFB.image = UIImage(data: data!)
                }
                
                
                self.viewContentUserFB.isHidden = false
                self.viewContentInicio.isHidden = true
                self.btnContinuar.isHidden = false
            case .failed(let error):
                
                let alert = UIAlertController(title: "Aviso",
                                              message: "Ocurrió un error, intenta de nuevo",
                                              preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action) -> Void in })
                
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                
                self.viewContentInicio.isHidden = false
                self.btnContinuar.isHidden = true
                self.viewContentUserFB.isHidden = true
                let loginManager = LoginManager()
                loginManager.logOut()
                AccessToken.current = nil
            }
        }
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("complete login")
        fetchProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
    @IBAction func continuar(_ sender: UIButton) {
        
        
    }
    
    /*@IBAction func pickPlace(_ sender: UIButton) {
        //let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let center = CLLocationCoordinate2D(latitude:userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.nameLabel.text = place.name
                self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
            } else {
                self.nameLabel.text = "No place selected"
                self.addressLabel.text = ""
            }
        })
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        userLocation = locations.last!
        print(String(format: "%.4f",latestLocation.coordinate.latitude))
        print(String(format: "%.4f",latestLocation.coordinate.longitude))
        
        listLikelyPlaces()
        locationManager.stopUpdatingLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        myPlacesDictionary.removeAll()
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    var emptyDict: [String: String] = [:]
                    for typePlace in place.types{
                        if typePlace == "restaurant"{
                            print("place.name: \(place.name)")
                            self.likelyPlaces.append(place)
                            break;
                        }
                    }
                }
            }
            
            print(self.myPlacesDictionary)
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSelect" {
            if let nextViewController = segue.destination as? ListadoPlacesViewController {
                nextViewController.likelyPlaces = likelyPlaces
                nextViewController.userLocation = userLocation
            }
        }
    }

}

