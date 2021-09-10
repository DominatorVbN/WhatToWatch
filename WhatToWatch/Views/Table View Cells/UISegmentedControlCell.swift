//
//  UISegmentedControlCell.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import UIKit

class UISegmentedControlCell: UITableViewCell {
    
    
    static let reuseIdentifier: String = String(describing: UISegmentedControlCell.self)
    
    var items: [String] = [] {
        didSet {
            updateAccessoryView()
        }
    }
    
    var segmentControl: UISegmentedControl!
    
    private var didChangeValueHook: (Int) -> Void = { _ in }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        updateAccessoryView()
    }
    
    func createSegment() -> UISegmentedControl {
        let control = UISegmentedControl(items: items)
        control.addTarget(
                self,
                action: #selector(didChangeValue(sender:)),
                for: .valueChanged
            )
        return control
    }
    
    func updateAccessoryView() {
        segmentControl = createSegment()
        accessoryView = segmentControl
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didChangeValue(sender: UISegmentedControl) {
        didChangeValueHook(sender.selectedSegmentIndex)
    }
    
    func didChangeValue(_ action: @escaping (_ selectedIndex: Int) -> Void) {
        self.didChangeValueHook = action
    }
    
}
