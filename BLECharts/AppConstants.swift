//
//  AppConstants.swift
//  BLECharts
//
//  Created by Eleven on 8/20/22.
//

import UIKit
import SwifterSwift


let kScreenHeight: CGFloat = UIScreen.main.bounds.height

let kScreenWidth: CGFloat = UIScreen.main.bounds.width

let kScreenSize: CGSize = CGSize(width: kScreenWidth, height: kScreenHeight)

let kScreenRect: CGRect = UIScreen.main.bounds

//let kScreenScale: CGFloat = screenWidth / 375.0

///// fix size: width,height, fontSize
///// - Parameter value: value
///// - Returns: value
func FIX_SIZE(_ value: CGFloat) -> CGFloat {
    return  value * (kScreenWidth / 375.0)
}


let isiPad = UIDevice.current.userInterfaceIdiom == .pad

var iPhoneX: Bool {
    if UIDevice.current.userInterfaceIdiom == .phone{
        let max = kScreenWidth > kScreenHeight ? kScreenWidth : kScreenHeight
        if max >= 812 {
            return true
        }
    }
    return false
}

let kTopInset: CGFloat = iPhoneX ? 24.0 : 0.0

let kBottomInset: CGFloat = iPhoneX ? 34.0 : 0.0
let bottomInset: CGFloat = iPhoneX ? 34.0 : 0.0

let kStatusBarHeight: CGFloat = iPhoneX ? 44.0 : 20.0

let kNavigationBarHeight: CGFloat = 64.0

let kTabBarHeight: CGFloat = iPhoneX ? 83 : 49  // 44

let kLineHeight = 1/UIScreen.main.scale

let kSafeAreaTopHeight: CGFloat = iPhoneX ? 88.0 : 64.0

let kSafeAreaBottomHeight: CGFloat = iPhoneX ? 30 : 0


class AppConstants: NSObject {

}
