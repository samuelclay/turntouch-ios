//
//  TTTitleMenuCell.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTTitleMenuCell: UITableViewCell {
    
    var menuTitle = UILabel()
    var menuImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuTitle.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.font = UIFont(name: "Effra", size: 16)
        textLabel?.textColor = UIColor(hex: 0x404A60)

        detailTextLabel?.font = UIFont(name: "Effra", size: 11)
        detailTextLabel?.textColor = UIColor(hex: 0x909AB0)
}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
