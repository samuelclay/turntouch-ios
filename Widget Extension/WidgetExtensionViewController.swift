//
//  WidgetExtensionViewController.swift
//  Widget Extension
//
//  Created by David Sinclair on 2020-04-28.
//  Copyright © 2020 Turn Touch. All rights reserved.
//

import UIKit
import NotificationCenter

class WidgetExtensionViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
