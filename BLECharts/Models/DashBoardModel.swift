//
//  DashBoardModel.swift
//  BLECharts
//
//  Created by Eleven on 12/19/22.
//

import UIKit

enum DashBoardType {
    case hr // 心率
    case bp //血压
    case ph
    case ua
    case none
}

struct DashBoardData {
    var valueHR: Int
    var valueBP: Int
    var valuePH: Int
    var valueUA: Int
}


