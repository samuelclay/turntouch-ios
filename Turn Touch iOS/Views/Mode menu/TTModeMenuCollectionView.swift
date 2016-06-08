//
//  TTModeMenuCollectionView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeMenuCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var CollectionViewCellIdentifier = "CollectionViewCellIdentifier"
    var menuType: TTMenuType = .MENU_MODE

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.registerClass(TTModeMenuCell.self, forCellWithReuseIdentifier: CollectionViewCellIdentifier)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clearColor()
        self.delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if menuType == .MENU_MODE {
            return appDelegate().modeMap.availableModes.count
        } else if menuType == .MENU_ACTION {
            return appDelegate().modeMap.availableActions.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifier, forIndexPath: indexPath) as! TTModeMenuCell
        cell.backgroundColor = UIColor.clearColor()
        cell.menuType = menuType
        cell.activeMode = nil
        if menuType == .MENU_MODE {
            cell.modeName = appDelegate().modeMap.availableModes[indexPath.row]
        } else if menuType == .MENU_ACTION {
            cell.modeName = appDelegate().modeMap.availableActions[indexPath.row]
        }
        return cell;
    }

}
