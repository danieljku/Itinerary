//
//  AddItineraryViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/18/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class AddItineraryViewController: UIViewController {
    @IBOutlet weak var itineraryTitleText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var durationText: UITextField!
    @IBOutlet weak var roughCostText: UITextField!
    @IBOutlet weak var categorySegControl: UISegmentedControl!
    @IBOutlet weak var summaryTextView: UITextView!
    let ref = FIRDatabase.database().reference()
    let itineraryID = NSUUID().UUIDString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let itineraryInfoViewController = segue.destinationViewController as! ItineraryInfoViewController
        if segue.identifier == "ItineraryInfo"{
            itineraryInfoViewController.userID = itineraryID
        }
    }
    
    @IBAction func createItineraryButton(sender: AnyObject) {
        var category = "Friends"
        
        if(categorySegControl.selectedSegmentIndex == 0){
            category = "Tourist"
        }else if(categorySegControl.selectedSegmentIndex == 1){
            category = "Date"
        }else if(categorySegControl.selectedSegmentIndex == 2){
            category = "Friends"
        }else if(categorySegControl.selectedSegmentIndex == 3){
            category = "Family"
        }else{
            let alertController = UIAlertController(title: "Choose a category!", message: "", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let itinerary = ["Title": itineraryTitleText.text,
                         "City": cityText.text,
                         "Duration": durationText.text,
                         "Cost": roughCostText.text,
                         "Category": category,
                         "Summary": summaryTextView.text,
                         "UserID": userID
                         ]
        
        ref.child("Itineraries").child(itineraryID).setValue(itinerary)
        ref.child("Users").child(userID!).child("MyItineraries").updateChildValues([itineraryID: itineraryTitleText.text!])
    }

}
