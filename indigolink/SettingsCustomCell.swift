//
//  DeviceCustomCell.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import UIKit

class SettingsCustomCell: UITableViewCell {
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Btn1: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func toggleAlarm(sender: AnyObject) {
 
        //send via sockets message to change on/off status
        
        let alarmStatus: String = Label2.text!
        
        var newStatus: String = "?"
        
        if alarmStatus == "On" {
 
            newStatus = "Off"
            
        } else {
            
            newStatus = "On"
        }
        
        var myObjClass:ViewController = ViewController()
        myObjClass.sendMessage("alarm:", message: newStatus)
    }
    

    
    
}

