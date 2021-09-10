//
//  TextDetailVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import UIKit

class TextDetailVC: UIViewController {
    
    private let text: String
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .medium)
        label.text = text
        label.numberOfLines = 0
        return label
    }()
    
    let scrollView = UIScrollView()
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: scrollView.readableContentGuide.topAnchor),
            textLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
        ])
    }
}
