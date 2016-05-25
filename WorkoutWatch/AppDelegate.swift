//
//  AppDelegate.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 4/23/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit
import HealthKit
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        WatchConnectivityManager.sharedInstance.activateSession()
        
        showOnboardingIfNecessary()
        
        return true
    }
    
    func showOnboardingIfNecessary() {
        
        if (!Defaults[.hasCompletedOnboarding]) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let onboardingNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("OnboardingNavigationViewController")
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.presentViewController(onboardingNavigationViewController, animated: false, completion: nil)
        }
    }

    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        
        self.healthStore.handleAuthorizationForExtensionWithCompletion { success, error in
            
        }
    }

}

