//
//  DeviceGroups.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//


import UIKit

class DeviceGroupViewController: UIViewController {
    
 
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var overShadowLabel: UILabel!
    
    var DeviceGroupId: Int = 0
    
    var showInd: Bool = true
    
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var api_error: String = ""

        activityInd.stopAnimating()
        
        if showInd == true {
            startInd()
        }
        
    }
    
    func startInd() {
        overShadowLabel.hidden = false
        activityInd.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopInd() {
        activityInd.stopAnimating()
        overShadowLabel.hidden=true
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LightsButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 1
        Misc().deviceGroupId = 1
        
    }
    
    @IBAction func PlugsButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 2
    }
    
    @IBAction func WindowSensorButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 4
    }
    
    
    @IBAction func MotionSensorButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 3
    }
    
    
    @IBAction func TemperaureSensorButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 5
    }
    
    
    @IBAction func SmokeSensorButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 6
    }
    
    @IBAction func LuminanceSensorButtonPress(sender: AnyObject) {
        
        DeviceGroupId = 7
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if (segue.identifier == "getSettings") {
            
                // at present do nothing...
            
        } else if (segue.identifier == "getLogin") {
            
                // at present do nothing...
            
        } else {
            
            // send the deviceGroupId to the next viewcontroller
            
            let theDestination = (segue.destinationViewController as DeviceListTableViewController)
            theDestination.DeviceGroupId = DeviceGroupId
            
            Misc().deviceGroupId = DeviceGroupId
        }
        
        
    }
    
    
}
