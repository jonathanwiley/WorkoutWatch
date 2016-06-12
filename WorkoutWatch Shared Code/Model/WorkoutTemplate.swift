//
//  WorkoutTemplate.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

public class WorkoutTemplate: NSObject {
    
    public let name: String
    public let workoutSteps: [WorkoutStep]
    public let fileName: String
    
    
    init(name: String, workoutSteps: [WorkoutStep], fileName: String) {
        
        self.name = name
        self.workoutSteps = workoutSteps
        self.fileName = fileName
    }
    
    func durationInMinutes() -> Int {
        
        var durationAccumulator = 0
        
        for workoutStep in workoutSteps {
            
            durationAccumulator += workoutStep.minutes
        }
        
        return durationAccumulator
    }
}
