//
//  OnboardingAgeViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/16/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class OnboardingAgeViewController: UIViewController {

    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let age = HealthKitManager.sharedInstance.age() {
            ageLabel.text = String(age)
        }
    }
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: { 
            Defaults[.hasCompletedOnboarding] = true
        })
    }
}
