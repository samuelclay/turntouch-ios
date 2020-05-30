//
//  WidgetDelegate.swift
//  Widget Extension
//
//  Created by David Sinclair on 2020-04-28.
//  Copyright © 2020 Turn Touch. All rights reserved.
//

import UIKit

class WidgetDelegate: UIResponder {
    /// Singleton shared instance.
    static let shared = WidgetDelegate()
    
    var window: UIWindow?
    var modeMap: TTModeMap!
    @IBOutlet var mainViewController: WidgetExtensionViewController!
    
    lazy var moduleName: String = {
        return NSStringFromClass(Self.self).components(separatedBy: ".")[0]
    }()
    
    private override init() {
        super.init()
    }
    
    func prepare() {
        //        self.erasePreferences()
        loadPreferences()
        
        modeMap = TTModeMap()
        modeMap.setupModes()
        modeMap.activateModes()
    }
    
    func redrawMainLayout() {
        modeMap.setupModes()
        mainViewController.layoutStackview()
        modeMap.activateModes()
    }
    
    func loadPreferences() {
        guard let prefs = UserDefaults(suiteName: "group.dejal.turntouch.ios-remote") else {
            return
        }
        
        let defaultPrefsFile = Bundle.main.path(forResource: "Preferences", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String: AnyObject]
        prefs.register(defaults: defaultPrefs)
        
        self.processDefaultSettings()
        
        prefs.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: "version")
        prefs.set(Bundle.main.infoDictionary!["CFBundleVersion"], forKey: "build_number")
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
    
    func runInApp(action: String) {
        let fullModeName = modeMap.selectedMode.nameOfClass
        let modeName = fullModeName.dropFirst("TTMode".count)
        let actionName = action.dropFirst(fullModeName.count)
        
        guard let url = URL(string: "turntouch://widget/\(modeName)/\(actionName)") else {
            return
        }
        
        mainViewController.extensionContext?.open(url)
    }
}

func appDelegate() -> WidgetDelegate {
    return WidgetDelegate.shared
}

func preferences() -> UserDefaults {
    #if DEJAL
    return UserDefaults(suiteName: "group.com.turntouch.ios-remote") ?? UserDefaults.standard
    #else
    return UserDefaults(suiteName: "group.com.turntouch.appgroup") ?? UserDefaults.standard
    #endif
}
