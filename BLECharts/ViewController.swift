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
        
        DispatchQueue.main.asyncAfter(delay: 5) {
            BLEManager.sharedManager.scan(services: nil) { discoverys in
                print(discoverys)
                //            self.tableView.reloadDataAsync()
                print("")
                BLEManager.sharedManager.stopScan()
            } completionBlock: {
                print("")
                //            SVProgressHUD.dismiss()
                //            self.tableView.reloadDataAsync()
                
                self.connectBLE()
                
            } errorBlock: { state in
                //            SVProgressHUD.showError(withStatus: state.description)
                //            self.tableView.reloadDataAsync()
                print("")
            }
        }
    }
    
    func connectBLE() {
        let discovery = BLEManager.sharedManager.discoverys[0]
        let peripheral = discovery.peripheral
        
        BLEManager.sharedManager.connect(peripheral: peripheral) { connectedPeriheral in
            print("已连接")
        } updateValue: { characteristic in
            guard let data:Data = characteristic.value else {
                return
            }
            self.convertUInt(data)
        } errorBlock: { state in
            print(state)
        }
        
        
    }
    
    @discardableResult
    func convertUInt(_ data: Data) -> [UInt8] {
        
        let bytes  = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
        let u16 = bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        // 大小端转换
        let hostU16 = CFSwapInt16BigToHost(u16)
        
        let hexString1 = HexUtils.encode(bytes)
        let hexString2 = HexUtils.encode(hostU16.toBytes)
        print("\(hexString1) == \(hexString2)")
        return hostU16.toBytes
    }
}


