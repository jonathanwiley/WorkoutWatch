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
    
    @IBOutlet var containerInterfaceGroup: WKInterfaceGroup!
    @IBOutlet var startAWorkoutGroup: WKInterfaceGroup!
    @IBOutlet var workoutInterfaceGroup: WKInterfaceGroup!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var timeRemainingTimer: WKInterfaceTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        WatchWorkoutManager.sharedWatchInstance.delegate = self
    }

    override func willActivate() {
        super.willActivate()
        
        if (WatchWorkoutManager.sharedWatchInstance.isWorkoutInProgress) {
            workoutDidStart()
        }
    }

    @IBAction func stopButtonPressed() {
        
        if (WatchWorkoutManager.sharedWatchInstance.isWorkoutInProgress) {
            WatchWorkoutManager.sharedWatchInstance.stopWorkout()
            
            WatchConnectivityManager.sharedInstance.sendEndWorkoutMessage(nil, errorHandler: nil)
        }
    }
    
    func workoutDidStart() {
        dispatch_async(dispatch_get_main_queue()) {
            self.timeRemainingTimer.setDate(WatchWorkoutManager.sharedWatchInstance.workoutEndDate!)
            self.timeRemainingTimer.start()
            
            self.startAWorkoutGroup.setHidden(true)
            self.workoutInterfaceGroup.setHidden(false)
        }
    }
    
    func workoutDidEnd() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.containerInterfaceGroup.setBackgroundColor(UIColor.clearColor())
            
            self.workoutInterfaceGroup.setHidden(true)
            self.startAWorkoutGroup.setHidden(false)
            
            self.heartRateLabel.setText("---")
            
            self.timeRemainingTimer.stop()
        }
    }
    
    func heartRateWasUpdated(currentHeartRate: Double) {
        self.heartRateLabel.setText(String(UInt16(currentHeartRate)) + " BPM")
    }
    
    func newHeartRateReadingIsAboveTarget() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Failure)
        
        self.containerInterfaceGroup.setBackgroundColor(UIColor.redColor())
    }
    
    func newHeartRateReadingIsOnTarget() {
        self.containerInterfaceGroup.setBackgroundColor(UIColor.clearColor())
    }
    
    func newHeartRateReadingIsBelowTarget() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
        
        self.containerInterfaceGroup.setBackgroundColor(UIColor.greenColor())
    }
    
    func currentHeartRateTargetWasUpdated(minHeartRate: Int, maxHeartRate: Int) {
        // no-op
    }
}
