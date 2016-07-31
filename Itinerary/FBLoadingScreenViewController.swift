//
//  FBLoadingScreenViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/29/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit

class FBLoadingScreenViewController: UIViewController {
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
