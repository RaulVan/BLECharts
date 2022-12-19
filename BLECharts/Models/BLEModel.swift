//
//  BLEModel.swift
//  BLECharts
//
//  Created by Eleven on 8/15/22.
//

import Foundation
import CoreBluetooth

public class BLEModel {
    
    
    public var peripheral: CBPeripheral
    public var advertisementData: [String : Any]
    public var rssi: NSNumber = 0
    
    public var name: String
    
    public var isConnect: Bool = false
    
    public init(name: String, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.name = name
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}

extension BLEModel: Equatable {
    
    public static func == (lhs: BLEModel, rhs: BLEModel) -> Bool {
        return lhs.peripheral.identifier == rhs.peripheral.identifier || lhs.name == rhs.name
    }
}
