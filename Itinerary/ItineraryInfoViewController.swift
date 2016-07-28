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
    
    var userID: String!
    var myImages = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let ref = FIRDatabase.database().reference()
        
        ref.child("Itineraries").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            self.titleLabel.text = snapshot.value!["Title"] as? String
            self.cityLabel.text = snapshot.value!["City"] as? String
            self.timeOfItineraryLabel.text = snapshot.value!["Duration"] as? String
            self.roughtCostLabel.text = "$\((round(100.00 * (Double)((snapshot.value!["Cost"] as? String)!)!))/100.00)"
            self.categoryLabel.text = snapshot.value!["Category"] as? String
            self.tripSummaryTextView.text = snapshot.value!["Summary"] as? String
        })
            
        ref.child("Photos").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var index = 0
            let numOfPhotos = Int(snapshot.childrenCount)
            
            while(index < numOfPhotos){
                if let profileImageURL = snapshot.childSnapshotForPath(String(index)).value!["image"] as? String{
                    let url = NSURL(string: profileImageURL)
                    let imageData = NSData(contentsOfURL: url!)
                    let image  = UIImage(data: imageData!)
                    self.myImages.append(image!)
                }
                index += 1
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
                xPosition += imageWidth
                scrollViewSize += imageWidth
            }
            self.imageScrollView.contentSize = CGSize(width: scrollViewSize, height: imageHeight)

        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
