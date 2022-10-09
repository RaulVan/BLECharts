//
//  Queue.swift
//  SwitfDemo
//
//  Created by JamesLi on 2020/4/22.
//  Copyright © 2020 maokebing. All rights reserved.
//

import Foundation

public struct ECG_Data {
    var i: Double
    var ii: Double
    var iii: Double
    var avr: Double
    var avl: Double
    var avf: Double
}

public struct Queue<T> {
    // 数组用来存储数据元素
    fileprivate var data = [T]()
    // 构造方法
    public init() {
        
    }
    // 构造方法，用于从序列中创建队列
    public init<S: Sequence>(_ elements: S) where
         S.Iterator.Element == T {
             data.append(contentsOf: elements)
    }
    // 将类型为T的数据元素添加到队列的末尾
    public mutating func enqueue(element: T) {
        data.append(element)
    }
    
    // 移除并返回队列中第一个元素
    // 如果队列不为空，则返回队列中第一个类型为T的元素；否则，返回nil。
    public mutating func dequeue() -> T? {
        return data.removeFirst()
    }
    
    // 返回队列中的第一个元素，但是这个元素不会从队列中删除
    // 如果队列不为空，则返回队列中第一个类型为T的元素；否则，返回nil。
    public func peek() -> T? {
        return data.first
    }
    
    
    // 清空队列中的数据元素
    public mutating func clear() {
        data.removeAll()
    }
    
    
    // 返回队列中数据元素的个数
    public var count: Int {
        return data.count
    }
    
    // 返回或者设置队列的存储空间
    public var capacity: Int {
        get {
            return data.capacity
        }
        set {
            data.reserveCapacity(newValue)
        }
    }
    
    // 检查队列是否已满
    // 如果队列已满，则返回true；否则，返回false
    public func isFull() -> Bool {
        return count == data.capacity
    }
    
    // 检查队列是否为空
    // 如果队列为空，则返回true；否则，返回false
    public func isEmpty() -> Bool {
        return data.isEmpty
    }
    
}
