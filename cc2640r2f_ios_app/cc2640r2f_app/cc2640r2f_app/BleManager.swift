//
//  BleManager.swift
//  bleTest
//
//  Created by JamesLi on 2018/3/4.
//  Copyright © 2018年 JamesLi. All rights reserved.
//

import Foundation
import CoreBluetooth



class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    //系统蓝牙管理对象
    var bleScanFlg : Int8!
    var bleConnectFlg : Int8!
    var bleDisServieFlg : Int8!
    var manager : CBCentralManager!
    var connectedPeripheral : CBPeripheral!
    var writeCharacteristic : CBCharacteristic!

    var connBleName: String = "ECG"
    var serviceText: String = "FFF0"
    var notifyText: String = "FFF4"
    var writeText: String = "FFF1"

    
    //log
    typealias bleMsg = (_ backMsg: String) ->()
    var logPrint: bleMsg!
    //接收数据
    typealias fucBlock1 = (_ backMsg: [UInt8]) ->()
    var bleDataProcess: fucBlock1!
    // ble状态
    typealias bleStatus = (_ backMsg: UInt8) -> ()
    var bleStatusSet: bleStatus!
    
    //原始数据接收标志位
    public var RowDataSaveStatus : UInt8 = 0
    var filePath: URL!
    
    override init() {

    }
    public func bleBlockTest() {
        logPrint("block test")
    }
    
    public func bleManagerInit() {
        manager = CBCentralManager.init(delegate: self, queue: nil)
        bleScanFlg = 0
        bleConnectFlg = 0
        bleDisServieFlg = 0
    }
    
    public func bleStartScan() {
        manager.scanForPeripherals(withServices: nil, options: nil)
        //speedTimerStart()
    }
    
    public func bleDisConnect() {
        manager.cancelPeripheralConnection(connectedPeripheral)
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManagerStateUnknown")
        case .resetting:
            print("CBCentralManagerStateResetting")
        case .unsupported:
            print("CBCentralManagerStateUnsupported")
        case .unauthorized:
            print("CBCentralManagerStateUnauthorized")
        //蓝牙电源关闭
        case .poweredOff:
            print("CBCentralManagerStatePoweredOff")
           logPrint("蓝牙电源关闭中，请先打开蓝牙...")
        //蓝牙上电，自动开始搜索设备
        case .poweredOn:
            print("CBCentralManagerStatePoweredOn")
            if bleScanFlg == 0 {
                bleScanFlg = 1
                logPrint("搜索设备中...")
                bleStartScan()
            }
            
        }
    }
    //1、发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var device: String = "nil"
        if peripheral.name == nil {
            //logPrint("没有找到设备，请重新搜索\r\n")
            return
        }
        
        device = String(describing: peripheral.name!)
        logPrint(device)
        if device == connBleName {
            print("找到制定设备RSSI:\(RSSI),Adv:\(advertisementData)\n准备进行连接\n")
            //停止搜索
            manager.stopScan()
            connectedPeripheral = peripheral;
            //链接设备
            manager.connect(connectedPeripheral, options: nil)
        }
        //链接成功进行搜索服务
        
    }
    //2、链接成功获取Services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if bleDisServieFlg == 0 {
            bleDisServieFlg = 1;
            logPrint("链接成功开始扫描服务\n")
            peripheral.delegate = self;
            peripheral.discoverServices(nil)
            
        }
    }
    //3、获取Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            if service.uuid.uuidString == serviceText {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    //4、Indicate characteristics UUID
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        for characteristics in service.characteristics! {
            switch characteristics.uuid.uuidString {
            case notifyText:
                /* 允许发送指令 */
                bleConnectFlg = 1
                print("notify FFF4\n")
                peripheral.setNotifyValue(true, for: characteristics)
                bleStatusSet(1)
                logPrint("开始接收数据")
            case writeText:
                print("Write FFF1\n")
                writeCharacteristic = characteristics
            default:
                break;
            }
            
        }
    }
    //5、characteristics value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        let characteristicLength = characteristic.value!.count
        let characteristicBuff = [UInt8](characteristic.value!)
        let characteristicName = "\(characteristic.uuid)"
        //接收指令和数据
        if characteristicName == "FFF4" {
            bleDataProcess(characteristicBuff)
            //deviceDataProcess(buff: characteristicBuff)
        }
        
    }
    //6、ble断链
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bleScanFlg = 0
        bleConnectFlg = 0
        bleDisServieFlg = 0
        logPrint("设备断开，继续搜索设备...")
        bleStatusSet(2)
        bleStartScan()
    }
    //7、bleWriteValue
    func bleWriteValue(buff: [UInt8]) {
        
        let _data = NSData(bytes: buff, length: buff.count)
        
        connectedPeripheral.writeValue(_data as Data, for: writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
    }

}
