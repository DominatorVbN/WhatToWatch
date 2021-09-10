//
//  NSCachePreferences.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/09/21.
//

import Foundation

struct NSCachePreferences: Equatable, CachePrefrenceProvider {
    var shouldUsediskBasedCache = false
    var cacheType: Provider<TMDBAPI>.CacheType {
        return .NSCache(useDiskBasedCache: shouldUsediskBasedCache)
    }
}
