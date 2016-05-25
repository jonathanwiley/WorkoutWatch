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
    
    static let commandKey = "command"
    static let startWorkoutCommandString = "startWorkout"
    static let workoutTemplateFileNameKey = "workoutTemplateFileName"
    static let workoutEndDateKey = "workoutEndDate"
    static let heartRateKey = "heartRate"
    static let requestUpdatedHeartRateKey = "requestUpdatedHeartRateKey"
    
    static let heartRateUpdatedNotificationKey = "com.lunarlincoln.workoutwatch.heartRateUpdatedNotificationKey"
    
    static let sharedInstance = WatchConnectivityManager()
    
    private let session = WCSession.defaultSession()
    
    func activateSession() {
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
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
        
        let message = [WatchConnectivityManager.commandKey : WatchConnectivityManager.startWorkoutCommandString,
                       WatchConnectivityManager.workoutTemplateFileNameKey : workoutTemplate.fileName]
        
        session.sendMessage(message, replyHandler:replyHandler, errorHandler: errorHandler)
    }
    
    func sendUpdatedHeartRateMessage(newHeartRate: Int) {
        
        let message = [WatchConnectivityManager.heartRateKey : newHeartRate]
        
        session.sendMessage(message, replyHandler:nil, errorHandler: nil)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let heartRate = message[WatchConnectivityManager.heartRateKey] as! Int? {
            NSNotificationCenter.defaultCenter().postNotificationName(WatchConnectivityManager.heartRateUpdatedNotificationKey, object: heartRate)
        }
    }
    
    func sendRequestUpdatedHeartRateMessage() {
        
        let message = [WatchConnectivityManager.commandKey : WatchConnectivityManager.requestUpdatedHeartRateKey]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}