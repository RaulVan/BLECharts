//
//  DashboardView.swift
//  BLECharts
//
//  Created by Eleven on 11/27/22.
//

import UIKit
import SnapKit

class DashboardView: UIView {
    
    fileprivate var labelTitle: UILabel = UILabel()
    fileprivate var labelValue: UILabel = UILabel()
    fileprivate var labelUnits: UILabel = UILabel()
    
    
    var title: String? {
        didSet {
            labelTitle.text = title
        }
    }
    
    var value: String? {
        didSet {
            labelValue.text = value
        }
    }
    
    var untis: String? {
        didSet {
            labelUnits.text = untis
        }
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonitit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonitit()
    }
    
    func commonitit() {
        
        labelValue.textAlignment = .center
        labelValue.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        labelValue.textColor = .black
        
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        labelTitle.textColor = .black
        
        labelUnits.textAlignment = .center
        labelUnits.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        labelUnits.textColor = .black
        
        addSubview(labelTitle)
        addSubview(labelValue)
        addSubview(labelUnits)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = self.width/2
        
        labelValue.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        labelTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(15)
            make.centerX.equalToSuperview()
        }
        
        labelUnits.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-15)
            make.centerX.equalToSuperview()
        }
    }
    
    
    
}
