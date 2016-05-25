//
//  HealthKitWorkoutObserver.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/24/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthKitWorkoutObserverDelegate: class {
    func heartRateWasUpdated(currentHeartRate: Double)
}

class HealthKitWorkoutObserver: NSObject {
    
    weak var delegate: HealthKitWorkoutObserverDelegate?
    
    var heartRateAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    private let heartRateUnit = HKUnit(fromString: "count/min")
    private var heartRateSamples = [HKQuantitySample]()
    var currentHeartRate: Double = 0
    
    private var activeEnergyBurnedAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    private let activeEnergyBurnedUnit = HKUnit.kilocalorieUnit()
    private var currentActiveEnergyBurnedQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: 0.0)
    private var activeEnergyBurnedSamples = [HKQuantitySample]()
    var currentActiveEnergyBurned: Double = 0
    
    init(delegate: HealthKitWorkoutObserverDelegate) {
        
        self.delegate = delegate
        
        super.init()
        
        HealthKitManager.sharedInstance.startHeartRateStreamingQuery(heartRateAnchor, updateHandler: heartRateUpdateHandler)
        HealthKitManager.sharedInstance.startActiveEnergyBurnedStreamingQuery(activeEnergyBurnedAnchor, updateHandler: activeEnergyBurnedUpdateHandler)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(heartRateWasUpdatedByNotification), name: WatchConnectivityManager.heartRateUpdatedNotificationKey, object: nil)
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
        delegate?.heartRateWasUpdated(currentHeartRate)
        #if os(watchOS)
        WatchConnectivityManager.sharedInstance.sendUpdatedHeartRateMessage(Int(currentHeartRate))
        #endif
    }
    
    func heartRateWasUpdatedByNotification(notification: NSNotification) {
        currentHeartRate = notification.object as! Double
        delegate?.heartRateWasUpdated(currentHeartRate)
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
}
