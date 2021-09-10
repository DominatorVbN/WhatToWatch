//
//  NSCacheVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import UIKit

class NSCacheVC: ResultListVC<NSCacheViewModel> {
    
    override func loadView() {
        super.loadView()
        title = "NSCache"
    }
    
    override func showPrefrenceModal() {
        guard let prefrence: NSCachePreferences = viewModel.getprefrences() else {
            return
        }
        let style: UITableView.Style
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        } else {
            style = .grouped
        }
        let prefrencesVC = NSCachePrefrencesVC(preferences: prefrence, style: style)
        prefrencesVC.didCommit { [weak self] prefrences in
            self?.viewModel.updatePrefrences(prefrences)
            self?.reloadData()
        }
        let navigationVC = UINavigationController(rootViewController: prefrencesVC)
        self.present(navigationVC, animated: true)
    }
    
}
