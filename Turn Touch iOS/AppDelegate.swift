 //
//  AppDelegate.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var modeMap: TTModeMap!
    var bluetoothMonitor: TTBluetoothMonitor!
    var locationManager: CLLocationManager!
    @IBOutlet var mainViewController: TTMainViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        self.erasePreferences()
        self.loadPreferences()

        let centralManagerIdentifiers = launchOptions?[UIApplicationLaunchOptionsKey.bluetoothCentrals]
        if centralManagerIdentifiers != nil {
            print(" ---> centralManagerIdentifiers: \(centralManagerIdentifiers)")
        }

//        print(UserDefaults.standardUserDefaults().dictionaryRepresentation())
        
        bluetoothMonitor = TTBluetoothMonitor()
        modeMap = TTModeMap()
        modeMap.setupModes()
        locationManager = CLLocationManager()
        mainViewController = TTMainViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        modeMap.activateModes()

        DispatchQueue.global().async {
            self.beginLocationUpdates()
        }
        
        DispatchQueue.main.async {
            if self.bluetoothMonitor.noKnownDevices() {
//                appDelegate().mainViewController.showPairingModal()
            }
        }
        
        DispatchQueue.main.async {
//            appDelegate().mainViewController.showPairingModal()
            appDelegate().mainViewController.showFtuxModal()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
//        let prefs = UserDefaults.standardUserDefaults()
//        prefs.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
        
        bluetoothMonitor.countDevices()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate");
        bluetoothMonitor.terminate()
        let prefs = UserDefaults.standard
        prefs.synchronize()
    }
    
    func erasePreferences() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
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
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.mainViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func startSignificantChangeUpdates() {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        bluetoothMonitor.scanKnown()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.startSignificantChangeUpdates()
        }
    }
    
 }

func appDelegate () -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}
