//
//  ViewController.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import UIKit

class URLCacheVC: ResultList<URLCacheViewModel> {    
    
    override func loadView() {
        super.loadView()
        title = "URLCache"
    }
    
    @objc override func showPrefrenceModal() {
        guard let prefrence: URLCachePrefrences = viewModel.getprefrences() else {
            return
        }
        let style: UITableView.Style
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        } else {
            style = .grouped
        }
        let prefrencesVC = URLCachePrefrencesVC(preferences: prefrence, style: style)
        prefrencesVC.didCommit { [weak self] prefrences in
            self?.viewModel.updatePrefrences(prefrences)
            self?.reloadData()
        }
        let navigationVC = UINavigationController(rootViewController: prefrencesVC)
        self.present(navigationVC, animated: true)
    }
}
