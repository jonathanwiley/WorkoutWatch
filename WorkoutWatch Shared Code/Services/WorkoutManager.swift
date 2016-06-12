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
    
    private(set) var currentHealthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var workoutTimer : NSTimer?
    
    var isWorkoutInProgress = false
    var workoutEndDate: NSDate?
    var workoutStartDate: NSDate?
    
    var workoutTemplate: WorkoutTemplate?
    
    var maxHeartRate: Int?
    
    func startWorkout(workoutTemplate: WorkoutTemplate) {
        
        if let age = HealthKitManager.sharedInstance.age() {
            
            maxHeartRate = 220 - age
            
        } else {
            
            maxHeartRate = 180
        }
        
        isWorkoutInProgress = true
        self.workoutTemplate = workoutTemplate
        workoutStartDate = NSDate()
        workoutEndDate = workoutStartDate!.dateByAddingTimeInterval(Double(workoutTemplate.durationInMinutes()*60))
        
        currentHealthKitWorkoutObserver = HealthKitWorkoutObserver(delegate: self)
        
        delegate!.workoutDidStart()
        
        if let currentWorkoutStep = currentWorkoutStep() {
            
            delegate!.currentHeartRateTargetWasUpdated(currentWorkoutStep.minHeartRatePercentage*maxHeartRate!/100, maxHeartRate: currentWorkoutStep.maxHeartRatePercentage*maxHeartRate!/100)
        }
    }
    
    func stopWorkout() {
        
        if (isWorkoutInProgress) {
            
            isWorkoutInProgress = false
            delegate?.workoutDidEnd()
        }
        else {
            print("Attempting to stop workout that has not been started.")
        }
        
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        
        if let currentWorkoutStep = currentWorkoutStep() {
            
            let maxTargetHeartRate = currentWorkoutStep.maxHeartRatePercentage/100*maxHeartRate!
            let minTargetHeartRate = currentWorkoutStep.minHeartRatePercentage/100*maxHeartRate!
            
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
        }
        
        delegate?.heartRateWasUpdated(currentHeartRate)
    }
    
    func currentWorkoutStep() -> WorkoutStep? {
        
        if let workoutTemplate = workoutTemplate {
            
            let workoutElapsedMinutes = -workoutStartDate!.timeIntervalSinceNow as Double
            var workoutStepsMinutesAccumulator: Double = 0
            
            for workoutStep in workoutTemplate.workoutSteps {
                
                let workoutStepMinutes = Double(workoutStep.minutes)
                
                if workoutElapsedMinutes > workoutStepsMinutesAccumulator + workoutStepMinutes {
                    
                    return workoutStep
                }
                
                workoutStepsMinutesAccumulator += workoutStepMinutes
            }
        }
        
        return nil
    }
}
