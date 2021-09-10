//
//  TMDBProvider.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import Foundation
import ElegantAPI
import UIKit.UIImage

class Provider<Endpoint: API> {
    
    private lazy var imageCache: Cache<URL,Data> = Cache<URL,Data>.init()
    private lazy var cache: URLCache = createURLCache()
    private lazy var diskBasedCacheConfiguration: URLSessionConfiguration = {
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
}

private extension Provider where Endpoint: API {
    
    func createURLCache() -> URLCache {
        
        let cachesURL = FileManager.default.urls(
            for: .cachesDirectory,
               in: .userDomainMask
        )[0]
        
        let diskCacheURL = cachesURL.appendingPathComponent(
            String(describing: Self.self) + " Cache"
        )
        
        let cache: URLCache
        if #available(iOS 13.0, *) {
             cache = URLCache(
                memoryCapacity: 100_000_000,
                diskCapacity: 1_000_000_000,
                directory: diskCacheURL
             )
        } else {
            cache = URLCache(
                memoryCapacity: 100_000_000,
                diskCapacity: 1_000_000_000,
                diskPath: diskCacheURL.path
            )
        }
        return cache
    }
    
    func fetchFromNSCache<T: Decodable>(
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
    
    func fetch<T: Decodable>(
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
    
    func loadImageUsingNSCache(
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
