//
//  TTModeNestSetTempOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/1/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNestSetTempOptions: TTOptionsDetailViewController {

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeNestSetTempOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
    }


}
