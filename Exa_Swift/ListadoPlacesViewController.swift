//
//  ListadoPlacesViewController.swift
//  Exa_Swift
//
//  Created by Juan on 25/12/17.
//  Copyright © 2017 Arkos. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class ListadoPlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GMSAutocompleteViewControllerDelegate {
    
    

    var collectionView : UICollectionView?
    let cellId = "placeCell"
    let cellSpacing:CGFloat = 10
    var numberCell:CGFloat = 0
   
    var userLocation: CLLocation!
    
    var likelyPlaces: [GMSPlace] = []
    var likelyPlace : GMSPlace!
    struct DeviceInfo {
        struct Orientation {
            // indicate current device is in the LandScape orientation
            static var isLandscape: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isLandscape
                        : UIApplication.shared.statusBarOrientation.isLandscape
                }
            }
            // indicate current device is in the Portrait orientation
            static var isPortrait: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isPortrait
                        : UIApplication.shared.statusBarOrientation.isPortrait
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true;
        collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true;
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView?.backgroundColor = .white
        //collectionView settings
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView?.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: cellSpacing, bottom:0, right: cellSpacing)
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        
        
        let button1 = UIBarButtonItem(title: "Mapa", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addTapped)) // action:#selector(Class.MethodName) for swift 3
        self.navigationItem.rightBarButtonItem  = button1
        
        let buttonSearch = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: self.view.frame.size.height - 100, width: 90, height: 90))
        buttonSearch.titleLabel?.text = "Buscar"
        buttonSearch.setImage(UIImage(named: "ic_search_48pt") , for:.normal)
        buttonSearch.addTarget(self, action: #selector(buscarPlace), for: .touchUpInside)
        view.addSubview(buttonSearch)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            numberCell = 3
            
        } else {
            print("Portrait")
            numberCell = 2
        }
    }*/

    //UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 10;
        return likelyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
        cell.backgroundColor = .orange
        let collectionItem = likelyPlaces[indexPath.row]
        cell.nameLabel.text = collectionItem.name
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: collectionItem.placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, imageView: cell.showCaseImageView)
                }
            }
        }
        
        return cell
        
    }
    
    @objc func addTapped(){
        print("presenta mapa")
        performSegue(withIdentifier: "presentaMapaSegue", sender: self)
    }
    
    @objc func buscarPlace(){
        print("buscar lugar")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        //performSegue(withIdentifier: "presentaMapaSegue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select: \(likelyPlaces[indexPath.row])")
        likelyPlace = likelyPlaces[indexPath.row]
        performSegue(withIdentifier: "presentaDetalleSegue", sender: self)
    }
    
    //UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if DeviceInfo.Orientation.isLandscape{
            numberCell = 3
        }else{
            numberCell = 2
        }
        let width = (UIScreen.main.bounds.size.width - 4 * cellSpacing ) / numberCell
        let height = width
        return CGSize(width:width, height:height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentaMapaSegue" {
            if let mapaPlacesViewController = segue.destination as? MapaPlacesViewController {
                mapaPlacesViewController.likelyPlaces = likelyPlaces
            }
        }else if segue.identifier == "presentaDetalleSegue" {
            if let detallePlaceViewController = segue.destination as? DetallePlaceViewController {
                detallePlaceViewController.likelyPlace = likelyPlace
                detallePlaceViewController.userLocation = userLocation
            }
        }
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        
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
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        likelyPlaces .removeAll()
        likelyPlaces .append(place)
        collectionView?.reloadData()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
         print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }


}
