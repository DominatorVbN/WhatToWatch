//
//  PaginatedTrendingResponse.swift
//  WhatToWatch
//
//  Created by Amit Samant on 06/06/21.
//

import Foundation
import UIKit
// MARK: - PaginatedTrendingResponse
struct PaginatedTrendingResponse: Codable {
    let page: Int
    let results: [TMDBResult]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - TMDBResult
struct TMDBResult: Codable {

    let posterPath: String
    let title: String?
    let mediaType: String?
    let id: Int
    let imageURL: URL?
    let overview: String

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case title = "title"
        case id = "id"
        case name = "name"
        case imageURL
        case mediaType = "media_type"
        case overview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let posterPath = try container.decode(String.self, forKey: .posterPath)
        self.posterPath = posterPath
        self.title = try (container.decodeIfPresent(String.self, forKey: .title)) ?? ( container.decodeIfPresent(String.self, forKey: .name))
        let imageURLString = "https://image.tmdb.org/t/p/w200\(posterPath)"
        self.imageURL = URL(string: imageURLString)
        self.mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)?.capitalized
        self.overview = try container.decode(String.self, forKey: .overview)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(posterPath, forKey: .posterPath)
        try container.encode(title, forKey: .title)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(overview, forKey: .overview)
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case tv = "tv"
}

enum OriginalLanguage: String, Codable {
    case en = "en"
    case it = "it"
    case no = "no"
    case th = "th"
}
