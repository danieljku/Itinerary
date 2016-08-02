//
//  ItineraryInfoViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/19/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase

class ItineraryInfoViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeOfItineraryLabel: UILabel!
    @IBOutlet weak var roughtCostLabel: UILabel!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tripSummaryTextView: UITextView!
    @IBOutlet weak var tableViewButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var itineraryID: String!
    var myImages = [UIImage]()
    var prevLocation = "ProfileViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        if prevLocation == "AddItineraryViewController"{
            tableViewButton.title = "Done"
            likeButton.hidden = true
            saveButton.hidden = true
        }else if (prevLocation == "ItinerarySearchViewController" || prevLocation == "ProfileViewController"){
            tableViewButton.title = "Back"
        }
        
        // Do any additional setup after loading the view.
        let ref = FIRDatabase.database().reference()
        
        ref.child("Itineraries").child(itineraryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            self.titleLabel.text = snapshot.value!["Title"] as? String
            self.cityLabel.text = snapshot.value!["City"] as? String
            self.timeOfItineraryLabel.text = snapshot.value!["Duration"] as? String
            self.roughtCostLabel.text = "$\((round(100.00 * (Double)((snapshot.value!["Cost"] as? String)!)!))/100.00)"
            self.categoryLabel.text = snapshot.value!["Category"] as? String
            self.tripSummaryTextView.text = snapshot.value!["Summary"] as? String
        })
            
        ref.child("Photos").child(itineraryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var index = 0
            let numOfPhotos = Int(snapshot.childrenCount)
            var storageImages = [UIImage]()
            
            while(index < numOfPhotos){
                if let profileImageURL = snapshot.childSnapshotForPath(String(index)).value!["image"] as? String{
                    let url = NSURL(string: profileImageURL)
                    let imageData = NSData(contentsOfURL: url!)
                    let image  = UIImage(data: imageData!)
                    storageImages.append(image!)
                }
                index += 1
            }
            if (self.prevLocation == "ItinerarySearchViewController" || self.prevLocation == "ProfileViewController"){
                self.myImages = storageImages
            }
            let imageWidth:CGFloat = 120
            let imageHeight:CGFloat = 120
            var xPosition:CGFloat = 0
            var scrollViewSize:CGFloat=0
            
            
            for image in self.myImages {
                let myImageView:UIImageView = UIImageView()
                myImageView.image = image
                
                myImageView.frame.size.width = imageWidth
                myImageView.frame.size.height = imageHeight
                myImageView.frame.origin.x = xPosition
                myImageView.frame.origin.y = 10
                
                self.imageScrollView.addSubview(myImageView)
                xPosition += imageWidth + 10
                scrollViewSize += imageWidth + 10
            }
            self.imageScrollView.contentSize = CGSize(width: scrollViewSize, height: imageHeight)
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarViewController = segue.destinationViewController as! TabBarViewController
        if segue.identifier == "TabBarSelect"{
            if (prevLocation == "AddItineraryViewController" || prevLocation == "ProfileViewController"){
                tabBarViewController.tabBarIndex = 0
            }else{
                tabBarViewController.tabBarIndex = 1
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
