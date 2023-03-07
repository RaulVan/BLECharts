//
//  ViewController.swift
//  BLECharts
//
//  Created by Eleven on 7/22/22.
//

import UIKit
import SwifterSwift
import SVProgressHUD
import CoreBluetooth
import BRPickerView


class ViewController: UIViewController {
    
    
    @IBOutlet weak var btnDevice: UIButton!
    
    @IBOutlet weak var dashView1: DashboardView!
    
    @IBOutlet weak var dashView2: DashboardView!
    
    @IBOutlet weak var dashView3: DashboardView!
    
    @IBOutlet weak var dashView4: DashboardView!
    
    
    var currentDevice: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdataValue(_:)), name: .kNotificationUpdateValue, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .kNotificationUpdateValue, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashView1.title = "心率"
        dashView1.type = .hr
        dashView1.value = "0"
        dashView1.untis = "次/分"
        dashView2.title = "血压"
        dashView2.type = .bp
        dashView2.value = "0"
        dashView2.untis = "mmHg"
        dashView3.type = .ph
        dashView3.title = "PH"
        dashView3.value = "0"
        dashView3.untis = ""
        dashView4.title = "UA"
        dashView4.type = .ua
        dashView4.value = "0"
        dashView4.untis = "umol/L"
        
        btnDevice.setTitle("搜索设备", for: .normal)
        
        Tap.on(view: dashView1) {
            let vc = ChartsViewController()
            vc.title = "心率"
            vc.type = .hr
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView2) {
            let vc = ChartsViewController()
            vc.title = "血压"
            vc.type = .bp
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView3) {
            let vc = ChartsViewController()
            vc.title = "PH"
            vc.type = .ph
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView4) {
            let vc = ChartsViewController()
            vc.title = "UA"
            vc.type = .ua
            self.navigationController?.pushViewController(vc)
        }
    }
    
    @IBAction func btnDeviceAction(_ sender: UIButton) {
//        if BLEManager.sharedManager.discoverys.count > 0 {
//            showDeviceList()
//        } else {
//            scanBLE()
//        }
        
        mockBLE()
    }
    
    func mockBLE() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _timer in
            
            let y1 = Int.random(in: 0..<900)
            
            let y2 = Int.random(in: 0..<900)
            
            let y3 = Int.random(in: 0..<900)
            
            let y4 = Int.random(in: 0..<900)
            
            let data = DashBoardData(valueHR: y1, valueBP: y2, valuePH: y3, valueUA: y4)
            
            NotificationCenter.default.post(name: .kNotificationUpdateValue, object: data)

        }
    }
    
    func scanBLE() {
//        self.btnDevice.isEnabled = false
        SVProgressHUD.show(withStatus: "搜索..")
        DispatchQueue.main.asyncAfter(delay: 5) {
            BLEManager.sharedManager.discoverys.removeAll()
            BLEManager.sharedManager.scan(services: nil) { discoverys in
                print(discoverys)
                
                print("")
//                BLEManager.sharedManager.stopScan()
            } completionBlock: {
                print("")
                
                SVProgressHUD.dismiss()
//                self.connectBLE()
                self.showDeviceList()
            } errorBlock: { state in
                SVProgressHUD.showError(withStatus: state.description)
                print("")
            }
        }
    }
    
    func connectBLE(_ peripheral: CBPeripheral) {
        BLEManager.sharedManager.connect(peripheral: peripheral) { connectedPeriheral in
            self.btnDevice.setTitle("设备:\(peripheral.name ?? "")", for: .normal)
            SVProgressHUD.showSuccess(withStatus: "已连接")
            for (index, ble) in BLEManager.sharedManager.discoverys.enumerated() {
                if ble.peripheral.identifier.uuidString == connectedPeriheral.identifier.uuidString {
                    BLEManager.sharedManager.discoverys[index].isConnect = true
                } else {
                    BLEManager.sharedManager.discoverys[index].isConnect = false
                }
            }
        } updateValue: { characteristic in
            guard let data:Data = characteristic.value else {
                return
            }
            print(data)
            if data.bytes.count == 8 {
                let data1 = data.subdata(in: 0..<2)
                var value1 = self.convertData(data: data1)
                let data2 = data.subdata(in: 2..<4)
                let value2 = self.convertData(data: data2)
                let data3 = data.subdata(in: 4..<6)
                let value3 = self.convertData(data: data3)
                let data4 = data.subdata(in: 6..<8)
                let value4 = self.convertData(data: data4)
                
                value1 = value1 * 1/2
                
                // 通知，绘制折线图等
                let data = DashBoardData(valueHR: value1 , valueBP: value2, valuePH: value3, valueUA: value4)
                
                NotificationCenter.default.post(name: .kNotificationUpdateValue, object: data)
            } else {
                
            }
        } errorBlock: { state in
            print(state)
            SVProgressHUD.showInfo(withStatus: state.localizedDescription)
            self.btnDevice.setTitle("搜索设备", for: .normal)
        }
    }
    
    func convertData(data: Data) -> Int {
        let value = self.convertUInt(data)
        let hexStr = HexUtils.encode(value)
        print("hexStr: \(hexStr) === \(hexStr.hexToDecimal)")
        return hexStr.hexToDecimal
    }
    
    func showDeviceList()  {
        let list = BLEManager.sharedManager.discoverys.compactMap({$0.name})
        let popoverVC = PopoverViewController()
        popoverVC.dataSource = list
        popoverVC.defaultValue = currentDevice ?? "" // sender.currentTitle ?? "M1"
        popoverVC.preferredContentSize = CGSize(width: 120, height: 130)
        popoverVC.cellSelectionHandler = { value, index in
            self.currentDevice = value
            let bleModel = BLEManager.sharedManager.discoverys[index]
            self.connectBLE(bleModel.peripheral)
        }
        popoverVC.modalPresentationStyle = .popover
        let popPresentationController = popoverVC.popoverPresentationController
        popPresentationController?.sourceView = btnDevice
        popPresentationController?.sourceRect = btnDevice.bounds
        popPresentationController?.permittedArrowDirections = .up
        popPresentationController?.delegate = self
        self.present(popoverVC, animated: true)
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
    
    
    
    @objc func notificationUpdataValue(_ notify: Notification) {
        
        guard let data = notify.object as? DashBoardData else {
            return
        }
        
        DispatchQueue.main.async {
            self.dashView1.value = "\(data.valueHR)"
            //MARK: - 血压超标要警告 // 血压：高压、低压两部分
            
            self.dashView2.value = "\(data.valueBP)"
            if data.valueBP >= 2800 {
                self.dashView2.backgroundColor = UIColor(red:0.92, green:0.36, blue:0.33, alpha:1.00)
            } else {
                self.dashView2.backgroundColor = .white
            }
            self.dashView3.value = "\(data.valuePH)"
            self.dashView4.value = "\(data.valueUA)"
        }
        
//        self.setPoint(x: xValue, y: value)
//        xValue += timeInterval
        
    }
    
    
    @IBAction func btnHistoryHandler(_ sender: Any) {
        showDatePicker()
    }
    
    
    func showDatePicker() {
        let picker = BRDatePickerView(pickerMode: .date)
        picker.title = "选择时间"
        picker.selectDate = Date()
        picker.isAutoSelect = true
        picker.show()
    }
}


extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension UIViewController {
    
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        return instantiateFromNib()
    }
}
