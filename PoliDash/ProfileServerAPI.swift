//
//  ProfileServerAPI.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum ProfileServerAPI {
    case profileSignUp(nickname: String, password: String, regemail: String)
    case profileLogin(email: String, password: String)
    case profileInfo(email: String)
    case profileLogout
    case profilePhoto(photo: Data)
    case profileGetUrlPhoto(email: String)
    case profileChangeUserName(nickname: String, pwd: String)
    case profileChangePassword(pwd: String, newPwd: String)
    case profileRestorePassword(email: String)
    case profileSearchUsers(nickname: String)
    case profileFollowUp(email: String)
    case profileFamous
    case profileGetOwners(email: String)
    case profileGetFollowers(email: String)
    case profileNewFollowers
    case profileNewLikes
    case profileBalance
    case profileSetUnfollow(email: String)
    case profileNotify
    case profileActuals
    case profileCircles(email: String)
    case profilePutCircle(email: String)
    case profileDeleteCircle(owner_email: String, displayed_email: String)

    //wallet requests
    case bindingWallet(email: String, address: String)
    case сancelBindingWallet(email: String, address: String)
    case requestBindingWallet(address: String, already: Bool)
}

extension ProfileServerAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://82.202.212.125/api/v1")!
    }

    var path: String {
        switch self {
        case .profileSignUp(nickname: _, password: _, regemail: _):
            return "/profile"
        case .profileLogin(email: _, password: _):
            return "/profile/login"
        case .profileInfo(let email):
            return "/profile/\(email)"
        case .profileLogout:
            return "/profile/logout"
        case .profilePhoto(photo: _):
            return "/profile/image"
        case .profileGetUrlPhoto(let email):
            return "/profile/image/\(email)"
        case .profileChangeUserName(nickname: _, pwd: _):
            return "/profile"
        case  .profileChangePassword(pwd: _, newPwd: _):
            return "/profile/password"
        case .profileRestorePassword(email: _):
            return "/profile/restore-password"
        case .profileSearchUsers(nickname: _):
            return "/profile/search"
        case .profileFollowUp(email: _):
            return "/profile/follow-up"
        case .profileFamous:
            return "/profile/famous"
        case .profileGetOwners(email: _):
            return "/profile/get-owners"
        case .profileGetFollowers(email: _):
            return "/profile/get-followers"
        case .profileNewFollowers:
            return "/profile/notify/followers"
        case .profileSetUnfollow(email: _):
            return "/profile/unfollow"
        case .profileNotify:
            return "profile/notify"
        case .profileNewLikes:
            return "/profile/notify/likes"
        case .profileBalance:
            return "/profile/balance"
        case .profileActuals:
            return "activity"
        case .profileCircles(email: _):
            return "/profile/circles"
        case .profilePutCircle(email: _):
            return "/profile/circles"
        case .profileDeleteCircle(owner_email: _, displayed_email: _):
            return "/profile/circles"
        case .bindingWallet(email: _, address: _):
            return "wallet"
        case .сancelBindingWallet(email: _, address: _):
            return "wallet/unbind"
        case .requestBindingWallet(address: _, already: _):
            return "wallet/bind"
        }
    }
    var method: Moya.Method {
        switch self {
        case .profileSignUp(nickname: _, password: _, regemail: _):
            return .post
        case .profileLogin(email: _, password: _):
            return .get
        case .profileInfo(email: _):
            return .get
        case .profileLogout:
            return .get
        case .profilePhoto(photo: _):
            return .post
        case .profileGetUrlPhoto(email: _):
            return .get
        case .profileChangeUserName(nickname: _, pwd: _):
            return .put
        case .profileChangePassword(pwd: _, newPwd: _):
            return .put
        case .profileRestorePassword(email: _):
            return .get
        case .profileSearchUsers(nickname: _):
            return .get
        case .profileFollowUp(email: _):
            return .get
        case .profileFamous:
            return .get
        case .profileGetOwners(email: _):
            return .get
        case .profileGetFollowers(email: _):
            return .get
        case .profileNewFollowers:
            return .get
        case .profileNewLikes:
            return .get
        case .profileBalance:
            return .get
        case .profileSetUnfollow(email: _):
            return .get
        case .profileNotify:
            return .get
        case .profileActuals:
            return .get
        case .profileCircles(email: _):
            return .get
        case .profilePutCircle(email: _):
            return .put
        case .profileDeleteCircle(owner_email: _, displayed_email: _):
            return .delete
        case .bindingWallet(email: _, address: _):
            return .get
        case .сancelBindingWallet(email: _, address: _):
            return .delete
        case .requestBindingWallet:
            return .put
        }
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
            //у бэкенда возникли сложности с тем, чтобы передавать параметры в POST, поэтому они передатся именно для этого запроса через header
        case .profileSignUp(let nickname, let password, let regemail):
            return .requestParameters(parameters: ["nickname" : nickname, "password": password,  "regemail": regemail], encoding: JSONEncoding.default)
        case .profileLogin(let email, let password):
            return .requestParameters(parameters: ["email": email, "password": password], encoding: URLEncoding.default)
        case .profileInfo(email: _):
            return .requestPlain
        case .profileLogout:
            return .requestPlain
        case .profilePhoto(let data):
            let multipart = MultipartFormData.init(provider: .data(data), name: "upimage", fileName: "image.jpg", mimeType: "image/jpeg")
            return .uploadCompositeMultipart([multipart], urlParameters: [:])
        case .profileGetUrlPhoto(email: _):
            return .requestPlain
        case .profileChangeUserName(let nickname, let pwd):
            return .requestParameters(parameters: ["nickname": nickname, "pwd": pwd], encoding: JSONEncoding.default)
        case .profileChangePassword(let pwd, let newPwd):
            return .requestParameters(parameters: ["old_pwd": pwd, "new_pwd": newPwd], encoding: JSONEncoding.default)
        case .profileRestorePassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .profileSearchUsers(let nickname):
            return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.default)
        case .profileFollowUp(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .profileFamous:
            return .requestPlain
        case .profileGetOwners(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .profileGetFollowers(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .profileNewFollowers:
            return .requestPlain
        case .profileNewLikes:
            return .requestPlain
        case .profileBalance:
            return .requestPlain
        case .profileSetUnfollow(let email):
            return .requestParameters(parameters: ["email" : email], encoding: URLEncoding.default)
        case .profileNotify:
            return .requestPlain
        case .profileActuals:
            return .requestPlain
        case .profileCircles(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .profilePutCircle(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.queryString)
        case .profileDeleteCircle(let owner_email, let displayed_email):
            return .requestParameters(parameters: ["owner_email": owner_email, "displayed_email": displayed_email], encoding: URLEncoding.queryString)
        case .bindingWallet(let email, let address):
            return .requestParameters(parameters: ["email": email,
                                                   "address": address],
                                      encoding: URLEncoding.queryString)
        case .сancelBindingWallet(_,_):
            return .requestPlain
        case .requestBindingWallet(let address, _):
            return .requestParameters(parameters: ["wallet_addr": address
                                                   ],
                                      encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return nil
    }

}
