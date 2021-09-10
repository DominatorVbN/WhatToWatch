//
//  URLCacheViewModel.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import Foundation
import UIKit.UIImage

class NSCacheViewModel: ResultListProvider {
    var prefrences: NSCachePreferences = .init()
    var results: [TMDBResult] = []
}

class URLCacheViewModel: ResultListProvider {
    var prefrences: URLCachePrefrences = .init()
    var results: [TMDBResult] = []
}
