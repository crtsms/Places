//
//  PlaceViewController.swift
//  Places
//
//  Created by Crislei Terassi Sorrilha on 4/15/18.
//  Copyright © 2018 Crislei Terassi Sorrilha. All rights reserved.
//

import UIKit
import MapKit
import os.log

class PlacesViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var map: MKMapView!
    
    //This value is either passed by PlacesTableViewController in prepare(for:sender)
    var placeSelected: Place?
    
    //This value is loaded from user data
    var store = DataStore.sharedInstance

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Add the gesture recognizer
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        self.map.addGestureRecognizer(uilpgr)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadData()
        
        if store.places.count > 0 {
            for place in store.places {
                plotPace(place: place)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    @IBAction func unwindToMap(sender: UIStoryboardSegue){
        
        if let sourceViewController = sender.source as? PlacesViewController, let place = sourceViewController.placeSelected {
            plotPace(place: place)
        }
        
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        let  pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        pinView.pinTintColor = UIColor.darkGray
        pinView.isDraggable = true
        pinView.accessibilityLabel = "hello"
        let btn = UIButton(type: .detailDisclosure)
        pinView.rightCalloutAccessoryView = btn
        return pinView
    }
    
    //MARK: Private Methods
    
    private func loadData() {
        
        if let storedData = NSKeyedUnarchiver.unarchiveObject(withFile: Place.ArchiveURL.path) as? [Place]{
            self.store.places = storedData
        }
        
    }

    /// Save places into user data
    private func savePlaces(){
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.store.places, toFile: Place.ArchiveURL.path)
        print(self.store.places)
        
        if isSuccessfulSave {
            os_log("Places successfully saved.", log: OSLog.default, type: .debug)
        }else{
            os_log("Failed to save places...", log: OSLog.default, type: .error)
        }
        
    }
    
    /// Plot a specific place on the map
    ///
    /// - Parameter place: Place will be plot on the map
    private func plotPace(place: Place){
            
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        
        self.map.addAnnotation(annotation)
        
    }
    
    /// Insert a new place touched by user on the map
    ///
    /// - Parameter gestureRecognizer: Object gesture recognizer touched by user
    @objc private func longPress(gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            //Get the point touched and transform in a coordinate from map
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
            //Get the adress
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    fatalError("Reverse geocoder failed with error: \(String(describing: error?.localizedDescription))")
                }
                
                if (placemarks?.count)! > 0 {
                
                    let placeMark = placemarks![0]
                    var title : String = ""
                    
                    if placeMark.name?.isEmpty == false {
                        title = placeMark.name!
                    }
            
                    //Create a new place
                    let place:Place = Place(title: title, latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)!
                    place.latitude = newCoordinate.latitude
                    place.longitude = newCoordinate.longitude
                    
                    //Call a func to plot a selected place on the map
                    self.plotPace(place: place)
                    
                    //Add the new place on the places array
                    self.store.places.append(place)
                    
                    //Save the places array on the user data
                    self.savePlaces()
                    
                } else {
                    
                    fatalError("No Placemarks!")
                    
                }
                
            })
            
        }
        
    }

}
