//
//  TMDBAPI.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import Foundation

import Foundation
import ElegantAPI
import Combine

import UIKit

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


class Provider<Endpoint: API> {
    
    var imageCache: Cache<URL,Data> = Cache<URL,Data>.init()

    lazy var cache: URLCache = {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent(String(describing: Self.self) + " Cache")
        let cache: URLCache
        if #available(iOS 13.0, *) {
             cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
        } else {
            cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000, diskPath: diskCacheURL.path)
        }
        return cache
    }()
    
    lazy var diskBasedCacheConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = cache
        return sessionConfiguration
    }()
    
    
    enum RequestError: Error {
        case unableToCreate
        case dataNotFound
    }
    
    enum CacheType {
        case URLCache(
                useDiskBasedCache: Bool = false,
                cachePolicy: URLRequest.CachePolicy = . useProtocolCachePolicy
             )
        case NSCache(useDiskBasedCache: Bool = false)
    }
    
    func fetch<T: Decodable>(
        api: Endpoint,
        cacheType: CacheType = .URLCache(),
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch cacheType {
        case .NSCache(let useDiskBasedCache):
            fetchFromNSCache(api: api, useDiskBasedCache: useDiskBasedCache, completion: completion)
        case let .URLCache(useDiskBasedCache, cachePolicy):
            fetch(
                api: api,
                useDiskBasedCache: useDiskBasedCache,
                cachePolicy: cachePolicy,
                completion: completion
            )
        }
    }
    
    private func fetchFromNSCache<T: Decodable>(
        api: Endpoint,
        useDiskBasedCache: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let request =  api.getURLRequest() else {
            completion(.failure(RequestError.unableToCreate))
            return
        }
        perform(request: request, completion: completion)
    }
    
    
        
    private func fetch<T: Decodable>(
        api: Endpoint,
        useDiskBasedCache: Bool = false,
        cachePolicy: URLRequest.CachePolicy = . useProtocolCachePolicy,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard var request =  api.getURLRequest() else {
            completion(.failure(RequestError.unableToCreate))
            return
        }
        request.cachePolicy = cachePolicy
        let session: URLSession
        if useDiskBasedCache {
            session = URLSession(configuration: diskBasedCacheConfiguration)
        } else {
            session = URLSession(configuration: .default)
        }
        perform(request: request, onSession: session, completion: completion)
    }
    
    private func perform<T: Decodable>(
        request: URLRequest,
        onSession session: URLSession = URLSession.shared,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        NetworkLogger.log(request: request)
        session.dataTask(with: request) { data, response, error in
            NetworkLogger.log(data: data, response: response, error: error)
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(RequestError.dataNotFound))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func loadImage(
        url: URL,
        cacheType: CacheType = .URLCache(),
        completion: @escaping (UIImage) -> Void
    ) {
        switch cacheType {
        case .NSCache(let useDiskBasedCache):
            loadImageUsingNSCache(
                url: url,
                useDiskBasedCache: useDiskBasedCache,
                completion: completion
            )
        case let .URLCache(useDiskBasedCache, cachePolicy):
            loadImageUsingURLCache(
                url: url,
                useDiskBasedCache: useDiskBasedCache,
                cachePolicy: cachePolicy,
                completion: completion
            )
        }
    }
    
    private func loadImageUsingNSCache(
        url: URL,
        useDiskBasedCache: Bool = false,
        completion: @escaping (UIImage) -> Void
    ) {
        if useDiskBasedCache,
           let diskPersistedCache: Cache<URL,Data> = try? .getFromDisk(withName: "imageCache") {
            imageCache = diskPersistedCache
        }
        if let cachedData = imageCache.value(forKey: url),
           let image = UIImage(data: cachedData) {
            completion(image)
        } else {
            URLSession(configuration: .default).dataTask(with: url) { data, _, error in
                if let error = error {
                    debugPrint(error)
                    return
                }
                guard let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                self.imageCache.insert(data, forKey: url)
                if useDiskBasedCache {
                    try? self.imageCache.saveToDisk(withName: "imageCache")
                }
                completion(image)
            }.resume()
        }
    }
    
    func loadImageUsingURLCache(
        url: URL,
        useDiskBasedCache: Bool = false,
        cachePolicy: URLRequest.CachePolicy = . useProtocolCachePolicy,
        completion: @escaping (UIImage) -> Void
    ) {
        let request =  URLRequest(url: url, cachePolicy: cachePolicy)
        let session: URLSession
        if useDiskBasedCache {
            session = URLSession(configuration: diskBasedCacheConfiguration)
        } else {
            session = URLSession(configuration: .default)
        }
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                debugPrint(error)
                return
            }
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            completion(image)
        }.resume()
    }
}



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
