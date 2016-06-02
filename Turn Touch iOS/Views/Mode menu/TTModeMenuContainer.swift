//
//  TTModeMenuContainer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTMenuType {
    case MENU_MODE
    case MENU_ACTION
    case MENU_ADD_MODE
    case MENU_ADD_ACTION
}

class TTModeMenuContainer: UIView {

    var menuType: TTMenuType = .MENU_MODE
    var bordersView = TTModeMenuBordersView()
    var collectionView: TTModeMenuCollectionView!
    
    init(menuType: TTMenuType) {
        super.init(frame: CGRectZero)
        translatesAutoresizingMaskIntoConstraints = false
        self.menuType = menuType
        
        self.backgroundColor = UIColor.clearColor()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(200, 50)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = TTModeMenuCollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Height,
            relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Width,
            relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top,
            relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))

        self.addSubview(bordersView)
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Height,
            relatedBy: .Equal, toItem: collectionView, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Width,
            relatedBy: .Equal, toItem: collectionView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Top,
            relatedBy: .Equal, toItem: collectionView, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
}
