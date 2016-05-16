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
    
    let healthStore = HKHealthStore()
    
    private let heartRateQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    private let activeEnergyBurnedQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
    private let workoutObjectType = HKObjectType.workoutType()
    
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func requestHealthKitPermissionsWithCompletion(completion: (Bool, NSError?) -> Void) {
        
        let readTypes = Set([heartRateQuantityType, activeEnergyBurnedQuantityType])
        
        let shareTypes = Set([workoutObjectType, activeEnergyBurnedQuantityType])
        
        healthStore.requestAuthorizationToShareTypes(shareTypes, readTypes: readTypes) { (success, error) -> Void in
            if !success {
                print("error when requesting authorization: \(error)")
            }
            completion(success, error)
        }
    }
    
}
