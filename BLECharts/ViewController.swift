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
    
    
    @IBOutlet weak var btnDevice: UIButton!
    
    @IBOutlet weak var dashView1: DashboardView!
    
    @IBOutlet weak var dashView2: DashboardView!
    
    @IBOutlet weak var dashView3: DashboardView!
    
    @IBOutlet weak var dashView4: DashboardView!
    
    
    var currentDevice: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashView1.title = "心率"
        dashView1.value = "80"
        dashView1.untis = "次/分"
        dashView2.title = "血压"
        dashView2.value = "90/140"
        dashView2.untis = "mmHg"
        dashView3.title = "PH"
        dashView3.value = "7.35"
        dashView3.untis = ""
        dashView4.title = "UA"
        dashView4.value = "126"
        dashView4.untis = "umol/L"
        
        Tap.on(view: dashView1) {
            let vc = ChartsViewController()
            vc.title = "心率"
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView2) {
            let vc = ChartsViewController()
            vc.title = "血压"
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView3) {
            let vc = ChartsViewController()
            vc.title = "PH"
            self.navigationController?.pushViewController(vc)
        }
        
        Tap.on(view: dashView4) {
            let vc = ChartsViewController()
            vc.title = "UA"
            self.navigationController?.pushViewController(vc)
        }
    }
    @IBAction func btnDeviceAction(_ sender: UIButton) {
        let list = ["M1", "M2"]
        let popoverVC = PopoverViewController()
        popoverVC.dataSource = list
        popoverVC.defaultValue = currentDevice ?? "" // sender.currentTitle ?? "M1"
        popoverVC.preferredContentSize = CGSize(width: 120, height: 130)
        popoverVC.cellSelectionHandler = { value, index in
//            let type = self.reportTypeList[index]
//            self.selectedData1 = [type]
//            sender.setTitle(value, for: .normal)
//            self.refreshView()
            self.currentDevice = value
        }
        popoverVC.modalPresentationStyle = .popover
        let popPresentationController = popoverVC.popoverPresentationController
        popPresentationController?.sourceView = sender
        popPresentationController?.sourceRect = sender.bounds
        popPresentationController?.permittedArrowDirections = .up
        popPresentationController?.delegate = self
        self.present(popoverVC, animated: true)
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
