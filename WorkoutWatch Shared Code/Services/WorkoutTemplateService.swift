//
//  WorkoutTemplateService.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

public class WorkoutTemplateService {
    
    private static let workoutNameKey = "Name"
    private static let workoutStepsKey = "WorkoutSteps"
    private static let minutesKey = "Minutes"
    private static let maxHeartRatePercentageKey = "Max Heart Rate Percentage"
    private static let minHeartRatePercentageKey = "Min Heart Rate Percentage"
    
    public static func fetchWorkoutTemplatesFromDisk() -> [WorkoutTemplate] {
        
        let workoutTemplatePlistPaths = NSBundle.init(forClass: self).pathsForResourcesOfType("plist", inDirectory: "WorkoutTemplates")
        
        var workoutTemplates = [WorkoutTemplate]()
        
        for workoutTemplatePlistPath in workoutTemplatePlistPaths {
    
            if let workoutTemplate = fetchWorkoutTemplateWithFilePath(workoutTemplatePlistPath) {
                
                workoutTemplates.append(workoutTemplate)
            }
        }
        
        return workoutTemplates
    }
    
    public static func fetchWorkoutTemplateWithFileName(filename: String) -> WorkoutTemplate? {
        
        guard let workoutTemplatePlistPath = NSBundle.init(forClass: self).pathForResource(filename, ofType: "plist", inDirectory: "WorkoutTemplates") else {return nil}
        
        return fetchWorkoutTemplateWithFilePath(workoutTemplatePlistPath)
    }
    
    public static func fetchWorkoutTemplateWithFilePath(workoutTemplatePlistPath: String) -> WorkoutTemplate? {
        
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
                
                let fileNameWithExtension = (workoutTemplatePlistPath as NSString).lastPathComponent
                let fileName = (fileNameWithExtension as NSString).stringByDeletingPathExtension
                
                let workoutTemplate = WorkoutTemplate(name: name, workoutSteps: workoutSteps, fileName: fileName)
                
                return workoutTemplate
            }
        }
        
        return nil
    }
}
