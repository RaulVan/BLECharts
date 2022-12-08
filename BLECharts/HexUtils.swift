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

extension String {
    /// 十六进制字符串转换成 Data
    var hexData: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    var hexToDecimal: Int {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
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


extension Data {
    public func subdata(in range: CountableClosedRange<Data.Index>) -> Data {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
}
