//
//  HexUtils.swift
//  BLECharts
//
//  Created by 王涵初 on 2022/10/10.
//

import UIKit

class HexUtils  {
    
    //    static func decode(hexString: String) -> String? {
    //            let bytes = hexString.uppercased()
    //            let str = BabyToy.convertHexString(to: bytes)
    //            return str
    //        }
    
    static func encode(_ hexBytes: [UInt8]) -> String {
        var outString = ""
        for val in hexBytes {
            // Prefix with 0 for values less than 16.
            if val < 16 { outString += "0" }
            outString += String(val, radix: 16)
        }
        return outString
    }
    
    
   
}



protocol UIntToBytesConvertable {
    var toBytes: [UInt8] { get }
}

extension UIntToBytesConvertable {
    func toByteArr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}

extension UInt16: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt16>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt16>.size)
        }
    }
}

extension UInt32: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt32>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt32>.size)
        }
    }
}

extension UInt64: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt64>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt64>.size)
        }
    }
}
