//
//  ResultListProvider.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import Foundation
import UIKit.UIImage

protocol CachePrefrenceProvider {
    var cacheType: Provider<TMDBAPI>.CacheType { get }
}

protocol ResultListProvider: AnyObject {
    associatedtype Prefrences: CachePrefrenceProvider
    var prefrences: Prefrences { get set }
    var results: [TMDBResult] { get set }
    func fetch(_ completion: @escaping () -> Void)
    func loadImage(forUrl url: URL, completion: @escaping (UIImage) -> Void)
    func updatePrefrences(_ prefrences: Prefrences)
    func getprefrences() -> Prefrences?
}

extension ResultListProvider {
    
    func updatePrefrences(_ prefrences: Prefrences) {
        self.prefrences = prefrences
    }
    
    func getprefrences() -> Prefrences? {
        return prefrences
    }
    
    func fetch(_ completion: @escaping () -> Void = {}) {
        TMDBAPI.provider.fetch(api: .trending, cacheType: prefrences.cacheType) { (result: Result<PaginatedTrendingResponse, Error>) in
            switch result {
            case .success(let response):
                self.results = response.results
            case .failure:
                self.results = []
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func loadImage(forUrl url: URL, completion: @escaping (UIImage) -> Void) {
        TMDBAPI.provider.loadImage(
            url: url,
            cacheType: prefrences.cacheType
        ) {  image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

