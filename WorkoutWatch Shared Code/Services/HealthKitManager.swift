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
                print("Error when requesting authorization: \(error)")
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
            print("Error when request age from HealthKit")
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
    

    public func saveWorkout(startDate: NSDate, endDate: NSDate, activeEnergySamples: [HKSample], totalKiloCaloriesBurned: Double) {
        
        let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: totalKiloCaloriesBurned)
        
        /*
         NOTE: There is a known bug where activityType property of HKWorkoutSession returns 0, as of iOS 9.1 and watchOS 2.0.1. So, rather than set it using the value from the `HKWorkoutSession`, set it explicitly for the HKWorkout object.
         */
        let workout = HKWorkout(activityType: HKWorkoutActivityType.Cycling, startDate: startDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(startDate), totalEnergyBurned: totalEnergyBurned, totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0.0), metadata: nil)

        let finalActiveEnergySamples = activeEnergySamples

        healthStore.saveObject(workout) { (success, error) in
            if let error = error where !success {
                print("Error saving the workout: \(error.localizedDescription)")
                return
            }
            
            if success && finalActiveEnergySamples.count > 0 {
                self.healthStore.addSamples(finalActiveEnergySamples, toWorkout: workout) { (success, error) in
                    if let error = error where !success {
                        print("Error adding active energy samples to workout: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
}
