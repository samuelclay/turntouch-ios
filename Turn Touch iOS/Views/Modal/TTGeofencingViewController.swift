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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
    @objc func save(_ sender: UIBarButtonItem!) {
        let prefs = UserDefaults.standard
        let center = mapView.camera.centerCoordinate

        prefs.set(["lat": NSNumber(value: center.latitude),
                   "long": NSNumber(value: center.longitude)],
                  forKey: "TT:geofence:1")
        prefs.synchronize()
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            appDelegate().beginLocationUpdates()
        } else if CLLocationManager.authorizationStatus() != .authorizedAlways {
            appDelegate().beginLocationUpdates()
        } else {
            appDelegate().startLocationMonitoring()
        }
        
        appDelegate().mainViewController.closeModal()
    }
    
    // MARK: MapKit

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last, lastLocation.timestamp.timeIntervalSinceNow > -5.0 {
            if !regionHasBeenCentered {
                regionHasBeenCentered = true
                let prefs = UserDefaults.standard
                if let coords = prefs.dictionary(forKey: "TT:geofence:1") as? [String: NSNumber] {
                    let center = CLLocationCoordinate2D(latitude: coords["lat"] as! CLLocationDegrees,
                                                        longitude: coords["long"] as! CLLocationDegrees)
                    let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 120, longitudinalMeters: 120)
                    mapView.setRegion(region, animated: true)
                    
                    self.redrawGeofence(coordinate: center)
                } else {
                    self.zoomIn(self.mapView)
                }
            }
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
        mapView.addOverlay(circle)
    }

    @IBAction func zoomIn(_ sender: Any) {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion.init(center: userLocation, latitudinalMeters: 120, longitudinalMeters: 120)
            mapView.setRegion(region, animated: true)

            self.redrawGeofence(coordinate: userLocation)
        }
    }

}
