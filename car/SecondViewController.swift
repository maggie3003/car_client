//
//  SecondViewController.swift
//  car
//
//  Created by Meiqi You on 26/10/2015.
//  Copyright © 2015 Meiqi You. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    //var cell = TrackCell()
    var coapClient: SCClient!
    var hostName = "192.168.11.101"
    var portNumber = "5683"
    var size = 1
    var trip: [String] = []
    
    var separatorLine = "\n---------\n"
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
        
        getData()
        print(trip.description + "slkdjflajlkfjaljdlkfajldjflkasdjlfahklhjal;kshdfa")
    
        
        //refreshControl.addTarget()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     /*   func tableView(tableView:UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var oneCell = UITableViewCell()
        var startTime = trip[indexPath.row].0
        var endTime = trip[indexPath.row].1
        var cell:
        
        oneCell.textLabel?.text = "Start Time: " + startTime + " EndTime: " + endTime

        
        var cell = tableView.dequeueReusableCellWithIdentifier("TrackCell",forIndexPath:indexPath) as! TrackCell
        cell.titleLabel.text = trip[indexPath.row]
        print(trip[indexPath.row] + "fjsjgfakjfgakfhgkasfhakhfakh")
        return cell
    }*/
    
    
    func getData(){
        let m = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        if let stringData = "trip".dataUsingEncoding(NSUTF8StringEncoding){
            m.addOption(SCOption.UriPath.rawValue, data: stringData)
            //print(stringData.description + "................")
        }
        if let port = UInt16(portNumber){
            coapClient.sendCoAPMessage(m, hostName: hostName, port: port)
        }
        else{
            //Label.text = "Invalid Port"
        }
        
        
    }
    
    


}


extension SecondViewController: SCClientDelegate {
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
            }
        }
        
        print("payload is here----------->>>>" + payloadstring)
        
        
        
        
       /*
        let tripData:[String] = payloadstring.componentsSeparatedByString("\n")
        size = tripData.count
        var newSize = size/2 - 1
        for var i in 0...newSize{
            let st = tripData[i*2].componentsSeparatedByString(":")[1]
            //cell.setStartTime(st)
            
            print("loooook attttt hererererere----->" + i.description)
            let et = tripData[i*2+1].componentsSeparatedByString(":")[1]
            //cell.setEndTime(et)
            trip.append("Start Time: " + st + "End Time: " + et)
            print("A Trip: " + trip[trip.count-1])
            print(trip.count.description + "Trip Count !")
        }*/
        
        
        let firstPartString = "Message received with type: \(message.type.shortString())\nwith code: \(message.code.toString()) \nwith id: \(message.messageId)\nPayload: \(payloadstring)"
        var optString = "Options:\n"
        for (key, _) in message.options {
            var optName = "Unknown"
            
            if let knownOpt = SCOption(rawValue: key) {
                optName = knownOpt.toString()
            }
            
            optString += "\(optName) (\(key))"
        }
        textView.text = payloadstring
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        textView.text = "Failed with Error \(error.localizedDescription)" + separatorLine + separatorLine + textView.text
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        //textView.text = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n" + separatorLine + separatorLine + textView.text
    }
}
