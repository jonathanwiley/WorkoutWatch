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
    
    private let ageCharacteristicType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!
    private let heartRateQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    private let activeEnergyBurnedQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
    private let workoutObjectType = HKObjectType.workoutType()
    
    func isHealthKitAvailable() -> Bool {
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
            let birthDay = try healthStore.dateOfBirth()
            let today = NSDate()
            let differenceComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions.init(rawValue: 0))
            let age = differenceComponents.year
            return age
        } catch {
            // TODO: handle error
        }
        
        return nil
    }
    
}
