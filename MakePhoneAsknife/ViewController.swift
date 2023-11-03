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
    
    // 添加CLLocationManager属性
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
    
    
    // 添加变量来跟踪上一个位置
        var previousLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化CLLocationManager
        
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
                // 在这里，我使用了可选绑定 if let 来检查 targets 和 location 是否包含非空值
                // 只有在两者都包含非空值的情况下，才会执行下面的代码

                let xCoordinate = location.coordinate.latitude
                let yCoordinate = location.coordinate.longitude
                let speed = location.speed

                // 计算方向
            let direction = calculateDirection(from: previousLocation!, to: location)
                previousLocation = location // 更新前一个位置

                // 构建位置信息字典
                let locationInfo: [String: Any] = [
                    "xCoordinate": xCoordinate,
                    "yCoordinate": yCoordinate,
                    "direction": direction,
                    "speed": speed
                ]

            do {
                // 将字典转换为 JSON 数据
                let jsonData = try JSONSerialization.data(withJSONObject: locationInfo, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // 发送 JSON 字符串
                    ConnectManager.shared.send(message: jsonString, to: targets)
                }
            } catch {
                print("Error encoding locationInfo: \(error)")
            }

            }
          
    }
    func calculateDirection(from: CLLocation, to: CLLocation) -> String {
        // 获取起始点和结束点的经度和纬度
        let fromLatitude = from.coordinate.latitude
        let fromLongitude = from.coordinate.longitude
        let toLatitude = to.coordinate.latitude
        let toLongitude = to.coordinate.longitude

        // 计算经度差和纬度差
        let deltaLongitude = toLongitude - fromLongitude
        let deltaLatitude = toLatitude - fromLatitude

        // 判断方向
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




