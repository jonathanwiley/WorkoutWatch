//
//  SelectWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class SelectWorkoutViewController: UIViewController {

    var workoutTemplates = [WorkoutTemplate]()
    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        workoutTemplates = WorkoutTemplateService.fetchWorkoutTemplatesFromDisk()
    }
    
    
}
