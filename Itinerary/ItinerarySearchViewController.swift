//
//  ItinerarySearchViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/19/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase

class ItinerarySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let ref = FIRDatabase.database().reference()
    var itineraryArray = [FIRDataSnapshot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.child("Itineraries").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var snaps = [FIRDataSnapshot]()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    snaps.append(snap)
                }
                self.itineraryArray = snaps
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sections, withRowAnimation: .Fade)
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ItineraryInfo" {
                let indexPath = tableView.indexPathForSelectedRow!
                let itineraryInfoViewController = segue.destinationViewController as! ItineraryInfoViewController
                itineraryInfoViewController.userID = self.itineraryArray[indexPath.row].key
                itineraryInfoViewController.prevLocation = "ItinerarySearchViewController"
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itineraryArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itineraryTableViewCell", forIndexPath: indexPath) as! ItinerarySearchTableViewCell
        
        dispatch_async(dispatch_get_main_queue()) {
            let row = indexPath.row
            
            let userID = self.itineraryArray[row]
            self.ref.child("Itineraries").child(userID.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                cell.titleLabel.text = snapshot.value!["Title"] as? String
                cell.cityLabel.text = snapshot.value!["City"] as? String
                cell.costLabel.text = snapshot.value!["Cost"] as? String
                cell.categoryLabel.text = snapshot.value!["Category"] as? String
            })
            self.ref.child("Photos").child(userID.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let profileImageURL = snapshot.childSnapshotForPath(String(0)).value!["image"] as? String{
                    let url = NSURL(string: profileImageURL)
                    let imageData = NSData(contentsOfURL: url!)
                    let image  = UIImage(data: imageData!)
                    cell.itineraryImage.image = image
                }
            })
            
        }
        return cell
    }

}
