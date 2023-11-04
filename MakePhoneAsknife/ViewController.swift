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


class ViewController: UIViewController, ConnectManagerDelegate,CLLocationManagerDelegate{
    func didReceiveMessage(_ message: String, from peer: MCPeerID) {
        //
    }
    
    func didChangeConnectionState(peer: MCPeerID, isConnected: Bool) {
        //
        if isConnected{
            
        }else{
            
        }
    }
    
    // CLLocationManager properti
    var locationManager: CLLocationManager!
    

    @IBAction func showPopup(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Game Guide", message: "这是一段预设文本，用户无法编辑。", preferredStyle: .alert)
        
        // ﻿add a confirm button
        let okAction = UIAlertAction(title: "Let's go", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // show
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
     
        
    }
    
    
    // property for last location
    var previousLocation: CLLocation?
    
    
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
        
    }
    
    func sendMassage(){
//        
//        if   let targets=ConnectManager.shared.session?.connectedPeers{
//            ConnectManager.shared.send(message: "hi i am ios app", to: targets)
//        }else{
//            
//        }
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

            do {
                // change the location to string
                let jsonData = try JSONSerialization.data(withJSONObject: locationInfo, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // send string
                    ConnectManager.shared.send(message: jsonString, to: targets)
                }
            } catch {
                print("Error encoding locationInfo: \(error)")
            }

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




