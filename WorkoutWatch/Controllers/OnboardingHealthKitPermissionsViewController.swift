//
//  OnboardingHealthKitPermissionsViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/15/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class OnboardingHealthKitPermissionsViewController: UIViewController {
    
    @IBAction func allowHealthKitAccessButtonTapped(sender: UIButton) {
        
        HealthKitManager.sharedInstance.requestHealthKitPermissionsWithCompletion { (success, error) in
            // TODO: handle failure
            dispatch_async(dispatch_get_main_queue(), { 
                self.performSegueWithIdentifier("OnboardingAgeViewControllerSegue", sender: nil)
            })
        }
    }

}
