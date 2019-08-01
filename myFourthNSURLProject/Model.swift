//
//  Model.swift
//  myFourthNSURLProject
//
//  Created by rails on 25/07/19.
//  Copyright © 2019 rails. All rights reserved.
//

import Foundation

struct ApiResponseModelStructure: Codable{
    var resultCount: Int?
    var results: [SongModelStructure]?
}

struct SongModelStructure: Codable {
    var trackName: String?
    var artistName: String?
    var previewUrl: String?
    var songUrl: String?
    var trackId: Int?
    var price: Double?
    var image30: String?
    var image100: String?
    
    enum CodingKeys: String, CodingKey{
        case trackName
        case artistName
        case previewUrl
        case songUrl = "trackViewUrl"
        case trackId = "trackId"
        case price = "trackPrice"
        case image30 = "artworkUrl30"
        case image100 = "artworkUrl100"
    }
}
