//
//  GenericTileDisplay.swift
//  STBonjour
//
//  Created by Eric Dolecki on 7/8/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import UIKit

class GenericTileDisplay: UIView
{
    var myLabel: UILabel!
    var myBoundBox: UIView!
    var myFrame: CGRect!
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        myFrame = frame
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.image = UIImage(named: "abstract.png")
        imageView.contentMode = .ScaleAspectFit
        
        myBoundBox = UIView(frame:CGRect(x: 2, y: 2, width: frame.size.width - 4, height: frame.size.height - 4))
        myBoundBox.layer.cornerRadius = 5.0
        myBoundBox.layer.borderWidth = 1.0
        myBoundBox.layer.borderColor = UIColor(netHex: 0xFFFFFF).colorWithAlphaComponent(0.4).CGColor
        
        myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        myLabel.textAlignment = .Center
        myLabel.textColor = UIColor(netHex: 0xFFFFFF)
        myLabel.font = UIFont(name: "AvenirNext-Bold", size: 26.0)
        myLabel.lineBreakMode = .ByTruncatingTail
        myLabel.adjustsFontSizeToFitWidth = true
        myLabel.minimumScaleFactor = 0.5
        
        self.addSubview(imageView)
        self.addSubview(myBoundBox)
        self.addSubview(myLabel)
    }
    
    func updateTextDisplay(sValue:String){
        myLabel.text = sValue
    }
}