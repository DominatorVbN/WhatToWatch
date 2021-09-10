//
//  URLCachePrefrences.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import Foundation

struct URLCachePrefrences: Equatable, CachePrefrenceProvider {
    var selectedPolicyIndex = 0
    var selectedPolicy: URLRequest.CachePolicy {
        URLRequest.CachePolicy.allCases[selectedPolicyIndex]
    }
    var shouldUsediskBasedCache = false
    var cacheType: Provider<TMDBAPI>.CacheType {
        return .URLCache(useDiskBasedCache: shouldUsediskBasedCache, cachePolicy: URLRequest.CachePolicy.allCases[selectedPolicyIndex])
    }
}
