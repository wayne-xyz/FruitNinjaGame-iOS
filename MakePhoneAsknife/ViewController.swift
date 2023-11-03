//
//  ViewController.swift
//  MakePhoneAsknife
//
//  Created by 黄云峰 on 10/23/23.
//

import UIKit
import MultipeerConnectivity
import CoreLocation


class ViewController: UIViewController, ConnectManagerDelegate{
    func didReceiveMessage(_ message: String, from peer: MCPeerID) {
        //
    }
    
    func didChangeConnectionState(peer: MCPeerID, isConnected: Bool) {
        //
        if isConnected{
            
        }else{
            
        }
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
     
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ConnectManager.shared.delegate = self
        ConnectManager.shared.start()
        
    }
    
    func sendMassage(){
        
        if   let targets=ConnectManager.shared.session?.connectedPeers{
            ConnectManager.shared.send(message: "hi i am ios app", to: targets)
        }else{
            
        }
          
    }

}




