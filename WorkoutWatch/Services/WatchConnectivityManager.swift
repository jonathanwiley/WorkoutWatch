//
//  WatchConnectivityManager.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/24/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    static let sharedInstance = WatchConnectivityManager()
    
    private let session = WCSession.defaultSession()
    
    func activateSession() {
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
            
            if session.paired != true {
                print("Apple Watch is not paired")
            }
            
            if session.watchAppInstalled != true {
                print("WatchKit app is not installed")
            }
        } else {
            print("WatchConnectivity is not supported on this device")
        }
    }
    
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        if let error = error {
            print("error in activitationDidCompleteWithState: \(error)")
        } else {
            print("activitation did complete with state \(activationState)")
        }
    }
    
    func sendStartWorkoutMessage(workoutTemplate: WorkoutTemplate, replyHandler: (([String : AnyObject]) -> Void)?, errorHandler: ((NSError) -> Void)?) {
        
        let message = [WatchConnectivityConstants.commandKey : WatchConnectivityConstants.startWorkoutCommandString,
                       WatchConnectivityConstants.workoutTemplateFileNameKey : workoutTemplate.fileName]
        
        session.sendMessage(message, replyHandler:replyHandler, errorHandler: errorHandler)
    }
}