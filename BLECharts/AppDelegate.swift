//
//  AppDelegate.swift
//  BLECharts
//
//  Created by Eleven on 7/22/22.
//

import UIKit
import SVProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setImageViewSize(CGSize(width: 28, height: 28))
        
        BLEManager.sharedManager.bleInit { state in
            
        } error: { state in
            switch state {
                case .unauthorized:
                    let alertVC = UIAlertController(title: "", message: "Open Bluetooth" , preferredStyle: .alert)
                    
                    alertVC.addAction(title: "Settings", style: .cancel, isEnabled: true) { _action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    alertVC.show()
                default:
                    break
            }
        }
        
        
        return true
    }


}

