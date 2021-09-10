//
//  TMDBAPI.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import Foundation
import ElegantAPI


enum TMDBAPI {
    static let provider = Provider<Self>()
    static let apiKey = "d6bc218c10cb73c14b35b5a648f929ed"
    case trending
}

extension TMDBAPI: API {
    var baseURL: URL {
        URL(string: "https://api.themoviedb.org/3")!
    }
    
    var path: String {
        switch self {
        case .trending:
            return "trending/all/day"
        }
    }
    
    var method: ElegantAPI.Method {
        switch self {
        case .trending:
            return .get
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .trending:
            return .requestParameters(
                parameters: ["api_key": TMDBAPI.apiKey],
                encoding: .URLEncoded
            )
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .trending:
            return nil
        }
    }
}
