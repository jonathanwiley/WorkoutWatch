//
//  WorkoutTemplateService.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class WorkoutTemplateService {
    
    private static let workoutNameKey = "Name"
    private static let workoutStepsKey = "WorkoutSteps"
    private static let minutesKey = "Minutes"
    private static let maxHeartRatePercentageKey = "Max Heart Rate Percentage"
    private static let minHeartRatePercentageKey = "Min Heart Rate Percentage"
    
    static func fetchWorkoutTemplatesFromDisk() -> [WorkoutTemplate] {
        
        let workoutTemplatePlistPaths = NSBundle.mainBundle().pathsForResourcesOfType("plist", inDirectory: "WorkoutTemplates")
        
        var workoutTemplates = [WorkoutTemplate]()
        
        for workoutTemplatePlistPath in workoutTemplatePlistPaths {
    
            if let workoutTemplateDictionary = NSDictionary(contentsOfFile: workoutTemplatePlistPath) {
                
                var workoutSteps = [WorkoutStep]()
                
                if let workoutStepsFromPlist = workoutTemplateDictionary[workoutStepsKey] as? [NSDictionary] {
                 
                    for workoutStepFromPlist in workoutStepsFromPlist {
                        
                        if let minutes = workoutStepFromPlist[minutesKey] as? Int,
                            maxHeartRatePercentage = workoutStepFromPlist[maxHeartRatePercentageKey] as? Int,
                            minHeartRatePercentage = workoutStepFromPlist[minHeartRatePercentageKey] as? Int {
                            
                            let workoutStep = WorkoutStep(minutes: minutes, maxHeartRatePercentage: maxHeartRatePercentage, minHeartRatePercentage: minHeartRatePercentage)
                            
                            workoutSteps.append(workoutStep)
                        }
                    }
                }
                
                if let name = workoutTemplateDictionary[workoutNameKey] as? String {
                    
                    let workoutTemplate = WorkoutTemplate(name: name, workoutSteps: workoutSteps)
                    
                    workoutTemplates.append(workoutTemplate)
                }
            }
        }
        
        return workoutTemplates
    }
}
