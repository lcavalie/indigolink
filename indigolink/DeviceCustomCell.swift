//
//  DeviceCustomCell.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import UIKit
import CoreData

@objc class DeviceCustomCell: UITableViewCell {
    
    @IBOutlet var myLabel1: UILabel!
    @IBOutlet var myLabel2: UILabel!
    @IBOutlet var myLabel3: UILabel!
    @IBOutlet var myLabel4: UILabel!
    @IBOutlet var myLabel5: UILabel!
    @IBOutlet weak var myLabel6: UILabel!
    
    @IBOutlet var myButton: UIButton!
    @IBOutlet weak var btnGraph: UIButton!
    
    
    var existingItem: NSManagedObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func pressOnOffButton(sender: AnyObject) {
        
        //send via sockets message to toggle device...
        
        let device_id: String = myLabel6.text!
        
        myButton.setTitle("Wait", forState: UIControlState.Normal)
        
        var myObjClass:ViewController = ViewController()
        myObjClass.sendMessage("toggle:", message: device_id)
        
    }
    

}

