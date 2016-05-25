//
//  WatchWorkoutManager.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/25/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import Foundation

class WatchWorkoutManager: WorkoutManager {
    
    static let sharedWatchInstance = WatchWorkoutManager()
    
    var currentWorkoutSessionController: WorkoutSessionController?

    override func startWorkout(workoutTemplate: WorkoutTemplate) {
        
        super.startWorkout(workoutTemplate)
        
        currentWorkoutSessionController = WorkoutSessionController()
        currentWorkoutSessionController?.startWorkout()
    }
    
    override func stopWorkout() {
        
        super.stopWorkout()
        
        currentWorkoutSessionController?.endWorkout()
        
        let workoutStartDate = (currentWorkoutSessionController?.workoutSession.startDate)!
        let workoutEndDate = NSDate()
        let activeEnergySamples = (currentHealthKitWorkoutObserver?.activeEnergyBurnedSamples)!
        let totalKiloCaloriesBurned = (currentHealthKitWorkoutObserver?.currentActiveEnergyBurned)!
        
        HealthKitManager.sharedInstance.saveWorkout(workoutStartDate, endDate: workoutEndDate, activeEnergySamples: activeEnergySamples, totalKiloCaloriesBurned: totalKiloCaloriesBurned)
    }
}
