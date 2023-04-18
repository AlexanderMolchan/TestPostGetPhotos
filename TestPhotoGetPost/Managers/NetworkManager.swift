//
//  NetworkManager.swift
//  TestPhotoGetPost
//
//  Created by Александр Молчан on 18.04.23.
//

import Foundation
import Moya

typealias ObjectBlock<T: Decodable> = ((T) -> Void)
typealias Failure = ((Error) -> Void)

final class NetworkManager {
    let provider = MoyaProvider<ApiManager>(plugins: [NetworkLoggerPlugin()])

    func getPhotosData(page: Int = 0, success: ObjectBlock<ResponseObject>?, failure: Failure?) {
        provider.request(.getPhotos(page: page)) { result in
            switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode(ResponseObject.self, from: response.data)
                        success?(data)
                    } catch let error {
                        failure?(error)
                    }
                case .failure(let error):
                    failure?(error)
            }
        }
    }
    
    func uploadPhoto(photo: PostedPhoto, success: (() -> Void)?, failure: (() -> Void)?) {
        provider.request(.uploadPhoto(photo: photo)) { result in
            switch result {
                case .success(let responce):
                    if responce.response?.statusCode == 200 {
                        success?()
                    } else {
                        failure?()
                    }
                case .failure(_):
                    failure?()
            }
        }
    }
    
}
