//
//  ViewController.swift
//  MakePhoneAsknife
//
//  Created by 黄云峰 on 10/23/23.
////Info.plist
//Key: Privacy — Local Network Usage Description
//Value: FruitNinja needs to use your phone’s data to discover mac nearby
//Bonjur-service
//<?xml version="1.0" encoding="UTF-8"?>
//<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
//<plist version="1.0">
//<array>
//    <string>_MacGameApp._tcp</string>
//    <string>_MacGameApp_udp</string>
//</array>
//</plist>
// teste for the github
// mac- browsing(discovering)
// ios- adverstising..
// update


import UIKit
import MultipeerConnectivity
import CoreLocation
import CoreMotion


class ViewController: UIViewController, ConnectManagerDelegate,CLLocationManagerDelegate{
    
    // for update the lebel text
    @IBOutlet weak var conncetLable: UILabel!
    

    var LabelopenMacApp: String="Please open the Mac app to connect"
    var Labelconnecting: String="Connecting"
    var Labelconnected:String="Connected you can press start"
        
 
    
    func didReceiveMessage(_ message: String, from peer: MCPeerID) {
        //
    }
    
    func didChangeConnectionState(peer: MCPeerID, isConnected: Bool) {
        //update the label to prompt the connect situation
        DispatchQueue.main.async {
            // Perform UI updates on the main thread
            self.conncetLable.text=self.Labelconnecting
        }
       
        if isConnected{
            if let targets = ConnectManager.shared.session?.connectedPeers, !targets.isEmpty{
                DispatchQueue.main.async {
                    // Perform UI updates on the main thread
                    self.conncetLable.text=self.Labelconnected
                }
                
            }
        }else{
            DispatchQueue.main.async {
                // Perform UI updates on the main thread
                self.conncetLable.text=self.LabelopenMacApp
            }
        }
    }
    
    // CLLocationManager properti
    var locationManager: CLLocationManager!

    @IBAction func showPopup(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Game Guide", message: "Just open the Mac app to connect, and press the start game to move your phone as the Shuriken, Go Ninja!", preferredStyle: .alert)
        
        // ﻿add a confirm button
        let okAction = UIAlertAction(title: "Let's go", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // show
        present(alertController, animated: true, completion: nil)
    }
    
 

    // start game
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        if let targets = ConnectManager.shared.session?.connectedPeers, !targets.isEmpty{
            
            
            
        }else{
            conncetLable.text=LabelopenMacApp
        }
    }
    
    
    // property for last location
    var previousLocation: CLLocation?
    
    let motionManager = CMMotionManager()
    // for init the conncet and motion
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init CLLocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        ConnectManager.shared.delegate = self
        ConnectManager.shared.start()
        
       
        // for test
        //_ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendMassage), userInfo: nil, repeats: true)
        
        startAccelerometerUpdates()
    }
    
    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // Update interval (e.g., 60 times per second)
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                if let acceleration = accelerometerData?.acceleration {
                    // Process the accelerometer data here
                    
                    let xAcceleration = acceleration.x
                    let yAcceleration = acceleration.y
                    let zAcceleration = acceleration.z
                    
                    // Calculate the magnitude of acceleration
                    let accelerationMagnitude = sqrt(xAcceleration * xAcceleration + yAcceleration * yAcceleration + zAcceleration * zAcceleration)
                    
                    // Detect significant changes in acceleration
                    let accelerationThreshold: Double = 1.1
                    if accelerationMagnitude > accelerationThreshold {
                        // Respond to the detected movement
                        print("Device is moving!")
                        print("x:\(xAcceleration),y:\(yAcceleration),z:\(zAcceleration)")
                        var message="\(xAcceleration),\(yAcceleration),\(zAcceleration)"
                        self.sendMassage(message)
                        
                    }
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
          motionManager.stopAccelerometerUpdates()
    }
    
    
    
    func sendMassage(_ message:String){
        print("Start sending ")
        if   let targets=ConnectManager.shared.session?.connectedPeers{
            ConnectManager.shared.send(message: message, to: targets)
        }else{
            print("Send failed")
        }
        
        
          
    }
    
    
    // it's not gps
    func originalSendMessage(){
        if let targets = ConnectManager.shared.session?.connectedPeers,
            let location = locationManager.location {
            //optional check targests and location

            let xCoordinate = location.coordinate.latitude
            let yCoordinate = location.coordinate.longitude
            let speed = location.speed

                // cacul the orientation
            let direction = calculateDirection(from: previousLocation!, to: location)
                previousLocation = location // update the previous location

                // save the location dictionary
            let locationInfo: [String: Any] = [
                    "xCoordinate": xCoordinate,
                    "yCoordinate": yCoordinate,
                    "direction": direction,
                    "speed": speed
            ]
            print(locationInfo)
            do {
                // change the location to string
                let jsonData = try JSONSerialization.data(withJSONObject: locationInfo, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // send string
                    ConnectManager.shared.send(message: jsonString, to: targets)
                    print("send succefully\(jsonString)")
                }
            } catch {
                print("Error encoding locationInfo: \(error)")
            }
                
        }else{
            conncetLable.text=LabelopenMacApp
        }
    }
    
    func calculateDirection(from: CLLocation, to: CLLocation) -> String {
        // get start and end loction
        let fromLatitude = from.coordinate.latitude
        let fromLongitude = from.coordinate.longitude
        let toLatitude = to.coordinate.latitude
        let toLongitude = to.coordinate.longitude

        // caculate the dif
        let deltaLongitude = toLongitude - fromLongitude
        let deltaLatitude = toLatitude - fromLatitude

        // orentation
        if abs(deltaLongitude) > abs(deltaLatitude) {
            if deltaLongitude > 0 {
                return "east"
            } else {
                return "west"
            }
        } else {
            if deltaLatitude > 0 {
                return "north"
            } else {
                return "south"
            }
        }
    }

}




