//
//  guest.swift
//  pikicha
//
//  Created by Elvis Tapfumanei on 2017/05/31.
//  Copyright © 2017 Elmunei. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()

class guest: UICollectionViewController {

    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow vertical scroll
        self.collectionView!.alwaysBounceVertical = true
        
        // background color
        self.collectionView?.backgroundColor = .white
        
        // top title
        self.navigationItem.title = guestname.last?.uppercased()
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(guest.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guest.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guest.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts function
        loadPosts()
    }
    
    
    // back function
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    
    // refresh function
    func refresh() {
        refresher.endRefreshing()
        loadPosts()
    }
    
    
    // posts loading function
    func loadPosts() {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    // hold found information in arrays
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    
    // paging
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestname.last!)
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
        
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        // connect data from array to picImg object from pictureCell class
        picArray[indexPath.row].getDataInBackground (block: { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! header
        
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
                    let alert = UIAlertController(title: "🚫", message: "User \(guestname.last!.uppercased()) not found!", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                
                // find related to user information
                for object in objects! {
                    header.fullnameLbl.text = (object.object(forKey: "fullname") as? String)?.lowercased()
                    header.bioLbl.text = object.object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = object.object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) -> Void in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
                
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 2. Show do current user follow guest or do not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("FOLLOW", for: UIControlState())
                    header.button.backgroundColor = .lightGray
                } else {
                    header.button.setTitle("FOLLOWING", for: UIControlState())
                    header.button.backgroundColor = UIColor(red: 8/255, green: 165/255, blue: 137/255, alpha: 1.0)
                }
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 3. Count statistics
        // count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 4. Implement tap gestures
        // tap to posts label
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guest.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap to followers label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guest.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap to followings label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guest.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        
        return header
    }
    
    
    // tapped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTap() {
        user = guestname.last!
        category = "followers"
        
        // defind followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "Followers") as! Followers
        
        // navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    // tapped followings label
    func followingsTap() {
        user = guestname.last!
        category = "following"
        
        // define followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "Followers") as! Followers
        
        // navigate to it
        self.navigationController?.pushViewController(followings, animated: true)
        
    }
    
    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "posts") as! posts
        self.navigationController?.pushViewController(post, animated: true)
    }
    
}
