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

public class WorkoutManager: NSObject, HKWorkoutSessionDelegate  {
    
    static let sharedInstance = WorkoutManager()
    
    var currentWorkoutController: WorkoutController?
    
    
    
    
    
    
    
    
    
    
    weak var delegate: WorkoutManagerDelegate?
    
    private static let maxHeartRate = 187.0
    
    private struct WorkoutStep {
        init(durationMinutes: Double, minBPM: Double, maxBPM: Double) {
            self.durationMinutes = durationMinutes
            self.minBPM = minBPM
            self.maxBPM = maxBPM
        }
        var durationMinutes = 0.0
        var minBPM = 0.0
        var maxBPM = 0.0
    }
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private let heartRateQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    private let activeEnergyBurnedQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
    private let workoutObjectType = HKObjectType.workoutType()
    private var currentHeartRateStreamingQuery: HKQuery?
    private var currentActiveEnergyStreamingQuery: HKQuery?
    
    private let heartRateUnit = HKUnit(fromString: "count/min")
    private var activeEnergyUnit = HKUnit.kilocalorieUnit()
    private var currentActiveEnergyQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
    private var activeEnergySamples = [HKQuantitySample]()
    
    private static let workoutSteps = [WorkoutStep(durationMinutes: 20, minBPM: maxHeartRate*0.65, maxBPM: maxHeartRate*0.75)]
    private var currentWorkoutStep: WorkoutStep = workoutSteps[0]
    
    private var workoutTimer : NSTimer?
    
    var isWorkoutInProgress = false
    var workoutEndDate: NSDate?
    
    private override init() {
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            // not available
            return
        }
        
        guard let heartRateQuantityType = heartRateQuantityType, activeEnergyBurnedQuantityType = activeEnergyBurnedQuantityType  else {return}
        let readTypes = Set([heartRateQuantityType, activeEnergyBurnedQuantityType])
        let shareTypes = Set([workoutObjectType, activeEnergyBurnedQuantityType])
        healthStore.requestAuthorizationToShareTypes(shareTypes, readTypes: readTypes) { (success, error) -> Void in
            if success == false {
                // not allowed
            }
        }
    }
    
    func startWorkout() {
        
        isWorkoutInProgress = true

        currentActiveEnergyQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
        activeEnergySamples = []
        
        self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Cycling, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSession?.delegate = self
        healthStore.startWorkoutSession(self.workoutSession!)
        
        workoutEndDate = NSDate(timeIntervalSinceNow: Double(currentWorkoutStep.durationMinutes*60))
        workoutTimer = NSTimer(fireDate: workoutEndDate!, interval: 0, target: self, selector: #selector(workoutTimerExpired), userInfo: nil, repeats: false)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), workoutTimer, kCFRunLoopCommonModes)
    }
    
    func stopWorkout() {
        
        isWorkoutInProgress = false
        
        if let workout = self.workoutSession {
            healthStore.endWorkoutSession(workout)
        }
    }
    
    @objc private func workoutTimerExpired() {
        
        //TODO: open parent application and get it to send a local notification immediately saying that the workout timer has expired
        //http://stackoverflow.com/questions/30102806/trigger-uilocalnotification-from-watchkit
    }
    
    public func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        
        switch toState {
            case .Running:
                hkWorkoutSessionStarted()
            case .Ended:
                hkWorkoutSessionEnded()
            default:
                print("Unexpected state \(toState)")
        }
    }
    
    public func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    private func hkWorkoutSessionStarted() {

//        if let currentHeartRateStreamingQuery = createHeartRateStreamingQuery()
//        {
//            healthStore.executeQuery(currentHeartRateStreamingQuery)
//        }
//        
//        if let currentActiveEnergyStreamingQuery = createActiveEnergyStreamingQuery()
//        {
//            healthStore.executeQuery(currentActiveEnergyStreamingQuery)
//        }
//        
//        if let hkWorkoutDelegate = delegate
//        {
//            hkWorkoutDelegate.workoutDidStart()
//        }
    }
//
    private func hkWorkoutSessionEnded() {
//
//        if let query = createHeartRateStreamingQuery()
//        {
//            healthStore.stopQuery(query)
//        }
//        
//        if let activeEnergyQuery = createActiveEnergyStreamingQuery()
//        {
//            healthStore.stopQuery(activeEnergyQuery)
//        }
//        
//        saveWorkout()
//        
//        if let hkWorkoutDelegate = delegate
//        {
//            hkWorkoutDelegate.workoutDidEnd()
//        }
    }
    
//    private func createHeartRateStreamingQuery() -> HKQuery? {
//        
//        guard let quantityType = heartRateQuantityType else { return nil }
//        
//        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: heartRateAnchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, anchor, error) -> Void in
//            
//            if let error = error {
//                print("Error creating heart rate query: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let newAnchor = anchor else {return}
//            self.heartRateAnchor = newAnchor
//            
//            self.updateHeartRate(sampleObjects)
//        }
//        
//        heartRateQuery.updateHandler = {(query, samples, deleteObjects, anchor, error) -> Void in
//            
//            guard let newAnchor = anchor else {return}
//            self.heartRateAnchor = newAnchor
//            
//            self.updateHeartRate(samples)
//        }
//        
//        return heartRateQuery
//    }
    
//    private func createActiveEnergyStreamingQuery() -> HKQuery? {
//        guard let activeEnergyType = activeEnergyBurnedQuantityType else { return nil }
//        
//        let activeEnergyQuery = HKAnchoredObjectQuery(type: activeEnergyType, predicate: nil, anchor: activeEnergyAnchor, limit: Int(HKObjectQueryNoLimit)) { query, samples, deletedObjects, anchor, error in
//            
//            if let error = error {
//                print("Error creating active energy query: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let newAnchor = anchor else {return}
//            self.activeEnergyAnchor = newAnchor
//            
//            self.updateActiveEnergyBurned(samples)
//        }
//        
//        activeEnergyQuery.updateHandler = { query, samples, deletedObjects, anchor, error in
//            
//            if let error = error {
//                print("An error occurred with the `activeEnergyQuery`. The error was: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let newAnchor = anchor else {return}
//            self.activeEnergyAnchor = newAnchor
//            
//            self.updateActiveEnergyBurned(samples)
//        }
//        return activeEnergyQuery
//    }
    
    private func updateHeartRate(samples: [HKSample]?) {
        
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        guard let sample = heartRateSamples.first else {return}
        let currentHeartRate = sample.quantity.doubleValueForUnit(self.heartRateUnit)
        
        if let hkWorkoutDelegate = delegate {
            
            hkWorkoutDelegate.heartRateWasUpdated(currentHeartRate)
            
            if (currentHeartRate < self.currentWorkoutStep.maxBPM && currentHeartRate > self.currentWorkoutStep.minBPM)
            {
                hkWorkoutDelegate.newHeartRateReadingIsOnTarget()
            }
            else if (currentHeartRate > self.currentWorkoutStep.maxBPM)
            {
                hkWorkoutDelegate.newHeartRateReadingIsAboveTarget()
            }
            else if (currentHeartRate < self.currentWorkoutStep.minBPM)
            {
                hkWorkoutDelegate.newHeartRateReadingIsBelowTarget()
            }
        }
    }
    
    private func updateActiveEnergyBurned(samples: [HKSample]?) {
        
        guard let samples = samples as? [HKQuantitySample] else {return}
        
        guard let activeEnergyType = activeEnergyBurnedQuantityType else {return}
        
        let initialActiveEnergy = self.currentActiveEnergyQuantity.doubleValueForUnit(activeEnergyUnit)
        
        let processedResults: (Double, [HKQuantitySample]) = samples.reduce((initialActiveEnergy, [])) { current, sample in
            let accumulatedValue = current.0 + sample.quantity.doubleValueForUnit(activeEnergyUnit)
            
            let ourSample = HKQuantitySample(type: activeEnergyType, quantity: sample.quantity, startDate: sample.startDate, endDate: sample.endDate)
            
            return (accumulatedValue, current.1 + [ourSample])
        }
        
        self.currentActiveEnergyQuantity = HKQuantity(unit: activeEnergyUnit, doubleValue: processedResults.0)
        self.activeEnergySamples += processedResults.1
    }
    
    private func saveWorkout() {
        
        guard let beginDate = workoutSession?.startDate, endDate = workoutSession?.endDate else { return }
        guard healthStore.authorizationStatusForType(activeEnergyBurnedQuantityType!) == .SharingAuthorized && healthStore.authorizationStatusForType(workoutObjectType) == .SharingAuthorized else { return }
        
        /*
         NOTE: There is a known bug where activityType property of HKWorkoutSession returns 0, as of iOS 9.1 and watchOS 2.0.1. So, rather than set it using the value from the `HKWorkoutSession`, set it explicitly for the HKWorkout object.
         */
        let workout = HKWorkout(activityType: HKWorkoutActivityType.Cycling, startDate: beginDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(beginDate), totalEnergyBurned: currentActiveEnergyQuantity, totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0.0), metadata: nil)
        
        let finalActiveEnergySamples = activeEnergySamples
        
        healthStore.saveObject(workout) { [unowned self] success, error in
            if let error = error where !success {
                print("An error occurred saving the workout. The error was: \(error.localizedDescription)")
                return
            }
            
            if success && finalActiveEnergySamples.count > 0 {
                self.healthStore.addSamples(finalActiveEnergySamples, toWorkout: workout) { success, error in
                    if let error = error where !success {
                        print("An error occurred adding samples to the workout. The error was: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
