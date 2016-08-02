//
//  TTModeCameraReviewViewController.swift
//  
//
//  Created by Samuel Clay on 8/1/16.
//
//

import UIKit

class TTModeCameraReviewViewController: UIViewController {
    
    var image: UIImage
    var imageView: UIImageView!
    var closeButton: UIButton!
    var diamondView: TTActionDiamondView!
    let diamondSize: CGFloat = 272

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFit
        self.view.addSubview(imageView)
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX,
            relatedBy: .Equal, toItem: self.view, attribute: .CenterX,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY,
            relatedBy: .Equal, toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height,
            relatedBy: .Equal, toItem: self.view, attribute: .Height,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width,
            relatedBy: .Equal, toItem: self.view, attribute: .Width,
            multiplier: 1.0, constant: 0))
        
        diamondView = TTActionDiamondView(diamondType: .HUD)
        self.view.addSubview(diamondView)
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterX,
            relatedBy: .Equal, toItem: self.view, attribute: .CenterX,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Bottom,
            relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Height,
            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
            multiplier: 1.0, constant: diamondSize))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Width,
            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
            multiplier: 1.0, constant: 1.3*diamondSize))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func imageTapped(gesture: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
