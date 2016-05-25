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

public class WorkoutManager: NSObject, HealthKitWorkoutObserverDelegate  {
    
    static let sharedInstance = WorkoutManager()
    
    var currentHealthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var workoutTimer : NSTimer?
    
    var isWorkoutInProgress = false
    var workoutEndDate: NSDate?
    var workoutStartDate: NSDate?
    
    var workoutTemplate: WorkoutTemplate?
    
    var maxHeartRate: Int?
    
    func startWorkout(workoutTemplate: WorkoutTemplate) {
        
        maxHeartRate = 220 - HealthKitManager.sharedInstance.age()!
        
        isWorkoutInProgress = true
        self.workoutTemplate = workoutTemplate
        workoutStartDate = NSDate()
        workoutEndDate = workoutStartDate?.dateByAddingTimeInterval(Double(workoutTemplate.durationInMinutes()*60))
        
        currentHealthKitWorkoutObserver = HealthKitWorkoutObserver(delegate: self)
        
        delegate?.workoutDidStart()
        
        delegate?.currentHeartRateTargetWasUpdated(currentWorkoutStep().minHeartRatePercentage*maxHeartRate!/100, maxHeartRate: currentWorkoutStep().maxHeartRatePercentage*maxHeartRate!/100)
    }
    
    func stopWorkout() {
        
        isWorkoutInProgress = false
        delegate?.workoutDidEnd()
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        
        let maxTargetHeartRate = currentWorkoutStep().maxHeartRatePercentage/100*maxHeartRate!
        let minTargetHeartRate = currentWorkoutStep().minHeartRatePercentage/100*maxHeartRate!
        
        if (Int(currentHeartRate) < maxTargetHeartRate && Int(currentHeartRate) > minTargetHeartRate)
        {
            delegate?.newHeartRateReadingIsOnTarget()
        }
        else if (Int(currentHeartRate) > maxTargetHeartRate)
        {
            delegate?.newHeartRateReadingIsAboveTarget()
        }
        else if (Int(currentHeartRate) < minTargetHeartRate)
        {
            delegate?.newHeartRateReadingIsBelowTarget()
        }
        
        delegate?.heartRateWasUpdated(currentHeartRate)
    }
    
    func currentWorkoutStep() -> WorkoutStep {
        return (workoutTemplate?.workoutSteps[0])!
    }
}
