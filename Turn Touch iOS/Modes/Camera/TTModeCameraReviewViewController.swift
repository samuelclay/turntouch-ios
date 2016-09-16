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
        
        self.view.backgroundColor = UIColor.clear
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX,
            relatedBy: .equal, toItem: self.view, attribute: .centerX,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY,
            relatedBy: .equal, toItem: self.view, attribute: .centerY,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height,
            relatedBy: .equal, toItem: self.view, attribute: .height,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width,
            relatedBy: .equal, toItem: self.view, attribute: .width,
            multiplier: 1.0, constant: 0))
        
        diamondView = TTActionDiamondView(diamondType: .hud)
        self.view.addSubview(diamondView)
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerX,
            relatedBy: .equal, toItem: self.view, attribute: .centerX,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .bottom,
            relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .bottom,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: diamondSize))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 1.3*diamondSize))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func imageTapped(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
