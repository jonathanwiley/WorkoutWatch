//
//  ActiveWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class ActiveWorkoutViewController: UIViewController, HealthKitWorkoutObserverDelegate {

    @IBOutlet weak var aboveBelowOnTargetLabel: UILabel!
    @IBOutlet weak var currentHeartRateLabel: UILabel!
    @IBOutlet weak var activeCaloriesLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var averageHeartRateLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var startStopWorkoutButton: UIButton!
    
    var workoutTemplate: WorkoutTemplate?
    var healthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    var isWorkoutStarted = false
    
    var workoutStartDate: NSDate?
    var workoutEndDate : NSDate?
    var workoutTimer: NSTimer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func startEndWorkoutButtonPressed(sender: UIButton) {
        if (!isWorkoutStarted) {
            WatchConnectivityManager.sharedInstance.sendStartWorkoutMessage(workoutTemplate!, replyHandler: { (replyDictionary) in
                if let workoutEndDateFromReply = replyDictionary[WatchConnectivityManager.workoutEndDateKey] as! NSDate? {
                    self.workoutEndDate = workoutEndDateFromReply
                    self.workoutStartDate = self.workoutEndDate?.dateByAddingTimeInterval(Double((self.workoutTemplate?.durationInMinutes())!*(-60)))
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.startWorkout()
                }
            }) { error in
                self.showOpenWatchAppToStartDialog()
            }
        }
        else {
            
        }
    }
    
    func startWorkout() {
        isWorkoutStarted = true
        workoutTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ActiveWorkoutViewController.updateTimeLabels), userInfo: nil, repeats: true)
        startStopWorkoutButton.setTitle("End Workout", forState: UIControlState.Normal)
        healthKitWorkoutObserver = HealthKitWorkoutObserver(delegate: self)
    }
    
    func showOpenWatchAppToStartDialog() {
        
    }
    
    func updateTimeRemaining() {
        let secondsRemaining = (self.workoutEndDate?.timeIntervalSinceNow)!
        if (secondsRemaining > 0) {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(Int(secondsRemaining))
            timeRemainingLabel.text = "\(hours):\(minutes):\(seconds)"
        } else {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(0)
            timeRemainingLabel.text = "\(hours):\(minutes):\(seconds)"
        }
        
    }
    
    func updateTimeElapsed() {
        let secondsElapsed = -(self.workoutStartDate?.timeIntervalSinceNow)!
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(Int(secondsElapsed))
        timeElapsedLabel.text = "\(hours):\(minutes):\(seconds)"
    }
    
    func timeIntervalUntilEndOfWorkout() {
        
    }
    
    func updateTimeLabels() {
        updateTimeRemaining()
        updateTimeElapsed()
        WatchConnectivityManager.sharedInstance.sendRequestUpdatedHeartRateMessage()
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (String, String, String) {
        return (String(format: "%02d", seconds / 3600),
                String(format: "%02d", (seconds % 3600) / 60),
                String(format: "%02d", (seconds % 3600) % 60))
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.currentHeartRateLabel.text = String(currentHeartRate) + "bpm"
        }
    }
}
