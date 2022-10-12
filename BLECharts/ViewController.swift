//
//  ViewController.swift
//  BLECharts
//
//  Created by Eleven on 7/22/22.
//

import UIKit
import SwifterSwift
import SVProgressHUD


class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func sacnBLE() {
        DispatchQueue.main.asyncAfter(delay: 5) {
            SVProgressHUD.show(withStatus: "搜索..")
            BLEManager.sharedManager.scan(services: nil) { discoverys in
                print(discoverys)
                
                print("")
                BLEManager.sharedManager.stopScan()
            } completionBlock: {
                print("")
                SVProgressHUD.dismiss()
                self.connectBLE()
                
            } errorBlock: { state in
                SVProgressHUD.showError(withStatus: state.description)
                print("")
            }
        }
    }
    
    func connectBLE() {
        let discovery = BLEManager.sharedManager.discoverys[0]
        let peripheral = discovery.peripheral
        
        BLEManager.sharedManager.connect(peripheral: peripheral) { connectedPeriheral in
            SVProgressHUD.showSuccess(withStatus: "已连接")
        } updateValue: { characteristic in
            guard let data:Data = characteristic.value else {
                return
            }
            let value = self.convertUInt(data)
            let hexStr = HexUtils.encode(value)
            NotificationCenter.default.post(name: .kNotificationUpdateValue, object: hexStr.hexToDecimal)
        } errorBlock: { state in
            print(state)
            SVProgressHUD.show(withStatus: state.localizedDescription)
        }
    }
    
    @discardableResult
    func convertUInt(_ data: Data) -> [UInt8] {
        
        let bytes  = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
        let u16 = bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        // 大小端转换
        let hostU16 = CFSwapInt16BigToHost(u16)
//        let hexString2 = HexUtils.encode(hostU16.toBytes)
//        print("\(hexString1) == \(hexString2)")
        return hostU16.toBytes
    }
}


