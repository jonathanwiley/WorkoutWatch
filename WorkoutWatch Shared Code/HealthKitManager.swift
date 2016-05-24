//
//  HealthKitManager.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/15/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import HealthKit

public class HealthKitManager: NSObject {
    
    public static let sharedInstance = HealthKitManager()
    
    public let healthStore = HKHealthStore()
    
    private let ageCharacteristicType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!
    private let heartRateQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    private let activeEnergyBurnedQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
    private let workoutObjectType = HKObjectType.workoutType()
    
    public func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func requestHealthKitPermissionsWithCompletion(completion: (Bool, NSError?) -> Void) {
        
        let readTypes = Set([ageCharacteristicType, heartRateQuantityType, activeEnergyBurnedQuantityType])
        
        let shareTypes = Set([workoutObjectType, activeEnergyBurnedQuantityType])
        
        healthStore.requestAuthorizationToShareTypes(shareTypes, readTypes: readTypes) { (success, error) -> Void in
            if !success {
                print("error when requesting authorization: \(error)")
            }
            completion(success, error)
        }
    }
    
    public func age() -> Int? {
        
        do {
            let birthDate = try healthStore.dateOfBirth()
            let nowDate = NSDate()
            let differenceComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthDate, toDate: nowDate, options: NSCalendarOptions.init(rawValue: 0))
            let age = differenceComponents.year
            return age
        } catch {
            // TODO: handle error
        }
        
        return nil
    }
    
    public func startHeartRateStreamingQuery(anchor: HKQueryAnchor, updateHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void)) {
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateQuantityType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        heartRateQuery.updateHandler = updateHandler
        
        healthStore.executeQuery(heartRateQuery)
    }
    
    public func startActiveEnergyBurnedStreamingQuery(anchor: HKQueryAnchor, updateHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void)) {
        
        let activeEnergyBurnedQuery = HKAnchoredObjectQuery(type: activeEnergyBurnedQuantityType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        activeEnergyBurnedQuery.updateHandler = updateHandler
        
        healthStore.executeQuery(activeEnergyBurnedQuery)
    }
    
}
