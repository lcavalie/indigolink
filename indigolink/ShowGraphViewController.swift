//
//  ShowGraphViewController.swift
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

import UIKit
import Foundation

class ShowGraphViewController: UIViewController {
    @IBOutlet weak var test3: UILabel!
   
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var overShadowLabel: UILabel!
    
    var mydeviceID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "processGraphNotification:", name: "graphNotification", object: nil)
        
        if mydeviceID != "" {
            
            getGraphData(mydeviceID)
            test3.text = "Receiving & processing data..."
            
            startInd()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
   
    func startInd() {
        overShadowLabel.hidden = false
        activityInd.startAnimating()
    }
    
    func stopInd() {
        overShadowLabel.hidden=true
        activityInd.stopAnimating()
    }
    
    func getGraphData(mydeviceID: String) {
        
        var myObjClass:ViewController = ViewController()
        myObjClass.sendMessage("graph:", message: mydeviceID)
        
    }

    func processGraphNotification(notification:NSNotification) {
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as Dictionary<String,String!>
        let messageString: NSString = userInfo["message"]!
        
        let data = messageString.dataUsingEncoding(NSUTF8StringEncoding)
        
        showGraph(data!)
        
    }
    
    func showGraph(devicedataJSON: NSData) {
        
        var dev_x = [String]()
        var dev_y = [Float]()
        
        let json = JSON(data: devicedataJSON as NSData)
        
        if let devArray = json.arrayValue {
            
            for device in devArray {
                
                dev_x.append(device["ts"].stringValue!)
                
                var myValue: NSString = device["sensorvalue"].stringValue!
                dev_y.append(myValue.floatValue)
                
            }
            
        }
        
        if dev_y.count == 0 {
            
            test3.text = "No data for this device!"
            stopInd()
            return
        }
        

        let chart = TKChart(frame: CGRectInset(self.view.bounds, 5, 75))
        chart.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        self.view.addSubview(chart)
        
        var dataPoints = [TKChartDataPoint]()
        
        for var i = 0; i < dev_x.count; ++i {
            
            
            let newdt = dev_x[i].stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            let date = dateFormatter.dateFromString(newdt)!
            
            dataPoints.append(TKChartDataPoint(x: date, y: dev_y[i]))
            
            test3.text = "Receiving & processing data... \(i+1) data point(s) so far..."
        }
        
        let lineSeries = TKChartLineSeries(items: dataPoints)
        chart.addSeries(lineSeries)
        
        let adate = NSDate()
        let adateFormatter = NSDateFormatter()
        adateFormatter.dateFormat = "yyyy-MM-dd"
        var adateString: String = adateFormatter.stringFromDate(adate)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm"
        let date1 = dateFormatter.dateFromString(adateString + " 00:00")!
        let date2 = dateFormatter.dateFromString(adateString + " 23:59")!
        
        let xAxis = chart.xAxis as TKChartDateTimeAxis
        xAxis.style.lineStroke = TKStroke(color: UIColor.blueColor())
        xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.Hours
        xAxis.majorTickInterval = 4
        xAxis.style.majorTickStyle.ticksHidden = false
        xAxis.range = TKRange(minimum: date1, andMaximum: date2)

        let yAxis = chart.yAxis as TKChartNumericAxis
        yAxis.position = TKChartAxisPosition.Left
        yAxis.style.lineHidden = false
        yAxis.style.lineStroke = TKStroke(color: UIColor.blueColor())
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment.Left
        yAxis.style.labelStyle.textOffset = UIOffsetMake(10, 0)
        yAxis.style.labelStyle.firstLabelTextAlignment = TKChartAxisLabelAlignment.Left
        yAxis.style.labelStyle.firstLabelTextOffset = UIOffsetMake(10, 0)
        yAxis.position = TKChartAxisPosition.Left
        yAxis.style.majorTickStyle.ticksHidden = false
        yAxis.style.minorTickStyle.ticksHidden = false
        
        var yMaxFloat: Float = maxElement(dev_y)
        var yMinFloat: Float = minElement(dev_y)

        yMinFloat = yMinFloat - (0.1 * yMinFloat)
        yMaxFloat = yMaxFloat + (0.1 * yMaxFloat)
        
        yMaxFloat = round(yMaxFloat)
        yMinFloat = round(yMinFloat)
        
        var yMaxFloat1 : NSString = NSString(format: "%.01f", yMaxFloat)
        var yMinFloat1 : NSString = NSString(format: "%.01f", yMinFloat)
        
        yAxis.range = TKRange(minimum: yMinFloat1, andMaximum: yMaxFloat1)
        
        var yMaxMinDiff = (yMaxFloat - yMinFloat) * 0.1
        
        if yMaxMinDiff < 1 {
            var yMaxMinDiffStr : NSString = NSString(format: "%.01f", yMaxMinDiff)
            let formatter = NSNumberFormatter()
            var yMaxMinDiffShort : NSNumber? = formatter.numberFromString(yMaxMinDiffStr)
            yAxis.majorTickInterval = yMaxMinDiffShort
            
        } else {
            yMaxMinDiff = round(yMaxMinDiff)
            yAxis.majorTickInterval = yMaxMinDiff
        }
        
        chart.title().hidden = false
        chart.title().adjustsFontSizeToFitWidth = true
        chart.title().text = getChartTitle(mydeviceID)
        chart.legend().hidden = true
        
        chart.allowAnimations = true
        
        stopInd()
    }
    
    
    func getChartTitle (deviceid: String) -> (String) {
        var chartTitle: String = "Not found..."
        
        var serverSettings:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        var managedContext: NSManagedObjectContext = serverSettings.managedObjectContext!
        var request = NSFetchRequest(entityName: "IndigoDevices")
        
        let deviceFilter = NSPredicate (format: "id = '\(deviceid)'")!
        request.predicate = deviceFilter
        var DevicesList: Array<AnyObject>=[]
        DevicesList = managedContext.executeFetchRequest(request, error: nil)!
        
        if DevicesList.count > 0 {
            
            var data: NSManagedObject = DevicesList[0] as NSManagedObject
            
            var devname = data.valueForKeyPath("name") as String
            chartTitle = "Chart for \(devname)"
            
        }
        
        return chartTitle
    }
   
}

