//
//  ViewController.swift
//  Lugares Favoritos
//
//  Created by Alexis Araujo on 6/24/16.
//  Copyright © 2016 Alexis Araujo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.showsUserLocation = true
        if activePlace == -1 {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
        else {
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let span = MKCoordinateSpanMake(latDelta, lonDelta)
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegionMake(coordinate, span)
            self.map.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = places[activePlace]["name"]
            self.map.addAnnotation(annotation)
            
        }
        
       
        // Do any additional setup after loading the view, typically from a nib.
        
        //Este metodo recibe un argumento si no ponemos los ":" busca un metodo que no tenga argumentos
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressDetected(_:)))
        lpgr.minimumPressDuration = 2
        
        self.map.addGestureRecognizer(lpgr)
    }

    func longPressDetected(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Recognized {
            let tocuhPoint = gestureRecognizer.locationInView(self.map)
            let newCoordinate = self.map.convertPoint(tocuhPoint, toCoordinateFromView: self.map)
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                var title = ""
                
                if let p = placemarks?.first{
                    if p.thoroughfare != nil {
                        title += "\(p.thoroughfare!)"
                    }
                    if p.subThoroughfare != nil {
                        title += "\(p.subThoroughfare!)"
                    }
                }
                if title == "" {
                    title = "Punto añadido el \(NSDate())"
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                
                places.append(["name": title, "lat": "\(newCoordinate.latitude)", "lon": "\(newCoordinate.longitude)"])
                NSUserDefaults.standardUserDefaults().setObject(places, forKey: "places")
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //Si queremos que comience a darnos posiciones
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
            
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let span = MKCoordinateSpanMake(latDelta, lonDelta)
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegionMake(coordinate, span)
            self.map.setRegion(region, animated: true)
            
        }
    }

}

