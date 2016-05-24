//
//  WorkoutStep.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

public class WorkoutStep {
    let minutes: Int
    let maxHeartRatePercentage: Int
    let minHeartRatePercentage: Int
    
    init(minutes: Int, maxHeartRatePercentage: Int, minHeartRatePercentage: Int) {
        self.minutes = minutes
        self.maxHeartRatePercentage = maxHeartRatePercentage
        self.minHeartRatePercentage = minHeartRatePercentage
    }
}
