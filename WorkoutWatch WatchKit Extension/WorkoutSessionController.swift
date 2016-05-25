//
//  WorkoutController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/19/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutSessionController: NSObject, HKWorkoutSessionDelegate {
    
    let workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Cycling, locationType: HKWorkoutSessionLocationType.Indoor)
    
    func startWorkout() {
        
        workoutSession.delegate = self
        HealthKitManager.sharedInstance.healthStore.startWorkoutSession(workoutSession)
    }
    
    func endWorkout() {
        
        HealthKitManager.sharedInstance.healthStore.endWorkoutSession(workoutSession)
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        
        print("workoutSession changed to state \(toState)")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
}
