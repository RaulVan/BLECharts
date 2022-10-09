//
//  ViewController.swift
//  BLECharts
//
//  Created by Eleven on 7/22/22.
//

import UIKit
import SwifterSwift


class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        BLEManager.sharedManager.scan(services: nil) { discoverys in
            print(discoverys)
//            self.tableView.reloadDataAsync()
        } completionBlock: {
            print("")
//            SVProgressHUD.dismiss()
//            self.tableView.reloadDataAsync()
        } errorBlock: { state in
//            SVProgressHUD.showError(withStatus: state.description)
//            self.tableView.reloadDataAsync()
        }
    }
    
}

