//
//  TTGeofencingViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/17/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import UIKit
import MapKit

class TTGeofencingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var regionHasBeenCentered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.leftBarButtonItem = closeButton
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save,
                                          target: self, action: #selector(self.save))
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationItem.title = "Setup Geofence"
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
    @objc func save(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
    // MARK: MapKit

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !regionHasBeenCentered {
            regionHasBeenCentered = true
            self.zoomIn(self.mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor(hex: 0x404A60)
            circleRenderer.fillColor = UIColor(hex: 0xA0AAC0).withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        self.redrawGeofence(coordinate: mapView.centerCoordinate)
    }
    
    func redrawGeofence(coordinate: CLLocationCoordinate2D) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        let geofenceAnnotation = MKPointAnnotation()
        geofenceAnnotation.coordinate = coordinate;
        geofenceAnnotation.title = "Home";
        mapView.addAnnotation(geofenceAnnotation)
        
        let circle = MKCircle(center: coordinate, radius: 12)
        mapView.add(circle)
    }
//
//    func setupData() {
//        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//            let restaurantAnnotation = MKPointAnnotation()
//            restaurantAnnotation.coordinate = coordinate;
//            restaurantAnnotation.title = "\(title)";
//            mapView.addAnnotation(restaurantAnnotation)
//
//            // 5. setup circle
//            let circle = MKCircle(centerCoordinate: coordinate, radius: regionRadius)
//            mapView.addOverlay(circle)
//        }
//        else {
//            print("System can't track regions")
//        }
//    }
//
//    // 6. draw circle
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        let circleRenderer = MKCircleRenderer(overlay: overlay)
//        circleRenderer.strokeColor = UIColor.red
//        circleRenderer.lineWidth = 1.0
//        return circleRenderer
//    }
    
    @IBAction func zoomIn(_ sender: Any) {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(userLocation, 120, 120)
            mapView.setRegion(region, animated: true)

            self.redrawGeofence(coordinate: userLocation)
        }
    }
    
    

}
