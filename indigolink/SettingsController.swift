//
//  SettingsController.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import UIKit
import CoreData

class SettingsController: UITableViewController {
    
    let settingItems = ["Alarm arming"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func pressBack(sender: AnyObject) {
        // do notihng for now
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingItems.count
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SettingsCustomCell") as SettingsCustomCell
        
        var alarmStatus : String = "Off"

        
        if (indexPath.row == 0) {
            var serverSettings:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            var managedContext: NSManagedObjectContext = serverSettings.managedObjectContext!
            var request = NSFetchRequest(entityName: "IndigoDevices")
            
            let deviceFilter = NSPredicate (format: "id = '0'")!
            request.predicate = deviceFilter
            var DevicesList: Array<AnyObject>=[]
            DevicesList = managedContext.executeFetchRequest(request, error: nil)!

            if DevicesList.count > 0 {
            
                var data: NSManagedObject = DevicesList[indexPath.row] as NSManagedObject
                
                alarmStatus = data.valueForKeyPath("isOn") as String
            
            }
            
            cell.Btn1.setTitle(alarmStatus, forState: UIControlState.Normal)
            cell.Label2.text = alarmStatus
            cell.Btn1.hidden = false
            
        } else {
            
            cell.Btn1.hidden = true
        
        }
        
        cell.Label1.text = settingItems[indexPath.row]
        
        return cell
        
    }
    
    
    func alarmUpdate () {
        
        var rowToReload: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        var rowsToRelad: NSArray = NSArray(objects: rowToReload)
        self.tableView.reloadRowsAtIndexPaths(rowsToRelad, withRowAnimation: UITableViewRowAnimation.Fade)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "getDeviceGroups") {
            
            let theDestination = (segue.destinationViewController as DeviceGroupViewController)
            theDestination.showInd = false

        }
        
    }
    
}

