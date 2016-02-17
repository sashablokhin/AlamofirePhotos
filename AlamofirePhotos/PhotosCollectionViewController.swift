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
    
    var populatingPhotos = false
    var currentPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        populatePhotos()
        
        /*
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
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhoto" {
            (segue.destinationViewController as! PhotoViewController).photoID = sender!.integerValue
            (segue.destinationViewController as! PhotoViewController).hidesBottomBarWhenPushed = true
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        /*
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
        
        let imageURL = (photos[indexPath.row] as! PhotoInfo).url
        
        Alamofire.request(.GET, imageURL).response { _, _, data, _ in
            let image = UIImage(data: data!)
            cell.imageView.image = image
        }
        
        return cell*/
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
        
        let imageURL = (photos.objectAtIndex(indexPath.row) as! PhotoInfo).url
        
        cell.imageView.image = nil
        cell.request?.cancel()
        
        cell.request = Alamofire.request(.GET, imageURL).responseImage {
            response in
            
            let error = response.result.error
            let image = response.result.value
            
            if error == nil && image != nil {
                cell.imageView.image = image
            }
        }
        
        return cell
    }

    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerViewIdentifier, forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populatePhotos()
        }
    }
    
    func populatePhotos() {
        if populatingPhotos {
            return
        }
        
        populatingPhotos = true
        
        Alamofire.request(Five100px.Router.PopularPhotos(self.currentPage)).responseJSON {
            response in
            
            if response.result.error == nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    
                    if let JSON = response.result.value {
                        
                        // Use Swift’s filter function to filter out NSFW (Not Safe For Work) images
                        
                        let photoInfos = ((JSON as! NSDictionary).valueForKey("photos") as! [NSDictionary]).filter({ ($0["nsfw"] as! Bool) == false }).map { PhotoInfo(id: $0["id"] as! Int, url: $0["image_url"] as! String) }
                    
                        let lastItem = self.photos.count
                        self.photos.addObjectsFromArray(photoInfos)

                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }

                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                    
                        self.currentPage++
                    }
                }
            }
            self.populatingPhotos = false
        }
    }
    
    func handleRefresh() {
        
    }
}


class PhotosCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    var request: Alamofire.Request?
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
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
