//
//  Rechability.swift
//  DoodbleBlueTask
//
//  Created by malli nallapati on 24/05/18.
//  Copyright © 2018 malliswarinallapati. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit


public class Rechability //Fourtunately this is mispelled!
    
{
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    private static func showUserAlert(viewController:UIViewController){
        let alert = UIAlertController(title: "No Internet!", message: "Please check the network connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func isConnectedToInternetBoolValue() -> Bool {
        return Rechability.isConnectedToNetwork()
    }
    
    static func isConnectedToInternet(viewController:UIViewController) -> Bool {
        if Rechability.isConnectedToNetwork() == false
        {
            print("isConnectedToInternet == false")
            showUserAlert(viewController: viewController)
        }
        
        print("isConnectedToInternet == true")
        return Rechability.isConnectedToNetwork()
    }
}
