//
//  UIImageView+.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import UIKit.UIImageView

extension UIImageView {
    func setImage(_ url: URL?, cacheType: Provider<TMDBAPI>.CacheType = .URLCache()) {
        guard let url = url else {
            return
        }
        TMDBAPI.provider.loadImage(url: url, cacheType: cacheType) {  image in
            DispatchQueue.main.async {
                self.image = image
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
