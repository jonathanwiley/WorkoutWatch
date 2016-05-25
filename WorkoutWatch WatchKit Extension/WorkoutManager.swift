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
    
    var currentWorkoutSessionController: WorkoutSessionController?
    
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
        
        currentWorkoutSessionController = WorkoutSessionController()
        currentWorkoutSessionController?.startWorkout()
        
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
    

//    
//    private func saveWorkout() {
//        
//        guard let beginDate = workoutSession?.startDate, endDate = workoutSession?.endDate else { return }
//        guard healthStore.authorizationStatusForType(activeEnergyBurnedQuantityType!) == .SharingAuthorized && healthStore.authorizationStatusForType(workoutObjectType) == .SharingAuthorized else { return }
//        
//        /*
//         NOTE: There is a known bug where activityType property of HKWorkoutSession returns 0, as of iOS 9.1 and watchOS 2.0.1. So, rather than set it using the value from the `HKWorkoutSession`, set it explicitly for the HKWorkout object.
//         */
//        let workout = HKWorkout(activityType: HKWorkoutActivityType.Cycling, startDate: beginDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(beginDate), totalEnergyBurned: currentActiveEnergyQuantity, totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0.0), metadata: nil)
//        
//        let finalActiveEnergySamples = activeEnergySamples
//        
//        healthStore.saveObject(workout) { [unowned self] success, error in
//            if let error = error where !success {
//                print("An error occurred saving the workout. The error was: \(error.localizedDescription)")
//                return
//            }
//            
//            if success && finalActiveEnergySamples.count > 0 {
//                self.healthStore.addSamples(finalActiveEnergySamples, toWorkout: workout) { success, error in
//                    if let error = error where !success {
//                        print("An error occurred adding samples to the workout. The error was: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
}
