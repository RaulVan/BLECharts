//
//  ChartsViewController.swift
//  BLECharts
//
//  Created by Eleven on 8/20/22.
//

import UIKit
import SVProgressHUD
import Charts


/// 折线图
class ChartsViewController: UIViewController {
    
    
    
    var xValue: Double = 0 // 横轴
    let timeInterval = 0.5 // 描点频率
    
    
    var chartView: LineChartView = LineChartView()
    
    var lineChartData: LineChartData?
    
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
//        setLineView()
        
        chartView.frame = CGRect(x: 10, y: 120, width: kScreenWidth - 20, height: 250)
        view.addSubview(chartView)
        chartView.backgroundColor = .white
        chartView.noDataText = "暂无数据"
        
        chartView.chartDescription.enabled = false
        chartView.pinchZoomEnabled = true
        chartView.dragEnabled = true
        chartView.legend.form = .circle
        
//        let leftAxis = chartView.leftAxis
//        leftAxis.drawLimitLinesBehindDataEnabled = true
//        leftAxis.removeAllLimitLines()
//        leftAxis.axisMinimum = 0
////        leftAxis.axisMaximum = 3500
//
////        chartView.xAxis.axisMinimum = 1
////        chartView.xAxis.axisMaximum = 100
//        chartView.xAxis.spaceMin = 0.5
//        chartView.xAxis.drawGridLinesEnabled = true
//        chartView.xAxis.granularityEnabled = true
//        chartView.xAxis.labelPosition = .bottom
//        chartView.xAxis.labelRotationAngle = 30
//        chartView.rightAxis.enabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.rightAxis.enabled = false
        
        let chartDataSet1 = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0)], label: self.title ?? "")
        chartDataSet1.drawCirclesEnabled = false
        chartDataSet1.setColor(UIColor(hex: 0xEA5C55)!) //UIColor(red:0.92, green:0.36, blue:0.33, alpha:1.00)#
        chartDataSet1.lineWidth = 1.0
        chartDataSet1.mode = .horizontalBezier
        chartDataSet1.drawValuesEnabled = false
        chartDataSet1.drawFilledEnabled = true
        chartDataSet1.fillColor = UIColor(hex: 0xEA5C55)!
        chartDataSet1.fillAlpha = 0.3
        
        //生成20条随机数据
//        var dataEntries = [ChartDataEntry]()
//        for i in 0..<20 {
//            let y = arc4random()%100
//            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
//            dataEntries.append(entry)
//        }
//
        //这50条数据作为1根折线里的所有数据
        
        
        //目前折线图只包括1根折线
        lineChartData = LineChartData(dataSets: [chartDataSet1])
        //设置折现图数据
        chartView.data = lineChartData
        
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
        
//        self.setPoint(x: xValue, y: Double(value))
        let dataEntry = ChartDataEntry(x: xValue, y: Double(value))
//        entries.append(dataEntry)
        xValue += timeInterval
        lineChartData?.appendEntry(dataEntry, toDataSet: 0)
        lineChartData?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        
        
    }
}
