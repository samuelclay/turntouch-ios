//
//  AppDelegate.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreLocation
import Reachability
import InAppSettingsKit
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var modeMap: TTModeMap!
    var bluetoothMonitor: TTBluetoothMonitor!
    var locationManager: CLLocationManager!
    var reachability: Reachability!
    @IBOutlet var mainViewController: TTMainViewController!
    
    lazy var moduleName: String = {
       return NSStringFromClass(Self.self).components(separatedBy: ".")[0]
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        self.erasePreferences()
        self.loadPreferences()

        let centralManagerIdentifiers = launchOptions?[UIApplication.LaunchOptionsKey.bluetoothCentrals]
        if centralManagerIdentifiers != nil {
            print(" ---> centralManagerIdentifiers: \(String(describing: centralManagerIdentifiers))")
        }

//        print(preferences()UserDefaults().dictionaryRepresentation())
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        bluetoothMonitor = TTBluetoothMonitor()
        modeMap = TTModeMap()
        modeMap.setupModes()
        locationManager = CLLocationManager()
        mainViewController = TTMainViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        modeMap.activateModes()
        self.watchReachability()

        DispatchQueue.global().async {
            self.beginLocationUpdates()
        }
        
        DispatchQueue.main.async {
            let isSimulator = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
            if self.bluetoothMonitor.noKnownDevices() && !isSimulator {
                self.mainViewController.showPairingModal()
            }
        }
        
        DispatchQueue.main.async {
            //            appDelegate().mainViewController.showPairingModal()
            //            appDelegate().mainViewController.showFtuxModal()
//            appDelegate().mainViewController.showAboutModal()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("\n ---> applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(" ---> applicationDidEnterBackground")
        
        self.recordState()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print(" ---> applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("\n\n ---> applicationDidBecomeActive")
        
        bluetoothMonitor.countDevices()
        bluetoothMonitor.resetSearch()
        
        self.recordState()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(" ---> applicationWillTerminate");
        bluetoothMonitor.terminate()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let parameters = TTModeSpotify.appRemote.authorizationParameters(from: url)
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            TTModeSpotify.appRemote.connectionParameters.accessToken = access_token
            TTModeSpotify.accessToken = access_token
            TTModeSpotifyAppDelegate.recentSpotify?.didEstablishConnection()
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            TTModeSpotifyAppDelegate.recentSpotify?.cancelConnectingToSpotify(error: error_description)
        }
        
        return true
    }
    
    func redrawMainLayout() {
        modeMap.setupModes()
        mainViewController.layoutStackview()
        modeMap.activateModes()
    }
    
    func recordState() {
        switch (UIApplication.shared.applicationState) {
        case .active:
            modeMap.recordUsage(additionalParams: ["moment": "launch"])
        case .background:
            modeMap.recordUsage(additionalParams: ["moment": "launch-background"])
        case .inactive:
            modeMap.recordUsage(additionalParams: ["moment": "launch-inactive"])
        @unknown default:
            break
        }
    }
    
    func erasePreferences() {
        preferences().removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    func loadPreferences() {
        migratePreferencesToGroup()
        
        let prefs = preferences()
        let defaultPrefsFile = Bundle.main.path(forResource: "Preferences", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String: AnyObject]
        prefs.register(defaults: defaultPrefs)

        self.processDefaultSettings()
        
        prefs.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: "version")
        prefs.set(Bundle.main.infoDictionary!["CFBundleVersion"], forKey: "build_number")
        
        prefs.synchronize()
    }
    
    func migratePreferencesToGroup() {
        let localDefaults = UserDefaults.standard
        let localDictionary = localDefaults.dictionaryRepresentation()
        let groupDefaults = preferences()
        let didMigrateToAppGroups = "TT:didMigrateToAppGroups"
        
        if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
            for key in localDictionary.keys {
                if key.hasPrefix("TT:") {
                    groupDefaults.set(localDictionary[key], forKey: key)
                }
            }
            
            groupDefaults.set(true, forKey: didMigrateToAppGroups)
        }
    }
    
    func processDefaultSettings() {
        let defaults = preferences()
        defaults.synchronize()
        
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") as NSString? else {
            NSLog("Could not find Settings.bundle");
            return;
        }
        
        if let settings = NSDictionary(contentsOfFile: settingsBundle.appendingPathComponent("Root.plist")) {
//            print(" ---> Settings: \(settings)")
            if let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String: Any]] {
            
                var defaultsToRegister = [String: Any](minimumCapacity: preferences.count)
                
                for prefSpecification in preferences {
                    if let key = prefSpecification["Key"] as? String {
                        if !key.contains("") {
                            let currentObject = defaults.object(forKey: key)
                            if currentObject == nil {
                                let objectToSet = prefSpecification["DefaultValue"]
                                defaultsToRegister[key] = objectToSet!
                                
                                NSLog("Setting object \(String(describing: objectToSet)) for key \(key)")
                            }
                        }
                    }
                }
                
                defaults.register(defaults: defaultsToRegister)
                defaults.synchronize()
            }
        }
    }
    
    // MARK: Location
    
    func beginLocationUpdates() {
        // Wait until remotes are found before requesting location
        if bluetoothMonitor.foundDevices.count() > 0 {
//            mainViewController.showGeofencingModal()

            return
        }
        
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
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            alertController.addAction(openAction)
            
            self.mainViewController.present(alertController, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
    
    func startSignificantChangeUpdates() {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//        mainViewController.showGeofencingModal()
        // for all regions: self.monitorRegionAtLocation(region)
    }

    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let maxDistance = locationManager.maximumRegionMonitoringDistance
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func startLocationMonitoring() {
        let prefs = preferences()
        if let coords = prefs.dictionary(forKey: "TT:geofence:1") as? [String: NSNumber] {
            let center = CLLocationCoordinate2D(latitude: coords["lat"] as! CLLocationDegrees,
                                                longitude: coords["long"] as! CLLocationDegrees)
            let region = CLCircularRegion(center: center, radius: 12, identifier: "TT:geofence:1")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            locationManager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        bluetoothMonitor.scanKnown()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        bluetoothMonitor.scanKnown()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        bluetoothMonitor.scanKnown()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.startSignificantChangeUpdates()
        }
    }
    
    // MARK: Reachability
    
    func watchReachability() {
        if reachability != nil {
            return
        }
        
        reachability = Reachability()
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                print(" ---> Reachable, re-connecting to bluetooth...")
                self.bluetoothMonitor.scanKnown()
            }
        }
        
        reachability.whenUnreachable = { reachability in
            print(" ---> Unreachable, not connected")
        }
        
    }

 }

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func preferences() -> UserDefaults {
    return UserDefaults(suiteName: "group.com.turntouch.appgroup") ?? UserDefaults.standard
}
