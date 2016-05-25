//
//  WorkoutManager.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 4/23/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: class {
    func workoutDidStart()
    func workoutDidEnd()
    func heartRateWasUpdated(currentHeartRate: Double)
    func newHeartRateReadingIsAboveTarget()
    func newHeartRateReadingIsOnTarget()
    func newHeartRateReadingIsBelowTarget()
}

public class WorkoutManager: NSObject, HealthKitWorkoutObserverDelegate  {
    
    static let sharedInstance = WorkoutManager()
    
    var currentHealthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var workoutTimer : NSTimer?
    
    var isWorkoutInProgress = false
    var workoutEndDate: NSDate?
    var workoutStartDate: NSDate?
    
    var workoutTemplate: WorkoutTemplate?
    
    func startWorkout(workoutTemplate: WorkoutTemplate) {
        
        isWorkoutInProgress = true
        self.workoutTemplate = workoutTemplate
        workoutStartDate = NSDate()
        workoutEndDate = workoutStartDate?.dateByAddingTimeInterval(Double(workoutTemplate.durationInMinutes()*60))
        
        currentHealthKitWorkoutObserver = HealthKitWorkoutObserver(delegate: self)
        
        delegate?.workoutDidStart()
    }
    
    func stopWorkout() {
        
        isWorkoutInProgress = false
        delegate?.workoutDidEnd()
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        delegate?.heartRateWasUpdated(currentHeartRate)
    }
}
