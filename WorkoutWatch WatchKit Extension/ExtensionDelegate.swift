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

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        print("recieved message \(message)")
        
        if let command = message[WatchConnectivityManager.commandKey] as! String? {
            
            switch command {
            case WatchConnectivityManager.startWorkoutCommandString:
                
                if let workoutTemplateFileName = message[WatchConnectivityManager.workoutTemplateFileNameKey] as! String? {
                    
                    if let workoutTemplate = WorkoutTemplateService.fetchWorkoutTemplateWithFileName(workoutTemplateFileName) {
                        
                        WatchWorkoutManager.sharedWatchInstance.startWorkout(workoutTemplate)
                        replyHandler([WatchConnectivityManager.workoutEndDateKey : (WatchWorkoutManager.sharedWatchInstance.workoutEndDate)!])
                    }
                }
            default:
                break
            }
        }
    }
}
