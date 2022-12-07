//
//  PopoverViewController.swift
//  C052App
//
//  Created by Eleven on 11/25/22.
//

import UIKit

class PopoverViewController: UIViewController {
    
    var tableView: UITableView?
    
    var dataSource: [String] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    var defaultValue: String = ""
//    var accessoryType: UITableViewCell.AccessoryType = .none

    var cellTitleFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    var cellSelectionHandler: ((_ value: String, _ index: Int)->Void)?
    var cancelSelectionHandler: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(cellWithClass: UITableViewCell.self)
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    
}

extension PopoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, for: indexPath)
        let value = dataSource[indexPath.row]
        cell.textLabel?.font = cellTitleFont
        cell.textLabel?.text = value
        if value == defaultValue {
            cell.accessoryType = .checkmark
//            cell.isSelected = true
        } else {
            cell.accessoryType = .none
//            cell.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) {
            self.cancelSelectionHandler?()
        }
        let value = dataSource[indexPath.row]
        if defaultValue.count > 0 {
            defaultValue = value
            tableView.reloadData()
        }
        
        cellSelectionHandler?(value, indexPath.row)
    }
    
}

