//
//  ChartsViewController.swift
//  BLECharts
//
//  Created by Eleven on 8/20/22.
//

import UIKit
import SVProgressHUD


class ChartsViewController: UIViewController {
    
    
    var sprotLineView: SportLineView?
    
    var xValue: Double = 0 // 横轴
    let timeInterval = 0.1
    
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
        
        setLineView()
        
        sacnBLE()
        
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _timer in
            let y = Double.random(in: 0..<5000)
            NotificationCenter.default.post(name: .kNotificationUpdateValue, object: y)
            
        }
        
    }
    
    func sacnBLE() {
        SVProgressHUD.show(withStatus: "搜索...")
        
        DispatchQueue.main.asyncAfter(delay: 3) {
            
            BLEManager.sharedManager.scan(services: nil) { discoverys in
                print(discoverys)
                
                print("")
                BLEManager.sharedManager.stopScan()
                self.connectBLE()
            } completionBlock: {
                print("")
                SVProgressHUD.dismiss()
                if BLEManager.sharedManager.discoverys.count <= 0 {
                    SVProgressHUD.showInfo(withStatus: "未找到")
                }
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
            self.title = connectedPeriheral.name
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
    
    func setLineView() {
        let sprotLineView = SportLineView.lineChartView(withFrame: CGRect(x: 10, y: 120, width: kScreenWidth - 20, height: 250))
        //        sprotLineView.type = .TriangleType
        sprotLineView.xValues = [1,2,3,4,5,6,7,8,9,10]
        sprotLineView.yValues = [500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]
        sprotLineView.isShowLine = true
        sprotLineView.drawChartWithLineChart()
        self.sprotLineView = sprotLineView
        view.addSubview(sprotLineView)
    }
    
    func setPoint(x: Double, y: Double) {
        
        let newPoint = CGPoint(x: x, y: y)
        let newPointObj = NSValue(cgPoint: newPoint)
        self.sprotLineView?.pointArray.add(newPointObj)
        
        guard let pointArray = self.sprotLineView?.pointArray, let xValues = self.sprotLineView?.xValues else {
            return
        }
        //移除多余的点
        for point in pointArray {
            let pointRestored = (point as! NSValue).cgPointValue
            if x > Double(xValues.count) {
                if pointRestored.x < Double(x - Double(xValues.count)) {
                    self.sprotLineView?.pointArray.remove(point)
                }
            }
        }
        self.sprotLineView?.exchangeLineAnyTime()
    }
}

extension ChartsViewController {
    
    @objc func notificationUpdataValue(_ notify: Notification) {
        
        guard let value = notify.object as? Double else {
            return
        }
        
        self.setPoint(x: xValue, y: value)
        xValue += timeInterval
        
    }
}
