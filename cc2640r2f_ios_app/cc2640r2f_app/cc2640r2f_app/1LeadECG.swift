//
//  1LeadECG.swift
//  cc2640r2f_app
//
//  Created by JamesLi on 2020/4/27.
//  Copyright © 2020 JamesLi. All rights reserved.
//

import UIKit

public class Draw1GridView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func draw(_ rect: CGRect) {
        let lineHorPath = UIBezierPath.init()
        
        UIColor.lightGray.setStroke()
        lineHorPath.lineWidth = 0.4
        let BigGrid = 25
        let LittleGrid = 5
        for i in 0...7 {
            lineHorPath.move(to: CGPoint.init(x: 0, y: i*BigGrid))
            lineHorPath.addLine(to: CGPoint.init(x: 390, y: i*BigGrid))
        }
        for i in 0...20 {
            lineHorPath.move(to: CGPoint.init(x: i*BigGrid, y: 0))
            lineHorPath.addLine(to: CGPoint.init(x: i*BigGrid, y: 200))
        }
        lineHorPath.stroke()
        lineHorPath.lineWidth = 0.1
        for i in 0...50 {
            lineHorPath.move(to: CGPoint.init(x: 0, y: i*LittleGrid))
            lineHorPath.addLine(to: CGPoint.init(x: 390, y: i*LittleGrid))
        }
        for i in 0...100 {
            lineHorPath.move(to: CGPoint.init(x: i*LittleGrid, y: 0))
            lineHorPath.addLine(to: CGPoint.init(x: i*LittleGrid, y: 200))
        }
        lineHorPath.stroke()
    }
}

public class Draw1CurveView: UIView {
    var erase: Int = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var points:Array<CGPoint>  = []{
        didSet{
            //触发重新绘制
            setNeedsDisplay()
        }
    }
    
    public func setFlg(val: Int) {
        erase = val
    }
    
    public override func draw(_ rect: CGRect) {
        //使用贝瑟尔更简单绘制线
        //先绘制一个背景 rect 为当前view 的大小位置
        var bezierPath = UIBezierPath.init(rect: rect)
        if points.count < 1 {
            return
        }
        //绘制网格
        
        //画线，拿传过来的数据画点线
        bezierPath = UIBezierPath.init()
        bezierPath.lineWidth = 0.7
        UIColor.black.setStroke();
        //移动到第一个点
        let p1 = points.first!
        bezierPath.move(to: p1)
        for index in 0...points.count-1 {
            bezierPath.addLine(to: points[index])
            
        }
        var ferase: CGFloat
        ferase = CGFloat(erase)*0.2
        
        bezierPath.move(to: CGPoint.init(x: ferase, y: 0))
        bezierPath.addLine(to: CGPoint.init(x: ferase, y: 200))
        bezierPath.stroke()
    }
}

public class DrawSingleView : UIView {
    private var gridView:Draw1GridView?
    public var curveView:Draw1CurveView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gridView = Draw1GridView(frame: self.bounds);
        curveView = Draw1CurveView(frame: self.bounds);
        addSubview(gridView!)
        addSubview(curveView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var points:Array<CGPoint> {
        get {
            return curveView!.points
        }
        set {
            curveView!.points = newValue
        }
    }
}

