//
//  FirstViewController.swift
//  car
//
//  Created by Meiqi You on 26/10/2015.
//  Copyright © 2015 Meiqi You. All rights reserved.
//

import UIKit
import Charts


class FirstViewController: UIViewController {
    var coapClient: SCClient!
    @IBOutlet weak var temperatureText: UILabel!
    @IBOutlet weak var humidityText: UILabel!
    //test
    @IBOutlet weak var Label: UILabel!
    //get host and Port
    //var hostName = "localhost"
    var hostName = "192.168.11.101"
    //@IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var choiceSegment: UISegmentedControl!
    //temp,humi result
    var temperatureResult = String()
    var humidityResult = String()
    
    //line chart
    @IBOutlet weak var lineChartView: LineChartView!
    
    var hours = [String]!()
    var portNumber = "5683"
    let separatorLine = "\n-------\n"
    
    //select date
    var date = String()
   
    @IBAction func dismissDP(sender: AnyObject) {
        datePicker.resignFirstResponder()
    }
    @IBOutlet weak var datePicker: UITextField!
    @IBAction func pickDate(sender: UITextField) {
        let datePickerView : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleFromDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleFromDatePicker(sender:UIDatePicker){
        let timeFormatter = NSDateFormatter()
        let dateFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .ShortStyle
        dateFormatter.dateFormat = "yyyyMMdd"
        datePicker.text = timeFormatter.stringFromDate(sender.date)
        date = dateFormatter.stringFromDate(sender.date)
        getChart(date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
        //coapClient.httpProxyingData = ("localhost", 5683)
        
        getTempHumid()
        Label.text = hostName + ", " + portNumber
        
        delay(5){
            print("5 seconds later......")
        }
       
        
        //get current day's temperature and humidity chart
        let nowDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.stringFromDate(nowDate)
        getChart(dateString)
    }
    
    //get selected day's temperature and humidity
    func getChart(date:String){
        let m = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        if let stringData = ("date/"+date).dataUsingEncoding(NSUTF8StringEncoding){
            m.addOption(SCOption.UriPath.rawValue, data: stringData)
            print(stringData.description + "................")
        }
        if let port = UInt16(portNumber){
            coapClient.sendCoAPMessage(m, hostName: hostName, port: port)
        }
        else{
            Label.text = "Invalid Port"
        }
        delay(5){
            self.getTempHumid()
        }

    }
    
    func setChart(dataPoints:[ChartDataEntry],values:[Double]){
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "T/H")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //get current time temperature and humidity
    func getTempHumid(){
        let m = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        if let stringData = "latestData".dataUsingEncoding(NSUTF8StringEncoding){
            m.addOption(SCOption.UriPath.rawValue, data: stringData)
        }
        if let port = UInt16(portNumber){
            coapClient.sendCoAPMessage(m, hostName: hostName, port: port)
        }
        else{
            Label.text = "Invalid Port"
        }
        delay(5){
            self.getTempHumid()
        }
    }
    
    func delay(delay: Double, closure:()->()){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    
    
}

extension FirstViewController: SCClientDelegate{
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage){
        var payloadstring = ""
        if let pay = message.payload {
                if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                    payloadstring = String(string)
                }
        }
            //Label.text = payloadstring
        print("payloadstring starts here!!!_______>>>>>"+payloadstring)
        
        if payloadstring.containsString("Temperature:"){
            //change temperature and humidity label
            let temperatureRaw = payloadstring.componentsSeparatedByString(",")[0]
            let humidityRaw = payloadstring.componentsSeparatedByString(",")[1]
            temperatureResult = temperatureRaw.componentsSeparatedByString(":")[1]
            humidityResult = humidityRaw.componentsSeparatedByString(":")[1]
            temperatureText.text = temperatureResult
           humidityText.text = humidityResult
            }
        
        if payloadstring.containsString("T,20") && choiceSegment.selectedSegmentIndex == 0 && !payloadstring.containsString("Data"){
            print("Attention!!!!!!!!!!!!!!!!!!!!!!!!!!!! Start Line Chart Now!!!!!!!!")
            var temperatureDic:[ChartDataEntry] = []
            var hours = [String]()
            var tempes = [Double]()
            
            let temphumiData:[String] = payloadstring.componentsSeparatedByString("\n")
            var counter = 1
                for oneRecord in temphumiData{
                    if oneRecord.containsString("T"){
                    let index = oneRecord.componentsSeparatedByString(",")[1].startIndex.advancedBy(8)
                    let hour = oneRecord.componentsSeparatedByString(",")[1].substringFromIndex(index)
                    hours.append(hour)
                    print("temperature hour is -------->" + hour)
                    let tempe = oneRecord.componentsSeparatedByString(",")[2]
                        
                        print("Temp Temp Temp Temp -------->>>>>" + tempe)
                    tempes.append((tempe as NSString).doubleValue)
                        let dataEntry = ChartDataEntry(value:(tempe as NSString).doubleValue,xIndex: counter++)
                    temperatureDic.append(dataEntry)
                    //temperatureDic[hour]=Double(tempe)
                    }
                }
                setChart(temperatureDic, values: tempes)
            
        }else if (payloadstring.containsString("H,20") && choiceSegment.selectedSegmentIndex==1 && !payloadstring.containsString("Data")){
            var humidityDic:[ChartDataEntry] = []
            var hours = [String]()
            var humids = [Double]()
            let humiData: [String] = payloadstring.componentsSeparatedByString("\n")
            var counter = 1
                for oneRecord in humiData{
                    if oneRecord.containsString("H"){
                    let index = oneRecord.componentsSeparatedByString(",")[1].startIndex.advancedBy(8)
                    let hour = oneRecord.componentsSeparatedByString(",")[1].substringFromIndex(index)
                        print("humidity hour is ------>" + hour)
                    hours.append(hour)
                    let humi = oneRecord.componentsSeparatedByString(",")[2]
                    humids.append((humi as NSString).doubleValue)
                    let dataEntry = ChartDataEntry(value:(humi as NSString).doubleValue,xIndex: counter++)
                    humidityDic.append(dataEntry)
                    }
                }
            setChart(humidityDic, values: humids)
                
            }
    
    
            
            let firstPartString = "Message received with type: \(message.type.shortString())\nwith code: \(message.code.toString()) \nwith id: \(message.messageId)\nPayload: \(payloadstring)"
            var optString = "Options:\n"
            for (key, _) in message.options {
                var optName = "Unknown"
                
                if let knownOpt = SCOption(rawValue: key) {
                    optName = knownOpt.toString()
                }
                
                optString += "\(optName) (\(key))"
            }
            //textView.text = separatorLine + firstPartString + optString + separatorLine + textView.text!
    }
        func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
            Label.text = "Failed with Error \(error.localizedDescription)" + separatorLine + separatorLine
        }
        
        func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
           // textView.text = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n" + separatorLine + separatorLine + textView.text!
        }
    
}








