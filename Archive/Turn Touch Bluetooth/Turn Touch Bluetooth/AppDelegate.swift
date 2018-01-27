//
//  AppDelegate.swift
//  Turn Touch Bluetooth
//
//  Created by Samuel Clay on 8/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var bluetoothManager: TTBluetoothManager!
    let locationManager = CLLocationManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        print("didFinishLaunchingWithOptions");
        bluetoothManager = TTBluetoothManager()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("applicationWillResignActive");
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground");
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground");
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive");
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate");
    }

    
    func loadPreferences() {
        let prefs = UserDefaults.standard
        let defaultPrefsFile = Bundle.main.path(forResource: "Preferences", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String: AnyObject]
        
        prefs.register(defaults: defaultPrefs)
        prefs.synchronize()
    }
    
    func beginLocationUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            self.startSignificantChangeUpdates()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to have your remote automatically connect, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
        }
    }
    
    func startSignificantChangeUpdates() {
        print(" ---> startSignificantChangeUpdates")
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(" ---> didUpdateLocations")
        bluetoothManager.centralManagerDidUpdateState(bluetoothManager.manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(" ---> didChangeAuthorizationStatus")
        if status == .authorizedAlways {
            self.startSignificantChangeUpdates()
        }
    }
}


func appDelegate () -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}
