//
//  Misc.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import Foundation


class Misc {
    var deviceGroupId: Int = 0
    
    func splitDevDescr (device_name_input: String) -> (device_room: String, device_name: String) {
        // the device name as entered in indigo is split here based on the "-" within
        
        var device_room: String = ""
        var device_name: String = ""
        
        let characterToFind: Character = "-"
        
        let names = device_name_input.componentsSeparatedByString(" - ") as NSArray
        
        if names.count > 0 {
            device_room = names[0] as String
            
            for var index = 1; index < names.count; ++index {
                
                if (index > 1) {
                    device_name += " - "
                }
                device_name += names[index] as String
                
            }
            
        } else {
            device_name = device_name_input
        }

        return (device_room, device_name)
    }
    

    func splitSensorValue (sensorValue_input: String) -> (String) {
        // play a bit with the temperature to remove the degree - could use the RawState in a next version
        
        var sensorValue: String = ""
        
        let names = sensorValue_input.componentsSeparatedByString(" ") as NSArray
        
        if names.count > 0 {
            sensorValue = names[0] as String
            
            var float_sensor_Value: Float = (sensorValue as NSString).floatValue
            
            sensorValue = String(format: "%.1f", float_sensor_Value)
            
        } else {
            sensorValue = sensorValue_input
        }
        
        return (sensorValue)
    }
    
}