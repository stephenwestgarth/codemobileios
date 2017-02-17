//
//  MapDetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 10/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapDetailViewController: UIViewController {

    @IBOutlet weak var chesterMapView: MKMapView!
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
  
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        
        setupUI()
        let initialLocation = CLLocation(latitude: lat, longitude: long)
        centerMapOnLocation(location: initialLocation)
        addAnnotations()
    }
    
    // MARK: - MapKit
    
    var locationPoints = [CLLocationCoordinate2D]()
    var lat = 53.1938717
    var long = -2.8961019
    
    private let regionRadius: CLLocationDistance = 1000
    
    private func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        chesterMapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        
        switch mapTypeSegment.selectedSegmentIndex{
        case 0 : chesterMapView.mapType = MKMapType.standard
        case 1 : chesterMapView.mapType = MKMapType.satellite
        default : chesterMapView.mapType = MKMapType.hybrid
        }
    }
    
    func addAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        for item in locationPoints{
            let annotation = MKPointAnnotation()
            annotation.coordinate = item
            annotations.append(annotation)
        }
        
        chesterMapView.addAnnotations(annotations)
    }
    
    // MARK: - Other
    
    private func setupUI() {
        
        mapTypeSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        mapTypeSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
    }
}
