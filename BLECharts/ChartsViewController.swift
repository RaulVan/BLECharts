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
    
    var valueA: Double = 0
    var valueB: Double = 0
    var values: [Double] = []
    
    var xValueH: Double = 0 // 横轴
    let timeIntervalH = 0.5 // 描点频率
    
    
    var chartView: LineChartView = LineChartView()
    var lineChartData: LineChartData?
    
    var chartViewH: LineChartView = LineChartView()
    var lineChartDataH: LineChartData?
    
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
        setupChartViewDefault()
        setupChartViewH()
    }
    
    fileprivate func setupChartViewDefault() {
        chartView.frame = CGRect(x: 10, y: 120, width: kScreenWidth - 20, height: 250)
        view.addSubview(chartView)
        chartView.backgroundColor = .white
        chartView.noDataText = "暂无数据"
        
        chartView.chartDescription.enabled = false
        chartView.pinchZoomEnabled = true
        chartView.dragEnabled = true
        chartView.legend.form = .circle
        
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
        
        //目前折线图只包括1根折线
        lineChartData = LineChartData(dataSets: [chartDataSet1])
        //设置折现图数据
        chartView.data = lineChartData
        
    }
    
    fileprivate func setupChartViewH() {
        chartViewH.frame = CGRect(x: 10, y: chartViewH.height + 220 + 250, width: kScreenWidth - 20, height: 250)
        view.addSubview(chartViewH)
        chartViewH.backgroundColor = .white
        chartViewH.noDataText = "暂无数据"
        
        chartViewH.chartDescription.enabled = false
        chartViewH.pinchZoomEnabled = true
        chartViewH.dragEnabled = true
        chartViewH.legend.form = .circle
        
        chartViewH.xAxis.labelPosition = .bottom
        chartViewH.rightAxis.enabled = false
        
        let chartDataSet1 = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0)], label: self.title ?? "")
        chartDataSet1.drawCirclesEnabled = false
        chartDataSet1.setColor(UIColor(hex: 0xEA5C55)!) //UIColor(red:0.92, green:0.36, blue:0.33, alpha:1.00)#
        chartDataSet1.lineWidth = 1.0
        chartDataSet1.mode = .horizontalBezier
        chartDataSet1.drawValuesEnabled = false
        chartDataSet1.drawFilledEnabled = true
        chartDataSet1.fillColor = UIColor(hex: 0xEA5C55)!
        chartDataSet1.fillAlpha = 0.3
        
        //目前折线图只包括1根折线
        lineChartDataH = LineChartData(dataSets: [chartDataSet1])
        //设置折现图数据
        chartViewH.data = lineChartDataH
    }
    
}

extension ChartsViewController {
    
    
    
    @objc func notificationUpdataValue(_ notify: Notification) {
        
        guard let data = notify.object as? DashBoardData else {
            return
        }
        var value: Double = 0
        switch self.type {
        case .hr:
            value = Double(data.valueHR)
            
            values.append(value)
            
            if values.count >= 2 {
                let value1 = values[values.count - 1] // B
                let value2 = values[values.count - 2] // A
                // |B - A| > 300
                if abs(value1 - value2) > 300 {
                    if valueA == 0 {
                        valueA = value2
                    } else {
                        // 计算  B - A
                        valueB = value2
                        let valueH = valueB - valueA
                        setDataEntryH(value: valueH)
                        
                        valueA = 0
                        valueB = 0
//                       //TODO:  values remove 前面保存的点
                    }
                }
            }
            
        case .ph:
            value = Double(data.valuePH)
        case .bp:
            value = Double(data.valueBP)
        case .ua:
            value = Double(data.valueUA)
        default:
            break
        }
        
        
        let dataEntry = ChartDataEntry(x: xValue, y: value)
        //        entries.append(dataEntry)
        xValue += timeInterval
        lineChartData?.appendEntry(dataEntry, toDataSet: 0)
        lineChartData?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        
        
        
       
    }
    
    
    fileprivate func setDataEntryH(value: Double) {
        let dataEntryH = ChartDataEntry(x: xValueH, y: value)
        xValueH += timeIntervalH
        lineChartDataH?.appendEntry(dataEntryH, toDataSet: 0)
        lineChartDataH?.notifyDataChanged()
        chartViewH.notifyDataSetChanged()
    }
}

extension ChartsViewController {
    
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
