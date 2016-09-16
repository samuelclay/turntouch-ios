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
    var menuType: TTMenuType = .menu_MODE

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.register(TTModeMenuCell.self, forCellWithReuseIdentifier: CollectionViewCellIdentifier)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.white
        self.delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if menuType == .menu_MODE {
            return appDelegate().modeMap.availableModes.count
        } else if menuType == .menu_ACTION {
            return appDelegate().modeMap.availableActions.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifier, for: indexPath) as! TTModeMenuCell
        cell.backgroundColor = UIColor.clear
        cell.menuType = menuType
        cell.activeMode = nil
        if menuType == .menu_MODE {
            cell.modeName = appDelegate().modeMap.availableModes[(indexPath as NSIndexPath).row]
        } else if menuType == .menu_ACTION {
            cell.modeName = appDelegate().modeMap.availableActions[(indexPath as NSIndexPath).row]
        }
        
        cell.setNeedsDisplay()
        
        return cell;
    }
    
}
