//
//  DownloadedCollectionViewController.swift
//  AlamofirePhotos
//
//  Created by Alexander Blokhin on 16.02.16.
//  Copyright © 2016 Alexander Blokhin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class DownloadedCollectionViewController: UICollectionViewController {
    
    var downloadedPhotoURLs: [NSURL]?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 200.0)
        
        collectionView!.collectionViewLayout = layout
        
        collectionView!.registerClass(DownloadedCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.title = "Downloads"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL? {
            var error: NSError?
            
            let urls = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: nil, options: [])
            
            if error == nil {
                downloadedPhotoURLs = urls as [NSURL]?
                collectionView!.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return downloadedPhotoURLs?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DownloadedCollectionViewCell
        
        let localFileData = NSFileManager.defaultManager().contentsAtPath(downloadedPhotoURLs![indexPath.item].path!)
        
        let image = UIImage(data: localFileData!, scale: UIScreen.mainScreen().scale)
        
        cell.imageView.image = image
        
        return cell
    }
}


class DownloadedCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFit
    }
}






