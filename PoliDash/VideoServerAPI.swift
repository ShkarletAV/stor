//
//  VideoServerAPI.swift
//  PoliDash
//
//  Created by David Minasyan on 25.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum VideoServerAPI {
    case downloadVideo(upvideo: Data?, upimage: Data)
    case historyVideo(email: String)
    case confirmToSave(hash: String, circle: String)
    case getSympathy(hash: String)
    case getNewLikes(hash: String)
    case putLike(action: String, coordX: String, coordY: String, hash: String)
    case deleteVideo(hash: String)
    case hearts(hash: String)
}

extension VideoServerAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://212.92.98.212:8081")!
    }

    var path: String {
        switch self {
        case .downloadVideo(upvideo: _, upimage: _):
            return "/video/videochange"
        case .historyVideo(email: _):
            return "/video/history"
        case .confirmToSave:
            return "/video/confirm-to-save"//?hash=\(hash)&circle=\(circle)
        case .getSympathy(hash: _):
            return "/video/sympathyget"
        case .getNewLikes(hash: _):
            return "/video/hearts"
        case .putLike(action: _, coordX: _, coordY: _, hash: _):
            return "/video/putLike"
        case .deleteVideo(hash: _):
            return "/video/confirm-to-delete"
        case .hearts(hash: _):
            return "/video/hearts"
        }
    }

    var method: Moya.Method {
        switch self {
        case .downloadVideo(upvideo: _, upimage: _):
            return .post
        case .historyVideo(email: _):
            return .get
        case .confirmToSave(hash: _, circle: _):
            return .put
        case .getSympathy(hash: _):
            return .get
        case .getNewLikes(hash: _):
            return .get
        case .putLike(action: _, coordX: _, coordY: _, hash: _):
            return .get
        case .deleteVideo(hash: _):
            return .delete
        case .hearts(hash: _):
            return .get
        }
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .downloadVideo(let upvideo, let upimage):
            let multipartImagePrew = MultipartFormData.init(provider: .data(upimage), name: "upimage", fileName: "upimage.jpg", mimeType: "upimage/jpeg")
            if let video = upvideo {
                let multipartVideo = MultipartFormData.init(provider: .data(video), name: "upvideo", fileName: "upvideo.mp4", mimeType: "upvideo/mp4")
                 return .uploadCompositeMultipart([multipartVideo, multipartImagePrew], urlParameters: [:])
            } else {
                 return .uploadCompositeMultipart([multipartImagePrew], urlParameters: [:])
            }
        case .historyVideo(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .confirmToSave(let hash, let circle):
            return .requestParameters(parameters: ["hash": hash, "circle": circle], encoding: URLEncoding.queryString)
        case .getSympathy(let hash):
            return .requestParameters(parameters: ["hash": hash], encoding: URLEncoding.default)
        case .getNewLikes(let hash):
            return .requestParameters(parameters: ["hash": hash], encoding: URLEncoding.default)
        case .putLike(let action, let coordX, let coordY, let hash):
            return .requestParameters(parameters: ["action": action, "cx": coordX, "cy": coordY, "hash": hash], encoding: URLEncoding.default)
        case .deleteVideo(let hash):
            return .requestParameters(parameters: ["hash": hash], encoding: URLEncoding.default)
        case .hearts(let hash):
            return .requestParameters(parameters: ["hash": hash], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
