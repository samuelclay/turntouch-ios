//
//  ViewController.swift
//  STBonjour
//
//  Created by Eric Dolecki on 6/15/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import UIKit
import WatchConnectivity
import Foundation

struct Speaker
{
    var IPAddress: String   = "Unknown"
    var Name: String        = "Unknown"
    var MACAddress: String  = "Unknown"
    var DeviceType: String  = "Unknown"
    
    init(ip: String, name: String, mac: String, deviceType: String){
        self.IPAddress = ip
        self.Name = name
        self.MACAddress = mac
        self.DeviceType = deviceType
    }
}

struct Preset
{
    var id: Int         = -1
    var source: String  = "Unknown"
    var name: String    = "Unknown"
    
    init(id: Int, source: String, name: String ){
        self.id = id
        self.source = source
        self.name = name
    }
}

class ViewController: UIViewController, NSNetServiceDelegate, UITableViewDelegate, UITableViewDataSource, PresetButtonDelegate, WCSessionDelegate
{
    var nsns: NSNetService?
    var nsnsdel: BMNSDelegate?
    var nsb: NSNetServiceBrowser?
    var nsbdel: BMBrowserDelegate?
    var tableView: UITableView!
    var speakerArray = [String]()
    var speakerIPAddresses = [String]()
    var header: UILabel!
    var headerSecond: UILabel!
    var speakerObjectArray = [Speaker]()
    var presetObjectArray = [Preset]()
    var bottomBar: UIView!
    var powerButton: UIButton!
    var powerDot: UIView!
    var selIndex: Int = -1
    var speakerVolume: Int = 50
    var volumeSlider: UISlider!
    var presetTitle: UILabel!
    var refresh: UIButton!
    var presetButtonContainer: UIView!
    var titleConstructor: TitleConstructor = TitleConstructor()
    var tileDisplay: GenericTileDisplay!
    
    var session:WCSession!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            /*
            let dict = ["status":"load"]
            //session.transferUserInfo(dict)
            session.sendMessage(dict, replyHandler: {(_: [String : AnyObject]) -> Void in
                // handle reply from iPhone app here
                }, errorHandler: {(error ) -> Void in
                    // catch any errors here
            })
            */
        }
        
        header = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 20))
        header.textAlignment = .Center
        header.textColor = UIColor.orangeColor()
        header.adjustsFontSizeToFitWidth = true
        header.minimumScaleFactor = 0.7
        header.lineBreakMode = .ByTruncatingTail
        header.text = "SOUNDTOUCH UNITS"
        header.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
        self.view.addSubview(header)
        
        headerSecond = UILabel(frame: CGRect(x: 0, y: 90, width: self.view.frame.width, height: 20))
        headerSecond.textAlignment = .Center
        headerSecond.textColor = UIColor(netHex: 0x888888)
        headerSecond.text = "PLEASE SELECT A DEVICE BELOW..."
        headerSecond.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        headerSecond.hidden = true
        self.view.addSubview(headerSecond)
            
        tableView = UITableView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.height - 350))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorColor = UIColor.darkGrayColor()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        bottomBar = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 150, width: self.view.frame.width, height: 150))
        bottomBar.backgroundColor = UIColor.darkGrayColor()
        
        // Must select a speaker before allowing buttons to send commands.
        
        bottomBar.alpha = 1.0
        
        powerButton = UIButton(frame: CGRect(x: 15, y: 95, width: 100, height: 40))
        powerButton.setTitle("Power", forState: .Normal)
        powerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        powerButton.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.4).CGColor
        powerButton.layer.cornerRadius = 5.0
        powerButton.layer.borderWidth = 0.5
        powerButton.addTarget(self, action: #selector(powerPressed), forControlEvents: .TouchUpInside)
        powerButton.addTarget(self, action: #selector(powerDown), forControlEvents: .TouchDown)
        powerDot = UIView(frame: CGRect(x: 20, y: 100, width: 10, height: 10))
        powerDot.backgroundColor = UIColor.redColor()
        powerDot.layer.cornerRadius = 5.0
        
        tileDisplay = GenericTileDisplay(frame: CGRect(x: self.view.frame.width - 70, y: 90, width: 50, height: 50))
        
        volumeSlider = UISlider(frame: CGRect(x: 15, y: 60, width: self.view.frame.width - 30, height: 23))
        volumeSlider.maximumValue = 100.0
        volumeSlider.userInteractionEnabled = true
        volumeSlider.minimumValue = 0.0
        volumeSlider.value = 0.0
        volumeSlider.continuous = false
        volumeSlider.setThumbImage(UIImage(named: "smthumb.png"), forState: .Normal)
        volumeSlider.addTarget(self, action: #selector(setSelectedSpeakerVolume), forControlEvents: .ValueChanged)
        
        presetTitle = UILabel(frame: CGRect(x: 0, y: 10, width: self.view.frame.width - 10, height: 50))
        presetTitle.textAlignment = .Center
        presetTitle.textColor = UIColor.whiteColor()
        presetTitle.text = "No playing data."
        presetTitle.textColor = UIColor.lightGrayColor()
        presetTitle.numberOfLines = 2
        presetTitle.lineBreakMode = .ByWordWrapping
        presetTitle.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        
        bottomBar.addSubview(volumeSlider)
        bottomBar.addSubview(presetTitle)
        bottomBar.addSubview(powerButton)
        bottomBar.addSubview(powerDot)
        bottomBar.addSubview(tileDisplay)
        self.view.addSubview(bottomBar)
        
        refresh = UIButton(frame: CGRect(x: 10, y: 5, width: 100, height: 15))
        refresh.center = CGPoint(x: self.view.frame.width / 2, y: refresh.center.y)
        refresh.setTitle("refresh list", forState: .Normal)
        refresh.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        refresh.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        refresh.addTarget(self, action: #selector(refreshSearch), forControlEvents: .TouchUpInside)
        self.view.addSubview(refresh)
        
        presetButtonContainer = UIView(frame: CGRect(x: 0, y: 25, width: self.view.frame.width, height: 175))
        self.view.addSubview(presetButtonContainer)
        
        let BM_DOMAIN = "local."
        let BM_TYPE = "_soundtouch._tcp."
        let BM_NAME = "hello"
        let BM_PORT : CInt = 1900
        
        /// Netservice.
        
        nsns = NSNetService(domain: BM_DOMAIN, type: BM_TYPE, name: BM_NAME, port: BM_PORT)
        nsnsdel = BMNSDelegate() //see bellow
        nsns?.delegate = nsnsdel
        nsns?.publish()
        
        /// Net service browser.
        
        nsb = NSNetServiceBrowser()
        nsbdel = BMBrowserDelegate() //see bellow
        nsb?.delegate = nsbdel
        
        EDProgressView.shared.showProgressView(view)
        
        nsb?.searchForServicesOfType(BM_TYPE, inDomain: BM_DOMAIN)
    }    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Information FROM Apple Watch Extension. Try to get this to work.
    
    // Not using.
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print(userInfo) // Should be "status":"fetch"
        if let info = userInfo as? Dictionary<String,String>{
            if let s = info["status"]{
                print(s) // Should be "fetch"
            }
        }
    }
    
    //MARK: - Message from Watch Extension -
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        print("iOS App got from watch: \(message)")
        
        // Starts a background task with 3 minute timeout. Found this online - not sure it's good.
        // http://stackoverflow.com/questions/31618550/how-to-wake-up-iphone-app-from-watchos-2
        
        let application = UIApplication.sharedApplication()
        var identifier = UIBackgroundTaskInvalid
        let endBlock:dispatch_block_t = {() -> Void in
            if identifier != UIBackgroundTaskInvalid {
                application.endBackgroundTask(identifier)
            }
            identifier = UIBackgroundTaskInvalid
        }
        identifier = application.beginBackgroundTaskWithExpirationHandler(endBlock)
        
        if let info = message as? Dictionary<String,String>
        {
            if let s = info["status"] {
                print(s) // Should be "fetch"
            }
            
            if let s = info["volume"]
            {
                print("vol: \(s)")
                
                // Could be "87__Eric ST 30"
                
                let array = s.componentsSeparatedByString("__")
                let vol = array[0]
                let thisSpeakerName = array[1]
                print("We have volume of \(Int(vol)) for speaker \(thisSpeakerName)")
                
                // Now actually set it.
                
                self.setSpeakerVolumeFromWatch(Int(vol)!, speakerName: thisSpeakerName) // We should send name so we get from watch & get the IP.
            }
            
            // Watch app told us to navigate to a preset.
            
            if let s = info["preset"]
            {
                if selIndex == -1 {
                    return
                }
                let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
                let url = NSURL(string:"http://\(thisSpeakerIP):8090/key")
                let session = NSURLSession.sharedSession()
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
                let paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_\(s)</key>"
                
                request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = session.dataTaskWithRequest(request) {
                    (
                    let data, let response, let error) in
                    guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                        print("error")
                        return
                    }
                    let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("dataString: '\(dataString!)'")
                }
                task.resume()
                
                delay(0.25){
                    let paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_\(s)</key>"
                    request.HTTPBody = paramString2.dataUsingEncoding(NSUTF8StringEncoding)
                    let task2 = session.dataTaskWithRequest(request) {
                        (
                        let data, let response, let error) in
                        guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                            print("error")
                            return
                        }
                        let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("dataString: '\(dataString!)'")
                    }
                    task2.resume()
                }
                
                delay(0.50){
                    self.getSpeakerInfo()
                }
            }
            
            // This will cause a reload into the Apple Watch too.
            
            if let s = info["refresh"]{
                print(s)
                 dispatch_async(dispatch_get_main_queue()) {
                    self.refreshSearch() 
                }
            }
            
            // Loop through this list and find the correct speaker and select it programatically.
            
            if let s = info["selected"] {
                
                for i in 0..<speakerObjectArray.count {
                    if s == speakerObjectArray[i].Name {
                        
                        // We should select it in the tableview.
                        
                        let rowToSelect = NSIndexPath(forRow: i, inSection: 0)
                        
                        dispatch_async(dispatch_get_main_queue())
                        {
                            // Anything needed on UI thread.
                            
                            self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: .None)
                            self.tableView(self.tableView, didSelectRowAtIndexPath: rowToSelect)
                        }
                        break
                    }
                }
            }
            
            // Watch extension asked for current volume.
            
            if let s = info["request"]{
                if s == "vol" {
                    
                    // Send the current speaker volume to the watch extension.
                    
                    let window = UIApplication.sharedApplication().keyWindow
                    let vc = window?.rootViewController as! ViewController
                    let thisDictionary:[String:String] = ["volumeValue":"\(self.speakerVolume)"]
                    
                    vc.session.sendMessage(thisDictionary, replyHandler: {(_: [String : AnyObject]) -> Void in
                            // handle reply from iPhone app here
                        }, errorHandler: {(error ) -> Void in
                            // catch any errors here
                    })
                    
                }
            }
            
            // Request from watch extension (PresetViewController).
            
            if let s = info["needPresetData"]
            {
                let index = Int(s)
                var useIndex = index! - 1
                if useIndex < 0 {
                    useIndex = 0
                }
                let preset:Preset = self.presetObjectArray[useIndex]
                let p1 = preset.name
                let p2 = preset.source
                
                let window = UIApplication.sharedApplication().keyWindow
                let vc = window?.rootViewController as! ViewController
                
                // index needs to be unwrapped or it's an Optional. This caused an hour of searching around.
                
                let thisDictionary:[String:String] = ["description":"\(index!)_\(p1)\n\n\(p2)"] //index! alleviates Optional(index)
                vc.session.sendMessage(thisDictionary, replyHandler: {(_: [String : AnyObject]) -> Void in
                        // handle reply from iPhone app here
                    }, errorHandler: {(error ) -> Void in
                        // catch any errors here
                })
            }
            
            // Watch extension launched and on it's init asks if there is a list already.
            // If so, send it to the watch extension. Similar to the refresh operation.
            
            if let s = info["doYouHaveASpeakerList"] {
                
                print(s)
                
                let window = UIApplication.sharedApplication().keyWindow
                let vc = window?.rootViewController as! ViewController
                
                if vc.speakerObjectArray.count > 0 {
                    var thisDictionary = [String:String]()
                    for (index,speaker) in vc.speakerObjectArray.enumerate(){
                        thisDictionary["speaker_\(index)"] = speaker.Name
                    }
                    vc.session.sendMessage(thisDictionary, replyHandler: {(_: [String : AnyObject]) -> Void in
                            // handle reply from iPhone app here
                        }, errorHandler: {(error ) -> Void in
                            // catch any errors here
                    })
                } else {
                    
                    // There were no found speakers from the iOS application yet.
                    print("Don't have any found speakers. \(vc.speakerObjectArray.count)")
                }
            }
            
            // The Apple Watch extension requested if we have a currently playing preset. Tell it if we do.
            
            if let s = info["requestCurrentPreset"]{
                
                print(s)
                
                // Allow things to settle.
                
                delay(0.5){
                    
                    print("requestCurrentPreset called in VC")
                    print(self.presetTitle.text!, self.presetObjectArray.count)
                    
                    let sentence = self.presetTitle.text!
                    var lines:[String] = []
                    sentence.enumerateLines{ lines.append($0.line) }
                    let trueTitle = lines[0]
                    print(trueTitle)
                    
                    for i in 0..<self.presetObjectArray.count
                    {
                        print(self.presetObjectArray[i].name, trueTitle)
                        
                        if self.presetObjectArray[i].name == trueTitle {
                            
                            print("sending data to watch extension.")
                            
                            let index:Int = self.presetObjectArray[i].id + 1 // zero-based fix
                            let stringIndex = String(index)
                            
                            // Make sure index isn't an optional when sent.
                            
                            let window = UIApplication.sharedApplication().keyWindow
                            let vc = window?.rootViewController as! ViewController
                            let thisDictionary = ["presetIndex":"\(stringIndex)"]
                            
                            vc.session.sendMessage(thisDictionary, replyHandler: {(_: [String : AnyObject]) -> Void in
                                // handle reply from iPhone app here
                                }, errorHandler: {(error ) -> Void in
                                    // catch any errors here
                            })
                            
                            break
                        }
                    }
                }
                
                
                
                
                
                
            }
        }
        
        /*
        dispatch_async(dispatch_get_main_queue()) {
            // Anything needed on UI thread.
            
        }
        */
    }
    
    // PresetButtonView DELEGATE method
    
    func presetButtonPressed(sender:PresetButtonView) {
        
        if selIndex == -1 {
            return
        }
        
        tileDisplay.updateTextDisplay("")
        
        //print(sender.tag)
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url = NSURL(string:"http://\(thisSpeakerIP):8090/key")
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        var paramString = ""
        
        switch sender.myNumber - 1 {
        case 0:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_1</key>"
        case 1:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_2</key>"
        case 2:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_3</key>"
        case 3:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_4</key>"
        case 4:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_5</key>"
        case 5:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_6</key>"
        default:
            paramString = "<key state=\"press\" sender=\"Gabbo\">PRESET_1</key>"
        }
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("dataString: '\(dataString!)'")
        }
        task.resume()
        
        delay(0.25){
            var paramString2 = ""
            switch sender.myNumber - 1 {
            case 0:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_1</key>"
            case 1:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_2</key>"
            case 2:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_3</key>"
            case 3:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_4</key>"
            case 4:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_5</key>"
            case 5:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_6</key>"
            default:
                paramString2 = "<key state=\"release\" sender=\"Gabbo\">PRESET_1</key>"
            }
            request.HTTPBody = paramString2.dataUsingEncoding(NSUTF8StringEncoding)
            let task2 = session.dataTaskWithRequest(request) {
                (
                let data, let response, let error) in
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("dataString: '\(dataString!)'")
            }
            task2.resume()
        }
        
        delay(0.50){
            self.getSpeakerInfo()
        }
    }
    
    func refreshSearch()
    {
        speakerArray = [String]()
        speakerIPAddresses = [String]()
        speakerObjectArray = [Speaker]()
        tableView.reloadData()
        headerSecond.hidden = true
        header.text = "SoundTouch Units"
        
        for view in self.presetButtonContainer.subviews {
            view.removeFromSuperview()
        }
        
        EDProgressView.shared.showProgressView(view)
        let BM_DOMAIN = "local."
        let BM_TYPE = "_soundtouch._tcp."
        let BM_NAME = "hello"
        let BM_PORT : CInt = 1900
        
        nsb?.stop()
        
        nsns = NSNetService(domain: BM_DOMAIN, type: BM_TYPE, name: BM_NAME, port: BM_PORT)
        nsnsdel = BMNSDelegate() //see bellow
        nsns?.delegate = nsnsdel
        nsns?.publish()
        
        /// Net service browser.
        
        nsb = NSNetServiceBrowser()
        nsbdel = BMBrowserDelegate() //see bellow
        nsb?.delegate = nsbdel
        
        EDProgressView.shared.showProgressView(view)
        
        nsb?.searchForServicesOfType(BM_TYPE, inDomain: BM_DOMAIN)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // Talk to the selected speaker.
    
    func powerDown(){
        powerButton.backgroundColor = UIColor(netHex: 0x333333)
    }
    
    func powerPressed()
    {
        if selIndex == -1 {
            return
        }
        
        powerButton.backgroundColor = UIColor.clearColor()
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url = NSURL(string:"http://\(thisSpeakerIP):8090/key")
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let paramString = "<key state=\"press\" sender=\"Gabbo\">POWER</key>"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("dataString: '\(dataString!)'")
        }
        task.resume()
        
        delay(0.25){
            let paramString2 = "<key state=\"release\" sender=\"Gabbo\">POWER</key>"
            request.HTTPBody = paramString2.dataUsingEncoding(NSUTF8StringEncoding)
            let task2 = session.dataTaskWithRequest(request) {
                (
                let data, let response, let error) in
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("dataString: '\(dataString!)'")
            }
            task2.resume()
        }
        
        delay(0.50){
            self.getSpeakerInfo()
        }
    }
    
    // Trying to get speaker power value (standby or on)
    
    func getSpeakerInfo()
    {
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url : String = "http://\(thisSpeakerIP):8090/now_playing"
        let thisURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(thisURL!) {(data, response, error) in
            let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let xml = SWXMLHash.parse(xmlString as String)
            let val = xml["nowPlaying"]["ContentItem"].element?.attributes["source"]!
            
            // Needs to be on UI thread or there is a long pause.
            
            dispatch_async(dispatch_get_main_queue(), {
                if val == "STANDBY" {
                    self.powerDot.backgroundColor = UIColor.redColor()
                    self.presetTitle.text = "No playing data."
                    self.presetTitle.textColor = UIColor.lightGrayColor()
                } else {
                    self.powerDot.backgroundColor = UIColor(netHex: 0x009900)
                    self.presetTitle.textColor = UIColor.whiteColor()
                    
                    // Check Now Playing for information.
                    
                    self.getNowPlayingInfo()
                }
            })
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
        }
        task.resume()
    }
    
    // MARK: - Now Playing -
    
    func getNowPlayingInfo()
    {
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url : String = "http://\(thisSpeakerIP):8090/now_playing"
        let thisURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(thisURL!) {(data, response, error) in
            let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let xml = SWXMLHash.parse(xmlString as String)
            
            print(xml)
            
            var title = xml["nowPlaying"]["ContentItem"]["itemName"].element?.text!
            title = title?.stringByReplacingOccurrencesOfString("\\", withString: "") //Otto\'s fixed
            
            var source = xml["nowPlaying"]["ContentItem"].element?.attributes["source"]!
            source = source?.stringByReplacingOccurrencesOfString("_", withString: " ") //internet_radio fixed
            
            // Needs to be on UI thread or there is a long pause.
            
            dispatch_async(dispatch_get_main_queue(), {
                if title != nil && source != nil {
                    self.presetTitle.text = "\(title!)\n\(source!.lowercaseString)"
                    let myCharacters = self.titleConstructor.translateString(title!)
                    self.tileDisplay.updateTextDisplay(myCharacters)
                }
            })

            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            
        }
        task.resume()
    }

    // MARK: - Volume -
    
    func getSpeakerVolume()
    {
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url : String = "http://\(thisSpeakerIP):8090/volume"
        let thisURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(thisURL!) {(data, response, error) in
            let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let xml = SWXMLHash.parse(xmlString as String)
            let val = xml["volume"]["actualvolume"].element?.text
            self.speakerVolume = Int(val!)!
            print("Vol: \(self.speakerVolume), \(Float(self.speakerVolume))")
            let sval = Float(self.speakerVolume)
            
            // Needs to be on UI thread or there is a long pause.
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.setSlider(sval)
            })
            
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
        }
        task.resume()
    }
    
    func setSlider(val:Float){
        UIView.animateWithDuration(0.2, animations: {
            self.volumeSlider.setValue(val, animated:true)
        })
    }
    
    func setSpeakerVolumeFromWatch(val:Int, speakerName: String)
    {
        // A speaker needs to be selected? Or do we send that from the watch? Probably from the watch. Needs to match up.
        if selIndex == -1 {
            return
        }
        
        // Speaker name to loop for IP address.
        var foundIPAddress = ""
        for i in 0..<speakerObjectArray.count
        {
            if speakerName == speakerObjectArray[i].Name
            {
                foundIPAddress = speakerObjectArray[i].IPAddress
                
                // We should select it in the tableview too. No - should be selected already - this creates redraws.
                
                let rowToSelect = NSIndexPath(forRow: i, inSection: 0)
                tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: .None)
                //tableView(tableView, didSelectRowAtIndexPath: rowToSelect)
                
                break
            }
        }

        let thisSpeakerIP = foundIPAddress //speakerObjectArray[selIndex].IPAddress
        let url = NSURL(string:"http://\(thisSpeakerIP):8090/volume")
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let paramString = "<volume>\(val)</volume>"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("dataString: '\(dataString!)'")
        }
        task.resume()
    }
    
    func setSelectedSpeakerVolume()
    {
        let val = Int(volumeSlider.value)
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url = NSURL(string:"http://\(thisSpeakerIP):8090/volume")
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let paramString = "<volume>\(val)</volume>"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("dataString: '\(dataString!)'")
        }
        task.resume()
    }

    // For the currently selected device, retrieve the presets data for it.
    
    func getPresetsData()
    {
        let thisSpeakerIP = speakerObjectArray[selIndex].IPAddress
        let url : String = "http://\(thisSpeakerIP):8090/presets"
        let thisURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(thisURL!) {(data, response, error) in
            let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let xml = SWXMLHash.parse(xmlString as String)
            
            // Remove any previous preset buttons.
            
            self.presetObjectArray.removeAll()
            dispatch_async(dispatch_get_main_queue(), {
                for view in self.presetButtonContainer.subviews {
                    view.removeFromSuperview()
                }
            })
            
            for elem in xml["presets"]["preset"]
            {
                let thisID = elem.element!.attributes["id"]
                var thisIDInt = Int(thisID!)
                thisIDInt = thisIDInt! - 1 // So it's zero-based.
                
                var thisSource = elem["ContentItem"].element!.attributes["source"]
                thisSource = thisSource?.stringByReplacingOccurrencesOfString("_", withString: " ")
                thisSource = thisSource?.lowercaseString
                thisSource = thisSource?.capitalizedString
                
                var thisName = elem["ContentItem"]["itemName"].element!.text
                thisName = thisName?.stringByReplacingOccurrencesOfString("\\", withString: "")
                
                let thisPreset:Preset = Preset(id: thisIDInt!, source: thisSource!, name: thisName!)
                self.presetObjectArray.append(thisPreset)
            }
            
            // Loop through all of the presetObjects.
            
            dispatch_async(dispatch_get_main_queue(), {
                
                var positionX:CGFloat = 7.0
                var positionY:CGFloat = 10.0
                
                for i in 0..<self.presetObjectArray.count
                {
                    let ind = self.presetObjectArray[i].id + 1
                    let nam = self.presetObjectArray[i].name
                    let src = self.presetObjectArray[i].source
                    
                    let presetButton = PresetButtonView(index: ind, name: nam, source: src)
                    presetButton.frame = CGRect(x: positionX, y: positionY, width: presetButton.frame.size.width, height: presetButton.frame.size.height)
                    presetButton.delegate = self
                    self.presetButtonContainer.addSubview(presetButton)
                    
                    if i == 2 {
                        positionX = 7.0
                        positionY = positionY + presetButton.frame.height + 5
                    } else {
                        positionX = positionX + presetButton.frame.width + 5
                    }
                }
            })
        }
        task.resume()
    }

    
    // Hide the status bar.
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakerObjectArray.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(speakerObjectArray[indexPath.row].Name)
        selIndex = indexPath.row
        UIView.animateWithDuration(0.5, animations: {
            self.bottomBar.alpha = 1.0
            
        })
        
        // 1. Determine if the speaker is in standby or is actually on.
        
        self.getSpeakerInfo()
        
        // 2. Get the volume and set it.
        
        self.getSpeakerVolume()
        
        // 3. Get the presets data for this speaker.
        
        self.getPresetsData()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
        cell.textLabel!.text = speakerObjectArray[indexPath.row].Name //speakerArray[indexPath.row]
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
        cell.backgroundColor = UIColor.clearColor()
        
        cell.selectionStyle = .Blue
        //let v = UIView()
        //v.frame = cell.frame
        //v.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6)
        //cell.selectedBackgroundView = v
        
        // Make sure the IP Address has been found and appended to the array first. Can be out of index.
        
        if indexPath.row < speakerIPAddresses.count {
            cell.detailTextLabel!.text = "IP: \(speakerObjectArray[indexPath.row].IPAddress), MAC: \(speakerObjectArray[indexPath.row].MACAddress)"
            cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
        }
        
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        img.contentMode = .ScaleAspectFit
        
        // Associate device images with product.
        
        let speakerName = speakerObjectArray[indexPath.row].DeviceType
        if speakerName == "Lifestyle" {
            img.image = UIImage(named: "lifestyle.png")
        } else if speakerName == "SoundTouch 30" {
            img.image = UIImage(named: "soundtouch_30.png")
        } else if speakerName == "SoundTouch 20" {
            img.image = UIImage(named: "soundtouch_20.png")
        } else if speakerName == "SoundTouch Portable" {
            img.image = UIImage(named: "soundtouch_20.png")
        } else if speakerName == "SoundTouch 10" {
            img.image = UIImage(named: "soundtouch_10.png")
        } else if speakerName == "Wave SoundTouch" {
            img.image = UIImage(named: "wave_soundtouch.png")
        } else if speakerName == "SoundTouch SA-5" {
            img.image = UIImage(named: "sa5.png")
        } else if speakerName == "SoundTouch SA-4"{
            img.image = UIImage(named: "sa5.png")
        } else {
            img.image = UIImage(named: "soundtouch_20.png")
        }
        
        cell.imageView?.image = img.image
        
        /*
         Device identifier strings
         ========================
         Lifestyle
         SoundTouch 10
         SoundTouch 20
         SoundTouch 30
         Wave SoundTouch
         SoundTouch SA-5
        */
        
        return cell
    }
}

class BMNSDelegate : NSObject, NSNetServiceDelegate
{    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func netServiceWillPublish(sender: NSNetService) {
        print("netServiceWillPublish:\(sender)");
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        print("netServiceDidPublish:\(sender)")
        
        //We are done discovering. Let's show the user what we've found.
        
        let window = UIApplication.sharedApplication().keyWindow
        let vc = window?.rootViewController as! ViewController
        
        print("\(vc.speakerIPAddresses.count) speakers found.")
        
        for i in 0..<vc.speakerIPAddresses.count {
            self.fetchSpeakerMacAddress( vc.speakerIPAddresses[i] )
        }
        
        // Let things settle before we try to display in the tableview.
        
        delay( 7.0 )
        {
            EDProgressView.shared.hideProgressView()
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .SpellOutStyle
            let word = formatter.stringFromNumber(vc.speakerObjectArray.count)!.uppercaseString
            vc.header.text = "\(word) SOUNDTOUCH UNITS DISCOVERED"
            vc.headerSecond.hidden = false
            vc.tableView.reloadData()
            
            
            
            
            
            //Tell the Watch Extension of our discoveries.
            
            if vc.speakerObjectArray.count > 0 {
                print("We found speakers.")
            } else {
                print("We found no speakers.")
                return
            }
            
            
            var thisDictionary = [String:String]()
            for (index,speaker) in vc.speakerObjectArray.enumerate(){
                thisDictionary["speaker_\(index)"] = speaker.Name
            }
                        
            vc.session.sendMessage(thisDictionary, replyHandler: {(_: [String : AnyObject]) -> Void in
                    // handle reply from iPhone app here
                }, errorHandler: {(error ) -> Void in
                    // catch any errors here
            })
        }
    }
    
    func fetchSpeakerMacAddress( ip:String )
    {
        let url = NSURL(string: "http://" + ip + ":8090/info")        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            /*
             https://github.com/drmohundro/SWXMLHash
             This can parse XML pretty easily. Since we get that as return, bingo!
             */

            if ip == "192.168.1.94" {
                return //hack - something wrong with this IP (diff firmware?) This is VEGAS testing unit?
            }
            
            //let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
            let xmlString = String(data:data!, encoding: NSUTF8StringEncoding)
            let xml = SWXMLHash.parse(xmlString ?? "")
            let mac = xml["info"].element?.attributes["deviceID"] // Need to add colon every 2
            //let finalMacAddress = mac?.pairs.joinWithSeparator(":") // Not needed for API.
            
            let type = xml["info"]["type"].element?.text
            let name = xml["info"]["name"].element?.text
            
            //print("Speaker Info: \(name!): \(type!),   MAC: \(mac!), IP: \(ip)")
            
            if let s = name {
                print(s)
            } else {
                print("No Name found.")
                return
            }
            if let s = mac {
                print(s)
            } else {
                print("No Mac found.")
                return
            }
            if let s = type {
                print(s)
            } else {
                print("No Type found.")
                return
            }
            
            let thisSpeaker = Speaker(ip: "\(ip)", name: name!, mac: mac!, deviceType: type!)
            //print(thisSpeaker)
            
            let window = UIApplication.sharedApplication().keyWindow
            let vc = window?.rootViewController as! ViewController
            vc.speakerObjectArray.append(thisSpeaker)
        }
        task.resume()
    }
      
    func netServiceWillResolve(sender: NSNetService) {
        print("** netServiceWillResolve:\(sender)")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("** netServiceDidNotResolve:\(sender)");
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        print("** netServiceDidResolve:\(sender)")
    }
    
    func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
        print("netServiceDidUpdateTXTRecordData:\(sender)");
    }
    
    func netServiceDidStop(sender: NSNetService) {
        print("netServiceDidStopService:\(sender)")
    }
    
    func netService(sender: NSNetService,
                    didAcceptConnectionWithInputStream inputStream: NSInputStream,
                                                       outputStream stream: NSOutputStream) {
        print("netServiceDidAcceptConnection:\(sender)");
    }
}

class BMBrowserDelegate : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    
    var services = [NSNetService]()
    
    func netServiceDidResolveAddress(sender: NSNetService)
    {
        let window = UIApplication.sharedApplication().keyWindow
        let vc = window?.rootViewController as! ViewController
        
        // Convert the data to IP Address.
        
        let theAddress = sender.addresses!.first! as NSData
        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
        if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                       &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
            if let numAddress = String.fromCString(hostname) {
                //print("CONVERT IP: \(numAddress)")
                vc.speakerIPAddresses.append(numAddress)
                vc.speakerArray.append(sender.name)
            }
        }
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
                           didFindDomain domainName: String,
                                         moreComing moreDomainsComing: Bool) {
        print("netServiceDidFindDomain")
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
                           didRemoveDomain domainName: String,
                                           moreComing moreDomainsComing: Bool) {
        print("netServiceDidRemoveDomain")
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
                           didFindService netService: NSNetService,
                                          moreComing moreServicesComing: Bool) {
        
        if netService.name != "hello" {
            services.append(netService) //retained so resolveWithTimeout will work (netServiceDidResolveAddress)
            netService.delegate = self
            netService.resolveWithTimeout(5.0)
        }
        
        if moreServicesComing == false {
            // Fires 2x. Why? Can't use as event.
        }
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
                           didRemoveService netService: NSNetService,
                                            moreComing moreServicesComing: Bool) {
        print("netServiceDidRemoveService: \(netService.name)")
    }
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser){
        print("netServiceBrowserWillSearch")
    }
    
    func netServiceBrowserDidStopSearch(netServiceBrowser: NSNetServiceBrowser) {
        print("netServiceDidStopSearch")
    }
    
}
