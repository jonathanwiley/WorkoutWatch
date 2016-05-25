//
//  ExtensionDelegate.swift
//  WorkoutWatch WatchKit Extension
//
//  Created by Jonathan Wiley on 4/23/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        print("recieved message \(message)")
        
        if let command = message[WatchConnectivityConstants.commandKey] as! String? {
            switch command {
            case WatchConnectivityConstants.startWorkoutCommandString:
                if let workoutTemplateFileName = message[WatchConnectivityConstants.workoutTemplateFileNameKey] as! String? {
                    if let workoutTemplate = WorkoutTemplateService.fetchWorkoutTemplateWithFileName(workoutTemplateFileName) {
                        WorkoutManager.sharedInstance.currentWorkoutController = WorkoutController(workoutTemplate: workoutTemplate)
                        WorkoutManager.sharedInstance.currentWorkoutController?.startWorkout()
                        replyHandler([WatchConnectivityConstants.workoutEndDateKey : (WorkoutManager.sharedInstance.currentWorkoutController?.workoutEndDate)!])
                    }
                }
            default:
                break
            }
        }
    }
}
