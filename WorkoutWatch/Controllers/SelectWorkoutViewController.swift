//
//  SelectWorkoutViewController.swift
//  WorkoutWatch
//
//  Created by Jonathan Wiley on 5/17/16.
//  Copyright © 2016 Jonathan Wiley. All rights reserved.
//

import UIKit

class SelectWorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var workoutTemplates = [WorkoutTemplate]()
    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        workoutTemplates = WorkoutTemplateService.fetchWorkoutTemplatesFromDisk()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return workoutTemplates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let workoutTemplateCell = tableView.dequeueReusableCellWithIdentifier("WorkoutTemplateTableViewCell", forIndexPath: indexPath) as! WorkoutTemplateTableViewCell
        
        workoutTemplateCell.nameLabel.text = workoutTemplates[indexPath.row].name
        
        return workoutTemplateCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "StartActiveWorkoutSegue" {
            
            let activeWorkoutViewController = segue.destinationViewController as! ActiveWorkoutViewController
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
             
                activeWorkoutViewController.workoutTemplate = workoutTemplates[selectedIndexPath.row]
            }
        }
    }
}
