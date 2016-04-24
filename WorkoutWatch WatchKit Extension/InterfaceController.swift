//
//  InterfaceController.swift
//  WorkoutWatch WatchKit Extension
//
//  Created by Jonathan Wiley on 4/23/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    struct WorkoutStep {
        init(durationMinutes: Double, minBPM: Double, maxBPM: Double) {
            self.durationMinutes = durationMinutes
            self.minBPM = minBPM
            self.maxBPM = maxBPM
        }
        var durationMinutes = 0.0
        var minBPM = 0.0
        var maxBPM = 0.0
    }
    
    static let maxHeartRate = 187.0
    
    static let workoutSteps = [WorkoutStep(durationMinutes: 20, minBPM: maxHeartRate*0.65, maxBPM: maxHeartRate*0.75)]
    var currentWorkoutStep : WorkoutStep = workoutSteps[0]
    
    @IBOutlet var uiInterfaceGroup: WKInterfaceGroup!
    @IBOutlet var timeRemainingTimer: WKInterfaceTimer!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var startStopButton: WKInterfaceButton!
    
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    var isWorkoutInProgress = false
    var heartRateAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var activeEnergyAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    let heartRateUnit = HKUnit(fromString: "count/min")
    var workoutTimer : NSTimer?
    var currentActiveEnergyQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
    var activeEnergySamples = [HKQuantitySample]()
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            // not available
            heartRateLabel.setText("not available")
            return
        }
        
        guard let heartRateQuantityTypeIdentifier = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayNotAllowed()
            return
        }
        
        guard let activeEnergyQuantityTypeIdentifier = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned) else {
            displayNotAllowed()
            return
        }
        
        let readDataTypes = Set([heartRateQuantityTypeIdentifier, activeEnergyQuantityTypeIdentifier])
        let shareDataTypes = Set([HKObjectType.workoutType(), activeEnergyQuantityTypeIdentifier])
        healthStore.requestAuthorizationToShareTypes(shareDataTypes, readTypes: readDataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
    }
    
    func displayNotAllowed() {
        heartRateLabel.setText("not allowed")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func startStopButtonPressed() {
        
        if (isWorkoutInProgress) {
            isWorkoutInProgress = false
            startStopButton.setTitle("Start Workout")
            if let workout = self.workoutSession {
                healthStore.endWorkoutSession(workout)
            }
            uiInterfaceGroup.setBackgroundColor(UIColor.clearColor())
            timeRemainingTimer.stop()
            heartRateLabel.setText("---")
        } else {
            isWorkoutInProgress = true
            // Clear the local Active Energy Burned quantity when beginning a workout session.
            currentActiveEnergyQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
            activeEnergySamples = []
            startStopButton.setTitle("Stop Workout")
            self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Cycling, locationType: HKWorkoutSessionLocationType.Indoor)
            self.workoutSession?.delegate = self
            healthStore.startWorkoutSession(self.workoutSession!)
            let workoutEndDate = NSDate(timeIntervalSinceNow: Double(currentWorkoutStep.durationMinutes*60))
            timeRemainingTimer.setDate(workoutEndDate)
            timeRemainingTimer.start()
            workoutTimer = NSTimer(fireDate: workoutEndDate, interval: 0, target: self, selector: #selector(workoutTimerExpired), userInfo: nil, repeats: false)
            CFRunLoopAddTimer(CFRunLoopGetCurrent(), workoutTimer, kCFRunLoopCommonModes)
        }
    }
    
    func workoutTimerExpired() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Stop)
        uiInterfaceGroup.setBackgroundColor(UIColor.cyanColor())
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            workoutDidStart(date)
        case .Ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    func workoutDidStart(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(query)
        } else {
            heartRateLabel.setText("cannot start")
        }
        if let activeEnergyQuery = createActiveEnergyStreamingQuery(date) {
            healthStore.executeQuery(activeEnergyQuery)
        } else {
            heartRateLabel.setText("active energy error")
        }
    }
    
    func workoutDidEnd(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            heartRateLabel.setText("---")
        } else {
            heartRateLabel.setText("cannot stop")
        }
        if let activeEnergyQuery = createActiveEnergyStreamingQuery(date) {
            healthStore.stopQuery(activeEnergyQuery)
        }
        saveWorkout()
    }
    
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        // adding predicate will not work
        // let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: HKQueryOptions.None)
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: heartRateAnchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.heartRateAnchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.heartRateAnchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func createActiveEnergyStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        // Obtain the `HKObjectType` for active energy burned and the `HKUnit` for kilocalories.
        guard let activeEnergyType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned) else { return nil }
        let energyUnit = HKUnit.kilocalorieUnit()
        
        /*
         Create a results handler to recreate the samples generated by a query of active energy samples so that they can be associated with this app in the move graph. It should be noted that if your app has different heuristics for active energy burned you can generate your own quantities rather than rely on those from the watch. The sum of your sample's quantity values should equal the energy burned value provided for the workout.
         */
        let sampleHandler = { [unowned self] (samples: [HKQuantitySample]) -> Void in
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                
                let initialActiveEnergy = self.currentActiveEnergyQuantity.doubleValueForUnit(energyUnit)
                
                let processedResults: (Double, [HKQuantitySample]) = samples.reduce((initialActiveEnergy, [])) { current, sample in
                    let accumulatedValue = current.0 + sample.quantity.doubleValueForUnit(energyUnit)
                    
                    let ourSample = HKQuantitySample(type: activeEnergyType, quantity: sample.quantity, startDate: sample.startDate, endDate: sample.endDate)
                    
                    return (accumulatedValue, current.1 + [ourSample])
                }
                
                // Update the UI.
                self.currentActiveEnergyQuantity = HKQuantity(unit: energyUnit, doubleValue: processedResults.0)
                
                // Update our samples.
                self.activeEnergySamples += processedResults.1
            }
        }
        
        // Create a query to report new Active Energy Burned samples to our app.
        let activeEnergyQuery = HKAnchoredObjectQuery(type: activeEnergyType, predicate: nil, anchor: activeEnergyAnchor, limit: Int(HKObjectQueryNoLimit)) { query, samples, deletedObjects, anchor, error in
            if let error = error {
                print("An error occurred with the `activeEnergyQuery`. The error was: \(error.localizedDescription)")
                return
            }
            // NOTE: `deletedObjects` are not considered in the handler as there is no way to delete samples from the watch during a workout.
            guard let activeEnergySamples = samples as? [HKQuantitySample] else { return }
            sampleHandler(activeEnergySamples)
            self.activeEnergyAnchor = anchor!
        }
        
        // Assign the same handler to process future samples generated while the query is still active.
        activeEnergyQuery.updateHandler = { query, samples, deletedObjects, anchor, error in
            self.activeEnergyAnchor = anchor!
            if let error = error {
                print("An error occurred with the `activeEnergyQuery`. The error was: \(error.localizedDescription)")
                return
            }
            // NOTE: `deletedObjects` are not considered in the handler as there is no way to delete samples from the watch during a workout.
            guard let activeEnergySamples = samples as? [HKQuantitySample] else { return }
            sampleHandler(activeEnergySamples)
        }
        return activeEnergyQuery
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            self.heartRateLabel.setText(String(UInt16(value)) + " BPM")
            if (!self.workoutTimer!.valid) {
                WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Stop)
            }
            else {
                if (value > self.currentWorkoutStep.minBPM && value < self.currentWorkoutStep.maxBPM) {
                    self.uiInterfaceGroup.setBackgroundColor(UIColor.clearColor())
                } else if (value > self.currentWorkoutStep.maxBPM) {
                    self.uiInterfaceGroup.setBackgroundColor(UIColor.redColor())
                    WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Failure)
                } else if (value < self.currentWorkoutStep.minBPM) {
                    self.uiInterfaceGroup.setBackgroundColor(UIColor.greenColor())
                    WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
                }
            }
        }
    }

    func saveWorkout() {
        // Obtain the `HKObjectType` for active energy burned.
        guard let activeEnergyType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned) else {
            return
        }
        
        // Only proceed if both `beginDate` and `endDate` are non-nil.
        print(workoutSession?.startDate)
        print(workoutSession?.endDate)
        guard let beginDate = workoutSession?.startDate, endDate = workoutSession?.endDate else { return }
        
        /*
         NOTE: There is a known bug where activityType property of HKWorkoutSession returns 0, as of iOS 9.1 and watchOS 2.0.1. So, rather than set it using the value from the `HKWorkoutSession`, set it explicitly for the HKWorkout object.
         */
        let workout = HKWorkout(activityType: HKWorkoutActivityType.Cycling, startDate: beginDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(beginDate), totalEnergyBurned: currentActiveEnergyQuantity, totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0.0), metadata: nil)
        
        // Save the array of samples that produces the energy burned total
        let finalActiveEnergySamples = activeEnergySamples
        
        guard healthStore.authorizationStatusForType(activeEnergyType) == .SharingAuthorized && healthStore.authorizationStatusForType(HKObjectType.workoutType()) == .SharingAuthorized else { return }
        
        healthStore.saveObject(workout) { [unowned self] success, error in
            if let error = error where !success {
                print("An error occurred saving the workout. The error was: \(error.localizedDescription)")
                return
            }
            
            // Since HealthKit completion blocks may come back on a background queue, please dispatch back to the main queue.
            if success && finalActiveEnergySamples.count > 0 {
                // Associate the accumulated samples with the workout.
                self.healthStore.addSamples(finalActiveEnergySamples, toWorkout: workout) { success, error in
                    if let error = error where !success {
                        print("An error occurred adding samples to the workout. The error was: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
