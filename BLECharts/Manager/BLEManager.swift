//
//  BLEManager.swift
//  R3App
//
//  Created by Eleven on 6/20/22.
//

import UIKit
import CoreBluetooth

fileprivate let localNamePrefix: String = "FTR-BLE"

/// 自定义的Ble state管理枚举，涵盖了蓝牙启动、扫描、连接及数据更新过程中的错误状态
public enum RYBleState: Error, CustomStringConvertible{
    
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
    case connectFailed
    case discoverServiceFailed
    case discoverCharacterFailed
    case updateStateFailed
    case updateValueFailed
    case disconnected
    
    public var description: String{
        switch self {
        case .poweredOn: return "Bluetooth is open"
        case .poweredOff: return "Bluetooth not open"
        case .unsupported: return "Bluetooth sdk not support"
        case .unauthorized: return "Bluetooth not authed"
        case .resetting: return "CBCentralManagerStateResetting"
        case .unknown: return "CBCentralManagerStateUnknown"
        case .connectFailed: return "ble: did fail to connect peripheral"
        case .discoverServiceFailed: return "ble: did discover services error"
        case .discoverCharacterFailed: return "ble: did discover character error"
        case .updateStateFailed: return "ble: did update notification state error"
        case .updateValueFailed: return "ble: did update value error"
        case .disconnected: return "ble: did disconnect peripheral"
        }
    }
}

/// 基于CoreBluetooth库封装的BleCentral服务类，使用block的方式简化了蓝牙启动，扫描及配对的回调流程
public class BLEManager: NSObject{
    
    public static let sharedManager = BLEManager()
    
    public var discoverys: [BLEModel] = [] //[[String: AnyObject]]()
    public var connectedPeriheral: CBPeripheral?
    
    public var writeCharacteristic: CBCharacteristic?
    
    fileprivate var cbManager: CBCentralManager!
    //初始化回调
    fileprivate var initCompletion: ((RYBleState)->Void)?
    fileprivate var initError: ((RYBleState)->Void)?
    //扫描回调
    fileprivate var scanCallback: (([BLEModel])->Void)?
    fileprivate var scanCompletion: (()->Void)?
    fileprivate var scanError: ((RYBleState)->Void)?
    //连接回调
    fileprivate var connectedBlock: ((CBPeripheral)->Void)?
    fileprivate var connectdUpdateBlock: ((CBCharacteristic)->Void)?
    fileprivate var connectdErrorBlock: ((RYBleState)->Void)?
    
    fileprivate var timerStop: Timer?
    
    fileprivate let timeSec: TimeInterval = 10
    
    private override init(){
        super.init()
    }
    
    //MARK: Public methods
    /// 检查Central设备的蓝牙状态
    ///
    /// - returns                   :RYBleState
    public func checkBleStatus() -> RYBleState{
        switch self.cbManager.state {
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        case .resetting: return .resetting
        case .unauthorized: return .unauthorized
        case .unknown: return .unknown
        case .unsupported: return .unsupported
        @unknown default:
            return .unknown
        }
    }
    
    /// 停止设备扫描
    public func stopScan(){
        self.cbManager.stopScan()
        self.scanCompletion?()
    }
    
    /// 初始化Central蓝牙状态
    ///
    /// - parameter completion      :蓝牙成功打开状态回调
    /// - parameter error           :蓝牙启动失败状态回调
    public func bleInit(completion: ((RYBleState)->Void)?, error: ((RYBleState)->Void)?){
        self.initCompletion = completion
        self.initError = error
        print("ble: init central manager.")
        self.cbManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    /// 扫描附件蓝牙配件
    ///
    /// - parameter services        :设备开启的服务列表, nullable
    /// - parameter discoverBlock   :发现设备后的回调
    /// - parameter completionBlock :扫描完成后的回调
    /// - parameter errorBlock      :扫描失败的回调
    public func scan(services: [CBUUID]?,discoverBlock: @escaping ([BLEModel])->Void, completionBlock: @escaping ()->Void, errorBlock: @escaping (RYBleState)->Void){
        self.scanCallback = discoverBlock
        self.scanCompletion = completionBlock
        self.scanError = errorBlock
        guard self.checkBleStatus() == .poweredOn else {
            self.scanError?(self.checkBleStatus())
            return
        }
        timerForStop(sec: timeSec)
        self.cbManager.scanForPeripherals(withServices: services, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
    }
    
    /// 连接指定的蓝牙配件
    ///
    /// - parameter peripheral       :需要连接的设备
    /// - parameter connected        :连接成功后的回调
    /// - parameter updateValue      :设备数据更新后的回调
    /// - parameter errorBlock       :连接失败的回调
    public func connect(peripheral: CBPeripheral, connected: @escaping (CBPeripheral)->Void, updateValue: @escaping (CBCharacteristic)->Void, errorBlock:@escaping (RYBleState)->Void){
        print("ble: start connect peripheral.")
        peripheral.delegate = self
        self.connectedBlock = connected
        self.connectdUpdateBlock = updateValue
        self.connectdErrorBlock = errorBlock
        guard self.checkBleStatus() == .poweredOn else {
            self.connectdErrorBlock?(self.checkBleStatus())
            return
        }
        self.cbManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
        //            self.stopScan()
    }
    
    public func disconnect() {
        if let connectedPeriheral = self.connectedPeriheral {
            self.cbManager.cancelPeripheralConnection(connectedPeriheral)
            self.connectedPeriheral = nil
            self.writeCharacteristic = nil
            //            self.discoverys.removeAll()
        }
    }
    
    
    public func writeToPeripheral(_ data: Data) {
        if let writeCharacteristic = self.writeCharacteristic {
            connectedPeriheral?.writeValue(data, for: writeCharacteristic, type: .withResponse)
        }
    }
    
    private func timerForStop(sec: TimeInterval) {
        timerStop = Timer.scheduledTimer(withTimeInterval: sec, repeats: false, block: { _timer in
            self.timerStop?.invalidate()
            self.timerStop = nil
            self.stopScan()
        })
        timerStop?.fireDate = Date().addingTimeInterval(sec)
        RunLoop.current.add(timerStop!, forMode: .common)
    }
}

//MARK: CBCentralManagerDelegate methods
extension BLEManager: CBCentralManagerDelegate{
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            print("ble: bluetooth is ok.")
            self.initCompletion?(.poweredOn)
        case .poweredOff: self.initError?(.poweredOff)
        case .unsupported: self.initError?(.unsupported)
        case .unauthorized: self.initError?(.unauthorized)
        case .resetting: self.initError?(.resetting)
        case .unknown: self.initError?(.unknown)
        @unknown default:
            self.initError?(.unknown)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        // localName.hasPrefix(localNamePrefix)
        if let localName = advertisementData["kCBAdvDataLocalName"] as? String, localName.count > 0, localName.hasPrefix(localNamePrefix) {
            print(localName)
            let bleModel = BLEModel(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            print(bleModel)
            if !self.discoverys.contains(bleModel) {
                self.discoverys.append(bleModel)
            }
            self.scanCallback?(self.discoverys)
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        print("ble: did connect peripheral.")
        self.connectedPeriheral = peripheral
        self.connectedBlock?(peripheral)
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("ble: did fail to connect peripheral - \(String(describing: error))")
        self.connectedPeriheral = nil
        self.connectdErrorBlock?(.connectFailed)
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("ble: did disconnect peripheral - \(String(describing: error))")
        self.connectedPeriheral = nil
        self.writeCharacteristic = nil
        self.discoverys.removeAll()
        self.connectdErrorBlock?(.disconnected)
        //        NotificationCenter.default.post(name: .kNotificationDisconnectBLE, object: nil)
    }
}

//MARK: CBPeripheralDelegate methods
extension BLEManager: CBPeripheralDelegate{
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if let e = error{
            print("ble: did discover services error - \(e)")
            self.connectdErrorBlock?(.discoverServiceFailed)
            return
        }
        if let services = peripheral.services{
            for service in services{
                print("ble: discover services: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if let e = error{
            print("ble: did discover character error - \(e)")
            self.connectdErrorBlock?(.discoverCharacterFailed)
            return
        }
        
        if let characters = service.characteristics{
            for character in characters{
                let property = character.properties
                if property == .broadcast{
                    //如果是广播特性
                }
                if property == .read{
                    //如果具备读特性，可以读取特性的value
                    peripheral.readValue(for: character)
                }
                if property == .writeWithoutResponse{
                    //如果具备写入值不需要想要的特性
                    //这里保存这个可以写的特性，便于后面往这个特性中写数据
                    self.writeCharacteristic = character
                }
                if property == .write{
                    //如果具备写入值的特性，这个应该会有一些响应
                    self.writeCharacteristic = character
                }
                if property == [.writeWithoutResponse, .write] {
                    self.writeCharacteristic = character
                }
                if property == .notify{
                    //如果具备通知的特性，无响应
                    peripheral.setNotifyValue(true, for: character)
                }
                
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        if let e = error{
            print("ble: did update notification state error - \(e)")
            self.connectdErrorBlock?(.updateStateFailed)
            return
        }
        let property = characteristic.properties
        if property == .read{
            //如果具备读特性，即可以读取特性的value
            peripheral.readValue(for: characteristic)
        }
        if property == .write {
            print("-================")
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if let e = error{
            print("ble: did update value error - \(e)")
            self.connectdErrorBlock?(.updateValueFailed)
            return
        }
        
        if let _ = characteristic.value {
            self.connectdUpdateBlock?(characteristic)
        }
    }
}
