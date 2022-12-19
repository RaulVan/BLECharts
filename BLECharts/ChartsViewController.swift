//
//  ChartsViewController.swift
//  BLECharts
//
//  Created by Eleven on 8/20/22.
//

import UIKit
import SVProgressHUD


/// 折线图
class ChartsViewController: UIViewController {
    
    
    var sprotLineView: SportLineView?
    
    var xValue: Double = 0 // 横轴
    let timeInterval = 0.5 // 描点频率
    
    var type: DashBoardType = .none
    
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
        view.backgroundColor = .white
        setLineView()
    }
    
    
    @discardableResult
    /// 数据转换
    /// - Parameter data: data description
    /// - Returns: description
    func convertUInt(_ data: Data) -> [UInt8] {
        
        let bytes  = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
        let u16 = bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        // 大小端转换
        let hostU16 = CFSwapInt16BigToHost(u16)
        return hostU16.toBytes
    }
    
    func setLineView() {
        let sprotLineView = SportLineView.lineChartView(withFrame: CGRect(x: 10, y: 120, width: kScreenWidth - 20, height: 250))
        //        sprotLineView.type = .TriangleType
        sprotLineView.xValues = [1,2,3,4,5,6,7,8,9,10] // X 坐标值
        sprotLineView.yValues = [50, 80, 90, 100, 110, 120, 130, 140, 150, 160, 180, 190, 200] // Y 坐标值
        sprotLineView.isShowLine = true
        sprotLineView.drawChartWithLineChart()
        self.sprotLineView = sprotLineView
        view.addSubview(sprotLineView)
    }
    
    /// 设置描点
    /// - Parameters:
    ///   - x: x description
    ///   - y: y description
    func setPoint(x: Double, y: Double) {
        
        let newPoint = CGPoint(x: x, y: y)
        let newPointObj = NSValue(cgPoint: newPoint)
        self.sprotLineView?.pointArray.add(newPointObj)
        
        guard let pointArray = self.sprotLineView?.pointArray, let xValues = self.sprotLineView?.xValues else {
            return
        }
        //移除多余的点，修改 X 坐标，往后移动
        for (index, point) in pointArray.enumerated() {
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
        
        guard let data = notify.object as? DashBoardData else {
            return
        }
        var value: Int = 0
        switch self.type {
        case .hr:
            value = data.valueHR
        case .ph:
            value = data.valuePH
        case .bp:
            value = data.valueBP
        case .ua:
            value = data.valueUA
        default:
            break
        }
        
        self.setPoint(x: xValue, y: Double(value))
        xValue += timeInterval
        
    }
}
