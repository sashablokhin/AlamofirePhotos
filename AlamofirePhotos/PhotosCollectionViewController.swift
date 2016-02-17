//
//  PhotosCollectionViewController.swift
//  AlamofirePhotos
//
//  Created by Alexander Blokhin on 16.02.16.
//  Copyright © 2016 Alexander Blokhin. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "cell"
private let footerViewIdentifier = "footerView"

class PhotosCollectionViewController: UICollectionViewController {
    
    var photos = NSMutableOrderedSet()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        Alamofire.request(.GET, "https://api.500px.com/v1/photos", parameters: ["consumer_key": "uiGZOMxiSv7SJITSMZ2G4nwZwLe8Ek0j9SaE4nr0"]).responseJSON { response in
            
            if let JSON = response.result.value {
                let photoInfos = (JSON.valueForKey("photos") as! [NSDictionary]).filter({
                    ($0["nsfw"] as! Bool) == false
                }).map {
                    PhotoInfo(id: $0["id"] as! Int, url: $0["image_url"] as! String)
                }
                
                self.photos.addObjectsFromArray(photoInfos)
                
                self.collectionView!.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhoto" {
            //(segue.destinationViewController as! PhotoViewerViewController).photoID = sender!.integerValue
            //(segue.destinationViewController as! PhotoViewerViewController).hidesBottomBarWhenPushed = true
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
        
        let imageURL = (photos[indexPath.row] as! PhotoInfo).url
        
        Alamofire.request(.GET, imageURL).response { _, _, data, _ in
            let image = UIImage(data: data!)
            cell.imageView.image = image
        }
        
        return cell
    }

    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerViewIdentifier, forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
    }
    
    func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
        
        collectionView!.collectionViewLayout = layout
        
        navigationItem.title = "Featured"
        
        collectionView!.registerClass(PhotosCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.registerClass(PhotosCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    func handleRefresh() {
        
    }
}


class PhotosCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

class PhotosCollectionViewLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
}
