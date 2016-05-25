//
//  ActiveWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class ActiveWorkoutViewController: UIViewController, HealthKitWorkoutObserverDelegate, WorkoutManagerDelegate {

    @IBOutlet weak var aboveBelowOnTargetLabel: UILabel!
    @IBOutlet weak var currentHeartRateLabel: UILabel!
    @IBOutlet weak var activeCaloriesLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var averageHeartRateLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var startStopWorkoutButton: UIButton!
    
    var workoutTemplate: WorkoutTemplate?
    
    var workoutTimer: NSTimer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        WorkoutManager.sharedInstance.delegate = self
    }

    @IBAction func startEndWorkoutButtonPressed(sender: UIButton) {
        if (!WorkoutManager.sharedInstance.isWorkoutInProgress) {
            WatchConnectivityManager.sharedInstance.sendStartWorkoutMessage(workoutTemplate!, replyHandler: { (replyDictionary) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.startWorkout()
                }
            }) { error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.showOpenWatchAppToStartDialog()
                }
            }
        }
    }
    
    func startWorkout() {
        
        WorkoutManager.sharedInstance.startWorkout(workoutTemplate!)
    }
    
    func showOpenWatchAppToStartDialog() {
        
        let openWatchAlertController = UIAlertController(title: "Open Watch App", message: "Open the watch app and then try to start the workout again.", preferredStyle: UIAlertControllerStyle.Alert)
        let uiAlertCancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
        openWatchAlertController.addAction(uiAlertCancelAction)
        
        self.presentViewController(openWatchAlertController, animated: true, completion: nil)
    }
    
    func updateTimeRemaining() {
        let secondsRemaining = (WorkoutManager.sharedInstance.workoutEndDate?.timeIntervalSinceNow)!
        if (secondsRemaining > 0) {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(Int(secondsRemaining))
            timeRemainingLabel.text = "\(hours):\(minutes):\(seconds)"
        } else {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(0)
            timeRemainingLabel.text = "\(hours):\(minutes):\(seconds)"
        }
        
    }
    
    func updateTimeElapsed() {
        let secondsElapsed = -(WorkoutManager.sharedInstance.workoutStartDate?.timeIntervalSinceNow)!
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
    
    func workoutDidStart() {
        workoutTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ActiveWorkoutViewController.updateTimeLabels), userInfo: nil, repeats: true)
        startStopWorkoutButton.setTitle("End Workout", forState: UIControlState.Normal)
    }
    
    func workoutDidEnd() {
        
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentHeartRateLabel.text = String(currentHeartRate) + "bpm"
        }
    }
    
    func newHeartRateReadingIsAboveTarget() {
        
    }
    
    func newHeartRateReadingIsOnTarget() {
        
    }
    
    func newHeartRateReadingIsBelowTarget() {
        
    }
}
