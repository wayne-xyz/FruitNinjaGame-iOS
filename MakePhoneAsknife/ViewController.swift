//
//  ViewController.swift
//  MakePhoneAsknife
//
//  Created by 黄云峰 on 10/23/23.
//
// try the git
import UIKit
import MultipeerConnectivity
import CoreLocation


class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate,CLLocationManagerDelegate {

        
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCAdvertiserAssistant!
    var locationManager: CLLocationManager!
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            // Handle peer state changes
        }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            // Handle data received from peers
        }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
            // Handle data streams from peers
        }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
            // Handle the start of receiving a resource
        }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
            // Handle the finish of receiving a resource
        }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        // 用户完成设备查找并选择连接设备
        // 关闭设备查找页面
        browserViewController.dismiss(animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                // 获取实时位置信息
                let xCoordinate = location.coordinate.latitude
                let yCoordinate = location.coordinate.longitude
                let direction = "north" // 请根据实际情况获取移动方向
                let speed = location.speed

                // 构建位置信息字典
                let locationInfo: [String: Any] = [
                    "xCoordinate": xCoordinate,
                    "yCoordinate": yCoordinate,
                    "direction": direction,
                    "speed": speed
                ]

                // 将位置信息发送给连接的设备
                let connectedPeers = session.connectedPeers
                for peer in connectedPeers {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: locationInfo, options: [])
                        try session.send(data, toPeers: [peer], with: .reliable)
                    } catch {
                        print("Error sending location info: \(error)")
                    }
                }
            }
        }
        

    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // User cancelled the device discovery
                // Dismiss the view
                browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) -> Bool {
        // 当其他设备被发现时，返回 true 允许显示该设备
        // 您可以在此处处理其他设备被发现时的逻辑

        // 执行segue以显示设备被发现的提示视图控制器
        self.performSegue(withIdentifier: "DeviceDiscoveredSegue", sender: self)

        return true
    }


    @IBAction func showPopup(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Game Guide", message: "这是一段预设文本，用户无法编辑。", preferredStyle: .alert)
        
        // ﻿add a confirm button
        let okAction = UIAlertAction(title: "Let's go", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // show
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        // 当"start game"按钮被点击时，弹出设备查找界面
        present(browser, animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 获取设备的唯一标识符
        if let deviceID = UIDevice.current.identifierForVendor {
           peerID = MCPeerID(displayName: deviceID.uuidString)
        } else {
        // 如果无法获取设备ID，可以使用一个默认的名称
           peerID = MCPeerID(displayName: "Player1")
                }


        // 创建会话
        session = MCSession(peer: peerID)
        session.delegate = self


        
        // 创建广告和浏览器
        let serviceType = "fruit-ninja-game"
        advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self

        // 启动广告
        advertiser.start()
        
        // 初始化位置管理器
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

}




