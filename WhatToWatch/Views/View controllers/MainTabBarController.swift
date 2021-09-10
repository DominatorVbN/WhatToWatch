//
//  MainTabBarController.swift
//  WhatToWatch
//
//  Created by Amit Samant on 11/09/21.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func loadView() {
        super.loadView()
        let urlCacheViewModel = URLCacheViewModel()
        let urlCacheVC = URLCacheVC(viewModel: urlCacheViewModel)
        let urlCacheNavVC = UINavigationController(rootViewController: urlCacheVC)
        urlCacheNavVC.navigationBar.prefersLargeTitles = true
        urlCacheNavVC.tabBarItem = .init(
            title: "URL Cache",
            image: UIImage(named: "network"),
            tag: 0
        )
        let nsCacheViewModel = NSCacheViewModel()
        let nsCacheVC = NSCacheVC(viewModel: nsCacheViewModel)
        let nsCacheNavVC = UINavigationController(rootViewController: nsCacheVC)
        nsCacheNavVC.navigationBar.prefersLargeTitles = true
        nsCacheNavVC.tabBarItem = .init(
            title: "NS Cache",
            image: UIImage(named: "externaldrive"),
            tag: 0
        )
        viewControllers = [nsCacheNavVC, urlCacheNavVC]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
