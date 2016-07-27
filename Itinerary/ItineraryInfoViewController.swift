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
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tripSummaryTextView: UITextView!
    var userID: String!
    
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



//            if let profileImageURL = snapshot.value!["PhotoURL"] as? String{
//                let url = NSURL(string: profileImageURL)
//                let imageData = NSData(contentsOfURL: url!)
                //self.profileImageView.image = UIImage(data: imageData!)
            //}
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
