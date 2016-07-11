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

    var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)
    var modeMap: TTModeMap = TTModeMap()
    let bluetoothMonitor = TTBluetoothMonitor()
    let locationManager = CLLocationManager()
    @IBOutlet var mainViewController: TTMainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.loadPreferences()
        
        let centralManagerIdentifiers = launchOptions?[UIApplicationLaunchOptionsBluetoothCentralsKey]
        if centralManagerIdentifiers != nil {
            print(" ---> centralManagerIdentifiers: \(centralManagerIdentifiers)")
        }
        
        modeMap.setupModes()
        mainViewController = TTMainViewController()
        window!.rootViewController = mainViewController
        window!.makeKeyAndVisible()
        modeMap.activateModes()

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            self.beginLocationUpdates()
            self.bluetoothMonitor.updateBluetoothState(false)
        }
        
        dispatch_async(dispatch_get_main_queue()) { 
//            appDelegate().mainViewController.showPairingModal()
        }
        
//        print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("applicationWillResignActive")
//        var bgTask: UIBackgroundTaskIdentifier = 0
//        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
//            print(" Background time: \(UIApplication.sharedApplication().backgroundTimeRemaining)")
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
//                self.bluetoothMonitor.scanKnown()
//            }
//            UIApplication.sharedApplication().endBackgroundTask(bgTask)
//        }
//        
//        self.bluetoothMonitor.scanKnown()
//        print(" Background time remaining: \(UIApplication.sharedApplication().backgroundTimeRemaining)")
//        UIApplication.sharedApplication().endBackgroundTask(bgTask)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        bluetoothMonitor.terminate()
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.synchronize()
    }
    
    func loadPreferences() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let defaultPrefsFile = NSBundle.mainBundle().pathForResource("Preferences", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String: AnyObject]
        
        prefs.registerDefaults(defaultPrefs)
        prefs.synchronize()
    }
    
    func beginLocationUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            self.startSignificantChangeUpdates()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to have your remote automatically connect, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.mainViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func startSignificantChangeUpdates() {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        bluetoothMonitor.scanKnown()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            self.startSignificantChangeUpdates()
        }
    }
}

func appDelegate () -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}
