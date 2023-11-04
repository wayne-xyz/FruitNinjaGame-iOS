//
//  ViewController.swift
//  MakePhoneAsknife
//
//  Created by 黄云峰 on 10/23/23.
//setting description
//Info.plist
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
import CoreHaptics

class ViewController: UIViewController, ConnectManagerDelegate,CLLocationManagerDelegate{
    
    // for update the lebel text
    @IBOutlet weak var conncetLable: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    var LabelopenMacApp: String="Please open the Mac app to connect"
    var Labelconnecting: String="Connecting"
    var Labelconnected:String="Connected you can press start"
    var LabelGaming:String="Gameing"
        
    enum gameStatus {
        case unconnect // lost game
        case Gaming //start game the status
        case connect //connect succed
    }
    
    var status:gameStatus=gameStatus.unconnect // default
    
    func didReceiveMessage(_ message: String, from peer: MCPeerID) {
        //
        print("recieve message\(message)")
        if message=="hit"{
            //vib
            triggerHapticFeedback()
        }else if message=="gameover"{
            
        }
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
                    self.status=gameStatus.connect
                    self.conncetLable.text=self.Labelconnected
                    self.startButton.isEnabled=true
                }
                
            }
        }else{
            DispatchQueue.main.async {
                self.status=gameStatus.unconnect
                // Perform UI updates on the main thread
                self.conncetLable.text=self.LabelopenMacApp
            }
        }
    }
    


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
            self.status=gameStatus.Gaming
            sendMassage("Start")
            
            startAccelerometerUpdates()
            self.conncetLable.text=LabelGaming
            
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

        ConnectManager.shared.delegate = self
        ConnectManager.shared.start()
        startButton.isEnabled=false
        
       
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
                        let message="\(xAcceleration),\(yAcceleration),\(zAcceleration)"
                        self.sendMassage(message)
                        
                    }
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
          motionManager.stopAccelerometerUpdates()
    }
    
    
    //send message
    func sendMassage(_ message:String){
        print("Start sending ")
        if   let targets=ConnectManager.shared.session?.connectedPeers{
            ConnectManager.shared.send(message: message, to: targets)
        }else{
            print("Send failed")
            DispatchQueue.main.async {
                // Perform UI updates on the main thread
                self.conncetLable.text=self.LabelopenMacApp
            }
        }

    }
    
    
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

}




