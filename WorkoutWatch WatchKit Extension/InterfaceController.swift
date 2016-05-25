//
//  InterfaceController.swift
//  WorkoutWatch WatchKit Extension
//
//  Created by Jonathan Wiley on 4/23/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    
    @IBOutlet var uiInterfaceGroup: WKInterfaceGroup!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var timeRemainingTimer: WKInterfaceTimer!
    @IBOutlet var startStopButton: WKInterfaceButton!
    
    var healthKitWorkoutObserver: HealthKitWorkoutObserver?
    
    var workoutTemplate: WorkoutTemplate?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        WorkoutManager.sharedInstance.delegate = self
    }

    override func willActivate() {
        super.willActivate()
        
        if (WorkoutManager.sharedInstance.isWorkoutInProgress) {
            workoutDidStart()
        }
    }

    @IBAction func startStopButtonPressed() {
        
        if (WorkoutManager.sharedInstance.isWorkoutInProgress) {
            WorkoutManager.sharedInstance.stopWorkout()
        } else {
            WorkoutManager.sharedInstance.startWorkout(workoutTemplate!)
        }
    }
    
    func workoutDidStart() {
        dispatch_async(dispatch_get_main_queue()) {
            self.timeRemainingTimer.setDate(WorkoutManager.sharedInstance.workoutEndDate!)
            self.timeRemainingTimer.start()
            
            self.startStopButton.setTitle("Stop Workout")
        }
    }
    
    func workoutDidEnd() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.uiInterfaceGroup.setBackgroundColor(UIColor.clearColor())
            
            self.heartRateLabel.setText("---")
            
            self.timeRemainingTimer.stop()
            
            self.startStopButton.setTitle("Start Workout")
        }
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        self.heartRateLabel.setText(String(UInt16(currentHeartRate)) + " BPM")
    }
    
    func newHeartRateReadingIsAboveTarget() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Failure)
        
        self.uiInterfaceGroup.setBackgroundColor(UIColor.redColor())
    }
    
    func newHeartRateReadingIsOnTarget() {
        self.uiInterfaceGroup.setBackgroundColor(UIColor.clearColor())
    }
    
    func newHeartRateReadingIsBelowTarget() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
        
        self.uiInterfaceGroup.setBackgroundColor(UIColor.greenColor())
    }
}
