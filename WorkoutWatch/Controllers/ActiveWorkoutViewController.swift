//
//  ActiveWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class ActiveWorkoutViewController: UIViewController {

    @IBOutlet weak var aboveBelowOnTargetLabel: UILabel!
    @IBOutlet weak var currentHeartRateLabel: UILabel!
    @IBOutlet weak var activeCaloriesLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var averageHeartRateLabel: UILabel!
    
    var workoutTemplate: WorkoutTemplate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func startEndWorkoutButtonPressed(sender: UIButton) {
//        startWorkout()
        // TODO: ask the watch to start a workout
    }
}
