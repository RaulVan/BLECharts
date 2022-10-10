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
