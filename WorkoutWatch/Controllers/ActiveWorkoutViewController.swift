//
//  ActiveWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class ActiveWorkoutViewController: UIViewController, HealthKitWorkoutObserverDelegate, WorkoutManagerDelegate {

    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var currentTargetHeartRateRangeLabel: UILabel!
    @IBOutlet weak var currentHeartRateLabel: UILabel!
    @IBOutlet weak var aboveBelowOnTargetLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var startWorkoutButton: UIButton!
    
    var workoutTemplate: WorkoutTemplate?
    
    var workoutTimer: NSTimer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        WorkoutManager.sharedInstance.delegate = self
        
        self.workoutNameLabel.text = workoutTemplate?.name
        self.currentHeartRateLabel.text = ""
        self.currentHeartRateLabel.text = ""
        self.aboveBelowOnTargetLabel.text = ""
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds((workoutTemplate?.durationInMinutes())!*60)
        self.timeRemainingLabel.text = "\(hours):\(minutes):\(seconds)"
    }

    @IBAction func startWorkoutButtonPressed(sender: UIButton) {
        
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
    
    func updateTimeLabels() {
        updateTimeRemaining()
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (String, String, String) {
        return (String(format: "%02d", seconds / 3600),
                String(format: "%02d", (seconds % 3600) / 60),
                String(format: "%02d", (seconds % 3600) % 60))
    }
    
    func workoutDidStart() {
        dispatch_async(dispatch_get_main_queue()) {
            self.workoutTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ActiveWorkoutViewController.updateTimeLabels), userInfo: nil, repeats: true)
            self.startWorkoutButton.hidden = true
        }
    }
    
    func workoutDidEnd() {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentHeartRateLabel.text = String(Int(currentHeartRate)) + " BPM"
        }
    }
    
    func newHeartRateReadingIsAboveTarget() {
        dispatch_async(dispatch_get_main_queue()) {
            self.aboveBelowOnTargetLabel.text = "Above Target Heart Rate"
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    func newHeartRateReadingIsOnTarget() {
        dispatch_async(dispatch_get_main_queue()) {
            self.aboveBelowOnTargetLabel.text = "On Target Heart Rate"
            self.view.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func newHeartRateReadingIsBelowTarget() {
        dispatch_async(dispatch_get_main_queue()) {
            self.aboveBelowOnTargetLabel.text = "Below Target Heart Rate"
            self.view.backgroundColor = UIColor.greenColor()
        }
    }
    
    func currentHeartRateTargetWasUpdated(minHeartRate: Int, maxHeartRate: Int) {
        self.currentTargetHeartRateRangeLabel.text = "Current Target: \(minHeartRate) - \(maxHeartRate)"
    }
}
