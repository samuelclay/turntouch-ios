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
        return appDelegate().modeMap.availableModes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifier, forIndexPath: indexPath) as! TTModeMenuCell
        cell.backgroundColor = UIColor.clearColor()
        cell.modeName = appDelegate().modeMap.availableModes[indexPath.row]
        return cell;
    }

}
