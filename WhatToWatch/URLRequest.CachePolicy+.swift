//
//  URLRequest.CachePolicy+.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import Foundation

extension URLRequest.CachePolicy: CaseIterable {
    public static var allCases: [NSURLRequest.CachePolicy] = [
        .useProtocolCachePolicy,
        .returnCacheDataElseLoad,
        .returnCacheDataDontLoad,
        .reloadRevalidatingCacheData,
        .reloadIgnoringLocalCacheData,
        .reloadIgnoringLocalAndRemoteCacheData,
    ]
    
    var title: String {
        switch self {
        case .useProtocolCachePolicy:
            return "useProtocolCachePolicy"
        case .returnCacheDataElseLoad:
            return "returnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            return "returnCacheDataDontLoad"
        case .reloadRevalidatingCacheData:
            return "reloadRevalidatingCacheData"
        case .reloadIgnoringLocalCacheData:
            return "reloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "reloadIgnoringLocalAndRemoteCacheData"
        default:
            return String(describing: self)
        }
    }
    
    var info: String {
        switch self {
        case .useProtocolCachePolicy:
            return "Use the caching logic defined in the protocol implementation, if any, for a particular URL load request."
        case .returnCacheDataElseLoad:
            return "Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data."
        case .returnCacheDataDontLoad:
            return "Use existing cache data, regardless or age or expiration date, and fail if no cached data is available.\n\nIf there is no existing data in the cache corresponding to a URL load request, no attempt is made to load the data from the originating source, and the load is considered to have failed. This constant specifies a behavior that is similar to an “offline” mode."
        case .reloadRevalidatingCacheData:
            return "Use cache data if the origin source can validate it; otherwise, load from the origin.\n\nVersions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant."
        case .reloadIgnoringLocalCacheData:
            return "The URL load should be loaded only from the originating source.\nThis policy specifies that no existing cache data should be used to satisfy a URL load request."
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "Ignore local cache data, and instruct proxies and other intermediates to disregard their caches so far as the protocol allows."
        default:
            return String(describing: self)
        }
    }
    
}
