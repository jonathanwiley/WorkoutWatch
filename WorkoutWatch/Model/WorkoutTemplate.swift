//
//  WorkoutTemplate.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class WorkoutTemplate: NSObject {
    
    let name : String
    let workoutSteps: [WorkoutStep]
    
    init(name: String, workoutSteps: [WorkoutStep]) {
        self.name = name
        self.workoutSteps = workoutSteps
    }
}
