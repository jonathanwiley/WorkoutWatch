//
//  WorkoutController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/19/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit
import HealthKit

protocol WorkoutControllerDelegate: class {
    func workoutDidStart()
    func workoutDidEnd()
    func heartRateWasUpdated(currentHeartRate: Double)
    func newHeartRateReadingIsAboveTarget()
    func newHeartRateReadingIsOnTarget()
    func newHeartRateReadingIsBelowTarget()
}

class WorkoutController: NSObject, HKWorkoutSessionDelegate {

    weak var delegate: WorkoutControllerDelegate?
    
    private var workoutTimer : NSTimer?
    var workoutEndDate: NSDate?
    
    static let workoutStartedNotificationKey = "com.lunarlincoln.workoutwatch.workoutStartedNotificationKey"
    
    private let workoutObjectType = HKObjectType.workoutType()
    let workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Cycling, locationType: HKWorkoutSessionLocationType.Indoor)
    
    var heartRateAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    private let heartRateUnit = HKUnit(fromString: "count/min")
    private var heartRateSamples = [HKQuantitySample]()
    var currentHeartRate: Double = 0
    
    private var activeEnergyBurnedAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    private let activeEnergyBurnedUnit = HKUnit.kilocalorieUnit()
    private var currentActiveEnergyBurnedQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
    private var activeEnergyBurnedSamples = [HKQuantitySample]()
    var currentActiveEnergyBurned: Double = 0
    
    private let workoutTemplate : WorkoutTemplate
    
    init(workoutTemplate: WorkoutTemplate) {
        
        self.workoutTemplate = workoutTemplate
        
        super.init()
    }
    
    func startWorkout() {

        HealthKitManager.sharedInstance.startHeartRateStreamingQuery(heartRateAnchor, updateHandler: heartRateUpdateHandler)
        
        HealthKitManager.sharedInstance.startActiveEnergyBurnedStreamingQuery(activeEnergyBurnedAnchor, updateHandler: activeEnergyBurnedUpdateHandler)
        
        workoutSession.delegate = self
        HealthKitManager.sharedInstance.healthStore.startWorkoutSession(workoutSession)
        
        workoutEndDate = NSDate(timeIntervalSinceNow: Double(workoutTemplate.durationInMinutes()*60))
    }
    
    private(set) lazy var heartRateUpdateHandler:(HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void = {
        (query: HKAnchoredObjectQuery, samples: [HKSample]?, deletedObjects: [HKDeletedObject]?, anchor: HKQueryAnchor?, error: NSError?) -> Void in
        
        if let error = error {
            print("Error on heart rate query: \(error.localizedDescription)")
            return
        }
        
        guard let newAnchor = anchor else {return}
        self.heartRateAnchor = newAnchor
        
        
        if let deletedHeartRateSamples = deletedObjects {
            
            self.processDeletedHeartRateSamples(deletedHeartRateSamples)
        }
        
        if let addedHeartRateSamples = samples {
            
            self.processAddedHeartRateSamples(addedHeartRateSamples)
        }
        
        self.updateCurrentHeartRate()
    }
    
    private(set) lazy var activeEnergyBurnedUpdateHandler:(HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void = {
        (query: HKAnchoredObjectQuery, samples: [HKSample]?, deletedObjects: [HKDeletedObject]?, anchor: HKQueryAnchor?, error: NSError?) -> Void in
        
        if let error = error {
            print("Error on active energy burned query: \(error.localizedDescription)")
            return
        }
        
        guard let newAnchor = anchor else {return}
        self.activeEnergyBurnedAnchor = newAnchor
        
        if let deletedActiveEnergyBurnedSamples = deletedObjects {
            
            self.processDeletedActiveEnergyBurnedSamples(deletedActiveEnergyBurnedSamples)
        }
        
        if let addedActiveEnergyBurnedSamples = samples {
            
            self.processAddedActiveEnergyBurnedSamples(addedActiveEnergyBurnedSamples)
        }
        
        self.updateCurrentActiveEnergyBurned()
    }

    
    func processDeletedHeartRateSamples(deletedHeartRateSamples: [HKDeletedObject]) {
        
        for deletedHeartRateSample in deletedHeartRateSamples {
            heartRateSamples = heartRateSamples.filter { $0.UUID != deletedHeartRateSample.UUID }
        }
    }
    
    func processAddedHeartRateSamples(addedHeartRateSamples: [HKSample]) {
        
        guard let addedHeartRateQuantitySamples = addedHeartRateSamples as? [HKQuantitySample] else {return}
        
        heartRateSamples.appendContentsOf(addedHeartRateQuantitySamples)
    }
    
    func updateCurrentHeartRate() {
        guard let heartRateFromNewestSample = heartRateSamples.last else {
            // TODO: come up with better way of handling nil heart rate
            currentHeartRate = -1
            return
        }
        currentHeartRate = heartRateFromNewestSample.quantity.doubleValueForUnit(heartRateUnit)
    }
    
    func processDeletedActiveEnergyBurnedSamples(deletedActiveEnergyBurnedSamples: [HKDeletedObject]) {
        
        for deletedActiveEnergyBurnedSample in deletedActiveEnergyBurnedSamples {
            activeEnergyBurnedSamples = activeEnergyBurnedSamples.filter { $0.UUID != deletedActiveEnergyBurnedSample.UUID }
        }
    }
    
    func processAddedActiveEnergyBurnedSamples(addedActiveEnergyBurnedSamples: [HKSample]) {
        
        guard let addedActiveEnergyBurnedQuantitySamples = addedActiveEnergyBurnedSamples as? [HKQuantitySample] else {return}
        
        activeEnergyBurnedSamples.appendContentsOf(addedActiveEnergyBurnedQuantitySamples)
    }
    
    func updateCurrentActiveEnergyBurned() {
        currentActiveEnergyBurned = activeEnergyBurnedSamples.reduce(Double(0)) {$0 + $1.quantity.doubleValueForUnit(activeEnergyBurnedUnit)}
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        
        switch toState {
        case .Running:
            workoutTimer = NSTimer(fireDate: workoutEndDate!, interval: 0, target: self, selector: #selector(workoutTimerExpired), userInfo: nil, repeats: false)
            CFRunLoopAddTimer(CFRunLoopGetCurrent(), workoutTimer, kCFRunLoopCommonModes)
            NSNotificationCenter.defaultCenter().postNotificationName(WorkoutController.workoutStartedNotificationKey, object: nil)
//        case .Ended:
//            hkWorkoutSessionEnded()
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    @objc private func workoutTimerExpired() {
        
        //TODO: open parent application and get it to send a local notification immediately saying that the workout timer has expired
        //http://stackoverflow.com/questions/30102806/trigger-uilocalnotification-from-watchkit
    }
}
