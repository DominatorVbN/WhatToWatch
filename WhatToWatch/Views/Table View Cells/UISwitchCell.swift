//
//  UISwitchCell.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//


import UIKit

class UISwitchCell: UITableViewCell {
    
    static let reuseIdentifier: String = String(describing: UISwitchCell.self)
    
    let switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(
                self,
                action: #selector(didChangeValue(sender:)),
                for: .valueChanged
            )
        return control
    }()
    
    private var didChangeValueHook: (Bool) -> Void = { _ in }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didChangeValue(sender: UISwitch) {
        didChangeValueHook(sender.isOn)
    }
    
    func didChangeValue(_ action: @escaping (Bool) -> Void) {
        self.didChangeValueHook = action
    }
    
}
