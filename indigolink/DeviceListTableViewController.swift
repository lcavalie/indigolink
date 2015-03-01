//
//  DeviceListTableViewController.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import UIKit
import CoreData

class DeviceListTableViewController: UITableViewController {
    
    var DevicesList: Array<AnyObject>=[]
    var DeviceGroupId: Int = 0
    var ii: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
  
    @IBAction func pressBack(sender: AnyObject) {
        
        // do nothing for now
        
    }

    
    override func viewDidAppear(animated: Bool) {
        
        deviceUpdateAll()
        
    }
    
 
    func deviceUpdate (deviceid: String) {
        
        // update a single device only

        var rownum: Int = 0
        
        for item in DevicesList {
        
            var mydevid : String = item.valueForKeyPath("id") as String
            
            if mydevid == deviceid {
                
                var rowToReload: NSIndexPath = NSIndexPath(forRow: rownum, inSection: 0)
                var rowsToRelad: NSArray = NSArray(objects: rowToReload)
                self.tableView.reloadRowsAtIndexPaths(rowsToRelad, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            rownum++
            
        }
        
    }

    func deviceUpdateAll () {
        
        // update all devices, first filter the devices to load and the load the table
        
        var serverSettings:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        var managedContext: NSManagedObjectContext = serverSettings.managedObjectContext!
        var request = NSFetchRequest(entityName: "IndigoDevices")
        
        switch DeviceGroupId {
        case 1:
            // light switches have on/off
            let deviceFilter = NSPredicate (format: "type contains[c] %@ OR name contains[c] %@", "Relay Power Switch", "Relay Power Switch")!
            request.predicate = deviceFilter
        case 2:
            // plugs with on/off and possibly energy meter?
            let deviceFilter = NSPredicate (format: "type contains[c] %@ OR name contains[c] %@", "Appliance Module", "Appliance Module")!
            request.predicate = deviceFilter
        case 3:
            // motion sensors - on/off means breached/safe
            let deviceFilter = NSPredicate (format: "(type contains[c] %@ OR name contains[c] %@) AND NOT (name contains [c] %@ OR name contains [c] %@)", "Motion", "Motion", "Temperature", "Luminance")!
            request.predicate = deviceFilter
        case 4:
            // door/window sensors - on/off means breached/safe
            let deviceFilter = NSPredicate (format: "(name contains[c] %@ OR name contains[c] %@ OR type contains [c] %@) AND NOT (name contains [c] %@ OR name contains [c] %@ OR name contains [c] %@)", "Window Sensor", "Door Sensor", "Window Sensor", "Temperature", "Luminance", "Motion")!
            request.predicate = deviceFilter
        case 5:
            // temperature sensors - display temperature
            let deviceFilter = NSPredicate (format: "name contains[c] %@", "Temperature")!
            request.predicate = deviceFilter
        case 6:
            // smoke sensors on fire or not?
            let deviceFilter = NSPredicate (format: "(type contains[c] %@ OR type contains[c] %@) AND NOT name contains[c] %@", "Smoke", "Carbon", "Temperature")!
            request.predicate = deviceFilter
        case 7:
            // temperature sensors - display luminance
            let deviceFilter = NSPredicate (format: "name contains[c] %@", "Luminance")!
            request.predicate = deviceFilter
        default:
            //println("DeviceGroupId: default?")
            let deviceFilter = ""
        }
        
        DevicesList = managedContext.executeFetchRequest(request, error: nil)!

        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DevicesList.count
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        // add row slide options, first one common to all....
        
        var showOptions: [AnyObject] = []

        var showReload = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reload" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            var data: NSManagedObject = self.DevicesList[indexPath.row] as NSManagedObject
            var device_id: String = data.valueForKeyPath("id") as String
            
            var myObjClass:ViewController = ViewController()
            myObjClass.sendMessage("reload:", message: device_id)
            
        })
        
        showReload.backgroundColor = UIColor.grayColor()
        
        // show the graph option only to devices with electricity meter or temperature sensors or luminance

        if (self.DeviceGroupId == 2 || self.DeviceGroupId == 5 || self.DeviceGroupId == 7) {
            
            var data: NSManagedObject = self.DevicesList[indexPath.row] as NSManagedObject
            var device_id: String = data.valueForKeyPath("id") as String
            var device_type: String = data.valueForKeyPath("type") as String
            
            var showGraph = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Show Graph" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
                var VC1 = self.storyboard?.instantiateViewControllerWithIdentifier("vcGraph") as ShowGraphViewController
                VC1.mydeviceID = device_id
                
                self.navigationController?.pushViewController(VC1, animated: true)
                
            })
            
            // even from the appliance modules only some have a meter, the TZ88E is one, there could be others
            
            if (device_type.rangeOfString("TZ88E") != nil && self.DeviceGroupId == 2) {
                
                showOptions.append(showGraph)
            } else if (self.DeviceGroupId == 5 || self.DeviceGroupId == 7) {
                showOptions.append(showGraph)
            }
            
           showGraph.backgroundColor = UIColor.greenColor()
            
        }
        
        showOptions.append(showReload)
        
        return showOptions
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellID : NSString = "DeviceCustomCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier("DeviceCustomCell") as DeviceCustomCell
        
        if DevicesList.count > 0 {
            var data: NSManagedObject = DevicesList[indexPath.row] as NSManagedObject
            
            var devicename : String = data.valueForKeyPath("name") as String
            var lastchanged: String = data.valueForKeyPath("lastChangedRFC822") as String
            var device_isOn: String = data.valueForKeyPath("isOn") as String
            var device_id: String = data.valueForKeyPath("id") as String
            var meterValue: String = data.valueForKeyPath("meterValue") as String
            
            cell.myLabel4.text = devicename
            let mydevdetails = Misc().splitDevDescr(devicename)
            cell.myLabel1.text = mydevdetails.device_name
            cell.myLabel2.text = "Room: \(mydevdetails.device_room)"
            cell.myLabel3.text = "Last Changed: \(lastchanged)"
            cell.myLabel6.text = device_id
            
            var deviceOnOff: String = ""
            var statusColor = UIColor.blackColor()
            
            if (device_isOn == "True" ) {
                deviceOnOff = "On"
            } else {
                deviceOnOff = "Off"
            }
            
            switch DeviceGroupId {
            case 1:
                // light switches have on/off
            
                if (device_isOn == "True" ) {
                    deviceOnOff = "On"
                } else {
                    deviceOnOff = "Off"
                }
                
                cell.myButton.setTitle(deviceOnOff, forState: UIControlState.Normal)
                cell.myButton.hidden = false
                cell.myLabel5.hidden = true
                
            case 2:
                // plugs with on/off and possibly energy meter?
                
                if (device_isOn == "True" ) {
                    
                    if (meterValue != "ERROR") {
                        deviceOnOff = meterValue + "W"
                    } else {
                        deviceOnOff = "On"
                    }
                    
                } else {
                    deviceOnOff = "Off"
                }
                
                cell.myButton.setTitle(deviceOnOff, forState: UIControlState.Normal)
                cell.myButton.hidden = false
                cell.myLabel5.hidden = true
                
            case 3:
                // motion sensors - on/off means breached/safe
                
                if (device_isOn == "True" ) {
                    deviceOnOff = "Breached!"
                    statusColor = UIColor.redColor()
                } else {
                    deviceOnOff = "Safe"
                    statusColor = UIColor.blackColor()
                }
                
                cell.myLabel5.text = deviceOnOff
                cell.myLabel5.textColor = statusColor
                cell.myButton.hidden = true
                cell.myLabel5.hidden = false
                
            case 4:
                // door/window sensors - on/off means breached/safe
                
                if (device_isOn == "True" ) {
                    deviceOnOff = "Breached!"
                    statusColor = UIColor.redColor()
                } else {
                    deviceOnOff = "Safe"
                    statusColor = UIColor.blackColor()
                }
                
                cell.myLabel5.text = deviceOnOff
                cell.myLabel5.textColor = statusColor
                cell.myButton.hidden = true
                cell.myLabel5.hidden = false
                
            case 5:
                // temperature sensors - display temperature
                
                var display_temperature =  Misc().splitSensorValue(data.valueForKeyPath("sensorValue") as String!)
                var display_degree = "\u{00B0}"
                cell.myLabel5.text = "\(display_temperature)\(display_degree)C"
                cell.myButton.hidden = true
                cell.myLabel5.hidden = false
                
            case 6:
                // smoke sensors on fire or not?
                
                if (device_isOn == "True" ) {
                    deviceOnOff = "Fire!"
                    statusColor = UIColor.redColor()
                } else {
                    deviceOnOff = "Safe"
                    statusColor = UIColor.blackColor()
                }
                
                cell.myLabel5.text = deviceOnOff
                cell.myLabel5.textColor = statusColor
                cell.myButton.hidden = true
                cell.myLabel5.hidden = false
                
            case 7:
                // luminance sensors - display lux reading
                
                cell.myLabel5.text = data.valueForKeyPath("sensorValue") as String!
                cell.myButton.hidden = true
                cell.myLabel5.hidden = false
                
            default:
                // error no device group?
                cell.myLabel5.text = ""
                cell.myButton.hidden = false
                cell.myLabel5.hidden = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
            
            
        } else {
            
            // strange, nothing loaded...?
        }
        
        return cell
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "getDeviceGroups") {
        
            let theDestination = (segue.destinationViewController as DeviceGroupViewController)
            theDestination.showInd = false
    
        } else if (segue.identifier == "getGraph") {
        
            //do nothing for now
        
        }
        
    }
    
}
