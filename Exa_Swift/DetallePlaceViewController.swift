//
//  DetallePlaceViewController.swift
//  Exa_Swift
//
//  Created by Juan on 26/12/17.
//  Copyright © 2017 Arkos. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import FacebookShare

class DetallePlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    

    var likelyPlace: GMSPlace!
    @IBOutlet weak var imagePlace: UIImageView!
    @IBOutlet weak var lblDireccionNombrePlace: UILabel!
    @IBOutlet weak var tablaProductos: UITableView!
    var dictArray = [[String:String]]()
    @IBOutlet weak var constraintHeightTableView: NSLayoutConstraint!
    var userLocation: CLLocation!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated)
        constraintHeightTableView.constant = CGFloat(80*dictArray.count)
        self.view .layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(likelyPlace)
        
        let addresStr = likelyPlace.formattedAddress?.components(separatedBy: ", ")
            .joined(separator: " ")
        
        lblDireccionNombrePlace.text = "\(likelyPlace.name) \n\(addresStr!)"
        
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: likelyPlace.placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, imageView: self.imagePlace)
                }
            }
        }
        
        let path = Bundle.main.path(forResource: "listProductos", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        
        dictArray = plist as! [[String:String]]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, imageView: UIImageView) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                imageView.image = photo;
            }
        })
    }

    @IBAction func shareViaFacebook(_ sender: UIButton) {
        let content = LinkShareContent(url:likelyPlace.website! as URL,title:likelyPlace.name)
        do {
            try ShareDialog.show(from: self, content: content)
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func openMaps(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Abrir ubicación",
                                      message: "Selecciona la opción que desees",
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "iOS Maps", style: .default, handler: { (action) -> Void in
            print("ACTION 1 selected!")
            let latitude: CLLocationDegrees = self.likelyPlace.coordinate.latitude
            let longitude: CLLocationDegrees = self.likelyPlace.coordinate.longitude
            
            let regionDistance:CLLocationDistance = 1000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.likelyPlace.name
            mapItem.openInMaps(launchOptions: options)
        })
        
        let action2 = UIAlertAction(title: "Google Maps", style: .default, handler: { (action) -> Void in
            print("ACTION 2 selected!")
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(self.userLocation.coordinate.latitude),\(self.userLocation.coordinate.longitude)&zoom=14&views=traffic&q=\(self.likelyPlace.coordinate.latitude),\(self.likelyPlace.coordinate.longitude)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string:"http://itunes.apple.com/us/app/id585027354")!, options: [:], completionHandler: nil)
            }
        })
    
        
        let action3 = UIAlertAction(title: "Waze", style: .default, handler: { (action) -> Void in
            print("ACTION 3 selected!")
            if (UIApplication.shared.canOpenURL(URL(string:"waze://")!)) {
                UIApplication.shared.open(URL(string:"https://waze.com/ul?ll=\(self.likelyPlace.coordinate.latitude),\(self.likelyPlace.coordinate.longitude)&navigate=yes")!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.open(URL(string:"http://itunes.apple.com/us/app/id323229106")!, options: [:], completionHandler: nil)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageV = cell.viewWithTag(100) as! UIImageView
        imageV.image = UIImage(named: dictArray[indexPath.row]["imageKey"]!)
        
        let labelProducto = cell.viewWithTag(200) as! UILabel
        labelProducto.text = dictArray[indexPath.row]["label"]!
        
        let labelPrice = cell.viewWithTag(300) as! UILabel
        labelPrice.text = dictArray[indexPath.row]["price"]!
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProducto", for: indexPath)
        
        return cell
    }
    
    
    
}
