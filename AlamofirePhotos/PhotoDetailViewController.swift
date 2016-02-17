//
//  PhotoDetailViewController.swift
//  AlamofirePhotos
//
//  Created by Alexander Blokhin on 17.02.16.
//  Copyright © 2016 Alexander Blokhin. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var highestLabel: UILabel!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var photoInfo: PhotoInfo?
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismiss")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
            
        highestLabel.text = String(format: "%.1f", photoInfo?.highest ?? 0)
        pulseLabel.text = String(format: "%.1f", photoInfo?.pulse ?? 0)
        viewsLabel.text = "\(photoInfo?.views ?? 0)"
        descriptionLabel.text = photoInfo?.desc
    }
        
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
