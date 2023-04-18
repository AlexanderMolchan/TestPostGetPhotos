//
//  Models.swift
//  TestPhotoGetPost
//
//  Created by Александр Молчан on 18.04.23.
//

import Foundation

struct PostedPhoto: Encodable {
    var name: String
    var photo: Data
    var typeId: String
}

struct PhotoObject: Decodable {
    var id: Int
    var name: String
    var image: String?
}

struct ResponseObject: Decodable {
    var currentPage: Int
    var totalPages: Int
    var photos: [PhotoObject]
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"
        case totalPages = "totalPages"
        case photos = "content"
    }
}

