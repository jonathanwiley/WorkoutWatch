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
    func currentHeartRateTargetWasUpdated(minHeartRate: Int, maxHeartRate: Int)
}

public class WorkoutManager: HealthKitWorkoutObserverDelegate  {
    
    static let sharedInstance = WorkoutManager()
    
    var currentHealthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var workoutTimer : NSTimer?
    
    var isWorkoutInProgress = false
    var workoutEndDate: NSDate?
    var workoutStartDate: NSDate?
    
    var workoutTemplate: WorkoutTemplate?
    
    let maxHeartRate: Int
    
    init() {
        maxHeartRate = 220 - HealthKitManager.sharedInstance.age()!
    }
    
    func startWorkout(workoutTemplate: WorkoutTemplate) {
        
        isWorkoutInProgress = true
        self.workoutTemplate = workoutTemplate
        workoutStartDate = NSDate()
        workoutEndDate = workoutStartDate?.dateByAddingTimeInterval(Double(workoutTemplate.durationInMinutes()*60))
        
        currentHealthKitWorkoutObserver = HealthKitWorkoutObserver(delegate: self)
        
        delegate?.workoutDidStart()
        
        delegate?.currentHeartRateTargetWasUpdated(currentWorkoutStep().minHeartRatePercentage*maxHeartRate/100, maxHeartRate: currentWorkoutStep().maxHeartRatePercentage*maxHeartRate/100)
    }
    
    func stopWorkout() {
        
        isWorkoutInProgress = false
        delegate?.workoutDidEnd()
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        
        if (Int(currentHeartRate) < currentWorkoutStep().maxHeartRatePercentage*maxHeartRate/100 && Int(currentHeartRate) > currentWorkoutStep().minHeartRatePercentage*maxHeartRate/100)
        {
            delegate?.newHeartRateReadingIsOnTarget()
        }
        else if (Int(currentHeartRate) > currentWorkoutStep().maxHeartRatePercentage*maxHeartRate/100)
        {
            delegate?.newHeartRateReadingIsAboveTarget()
        }
        else if (Int(currentHeartRate) < currentWorkoutStep().minHeartRatePercentage*maxHeartRate/100)
        {
            delegate?.newHeartRateReadingIsBelowTarget()
        }
        
        delegate?.heartRateWasUpdated(currentHeartRate)
    }
    
    func currentWorkoutStep() -> WorkoutStep {
        return (workoutTemplate?.workoutSteps[0])!
    }
}
