//
//  ApiManager.swift
//  TestPhotoGetPost
//
//  Created by Александр Молчан on 18.04.23.
//

import UIKit
import Moya

enum ApiManager {
    case getPhotos(page: Int)
    case uploadPhoto(photo: PostedPhoto)
}

extension ApiManager: TargetType {
    var baseURL: URL {
        URL(string: "https://junior.balinasoft.com/")!
    }
    
    var path: String {
        switch self{
            case .getPhotos:
                return "api/v2/photo/type"
            case .uploadPhoto:
                return "api/v2/photo"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getPhotos:
                return .get
            case .uploadPhoto:
                return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
            case .getPhotos:
                guard let parameters else { return .requestPlain }
                return .requestParameters(parameters: parameters, encoding: encoding)
                
            case .uploadPhoto(let photo):
                let imageData = photo.photo
                let nameData = photo.name.data(using: String.Encoding.utf8) ?? Data()
                let idData = photo.typeId.data(using: String.Encoding.utf8) ?? Data()
                let nameFormData = MultipartFormData(provider: .data(nameData), name: "name")
                let imageFormData = MultipartFormData(provider: .data(imageData), name: "photo", fileName: "test.image", mimeType: "image/png")
                let idFormData = MultipartFormData(provider: .data(idData), name: "typeId")
                
                return .uploadMultipart([nameFormData, imageFormData, idFormData])
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var parameters: [String: Any]? {
        var parameters = [String: Any]()
        switch self {
            case .getPhotos(let page):
                parameters["page"] = page
            default: return nil
        }
        return parameters
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}
