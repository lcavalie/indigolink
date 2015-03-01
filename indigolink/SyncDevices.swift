//
//  SyncDevices.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc class syncDevices: NSObject {

    func parseDeviceXMLData(data: NSData) -> ([String]) {
        var xmlDoc = AEXMLDocument()
        
        var deviceArray = [String]()
        
        var xmlerror: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &xmlerror) {
            
            if xmlDoc.rootElement.name == "devices" {
                // this is an XML from indigo with device information...
                
                deviceArray = storeDeviceData(data)
                
            } else if (xmlDoc.rootElement.name == "graphdata") {

                getGraphJSONdata(data)
                
            } else {
                // this is custom XML for change of device info, uses the same function
                deviceArray = storeDeviceData(data)
            }
            
           
        } else {
            
            var datastring: String = NSString(data:data, encoding:NSUTF8StringEncoding)!
            println("XML Data:")
            println(datastring)
            println("XML ERROR!")
        }
    
        return(deviceArray)
    }

    func storeDeviceData(data: NSData) -> ([String]) {
        var xmlDoc = AEXMLDocument()
        
        var deviceArray = [String]()
        
        var xmlerror: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &xmlerror) {
            
            for zDev in xmlDoc.rootElement["device"].all {
                
                var existingItem: NSManagedObject!
                
                var error: NSError?
                
                var serverSettings:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                var managedContext: NSManagedObjectContext = serverSettings.managedObjectContext!
                
                let dev_id = zDev["id"].value as String
                
                deviceArray.append(dev_id)
                
                var myrequest = NSFetchRequest(entityName: "IndigoDevices")
                let deviceFilter = NSPredicate (format: "id = '\(dev_id)'")!
                myrequest.predicate = deviceFilter
                
                var myResults:NSArray = managedContext.executeFetchRequest(myrequest, error: nil)!
                
                if (myResults.count > 0) {
                    
                    for results in myResults {
                        
                        existingItem = results as NSManagedObject
                        
                    }
                    
                }
                
                
                var DeviceSettings:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                var managedContext2: NSManagedObjectContext = DeviceSettings.managedObjectContext!
                var entity = NSEntityDescription.entityForName("IndigoDevices", inManagedObjectContext: managedContext2)
                
                if (existingItem != nil) {
                    
                    existingItem.setValue(zDev["name"].value, forKey: "name")
                    existingItem.setValue(zDev["id"].value, forKey: "id")
                    existingItem.setValue(zDev["isOn"].value, forKey: "isOn")
                    existingItem.setValue(zDev["lastChangedRFC822"].value, forKey: "lastChangedRFC822")
                    existingItem.setValue(zDev["typeSupportsOnOff"].value, forKey: "typeSupportsOnOff")
                    existingItem.setValue(zDev["type"].value, forKey: "type")
                    existingItem.setValue(zDev["sensorValue"].value, forKey: "sensorValue")
                    existingItem.setValue(zDev["meterValue"].value, forKey: "meterValue")
                    
                } else {
                    
                    var entityentry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext2)
                    
                    entityentry.setValue(zDev["name"].value, forKey: "name")
                    entityentry.setValue(zDev["id"].value, forKey: "id")
                    entityentry.setValue(zDev["isOn"].value, forKey: "isOn")
                    entityentry.setValue(zDev["lastChangedRFC822"].value, forKey: "lastChangedRFC822")
                    entityentry.setValue(zDev["typeSupportsOnOff"].value, forKey: "typeSupportsOnOff")
                    entityentry.setValue(zDev["type"].value, forKey: "type")
                    entityentry.setValue(zDev["sensorValue"].value, forKey: "sensorValue")
                    entityentry.setValue(zDev["meterValue"].value, forKey: "meterValue")
                    
                }
                
                managedContext.save(nil)
                
            }
            
            
        } else {
            println("XML Error: \(xmlerror?.localizedDescription)\ninfo: \(xmlerror?.userInfo)")
        }
        
        return(deviceArray)
    }
    
    
    func getGraphJSONdata(data: NSData) {
        
        var xmlDoc = AEXMLDocument()
        
        var deviceArray = [String]()
        
        var xmlerror: NSError?
        
        var datastring: String = NSString(data:data, encoding:NSUTF8StringEncoding)!
        
        if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &xmlerror) {
            
            for zDev in xmlDoc.rootElement.all {
                
                let graphJSONdata = zDev["jsondata"].value as String
                
                let data = (graphJSONdata as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                
                var error: NSError?
                
                var json : AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error)
                
                if let err = error {
                    // do nothing for now
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("graphNotification", object: self, userInfo: ["message":graphJSONdata])

            }
            
        }
        

    }
    
    
}