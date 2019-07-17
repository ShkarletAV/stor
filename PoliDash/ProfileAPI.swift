//
//  ProfileAPI.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import Moya
import Moya_ObjectMapper
import RxSwift
import ObjectMapper
import Alamofire

class ProfileAPI {
    
    // MARK: - Регистрация нового аккаунта
    static func requestSignUp(delegate: AppDelegate, regemail: String,
                              nickname: String,
                              password pass: String, callback  : @escaping (_ msg_RequestSignUP: MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileSignUp(
            nickname: nickname,
            password: pass,
            regemail: regemail)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
                
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.code = 500
                    msg.msg = "Неизвестная ошибка"
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 500
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted requestSignUp")
            }) {
                print("onDisposed requestSignUp")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Авторизация
    static func requestLogin(delegate: AppDelegate,
                             email: String,
                             password: String,
                             callback  : @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileLogin(email: email,
                                                          password: password))
            .mapObject(MessageModel.self)
            .asObservable()
            .subscribe(onNext: { (responce) in
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.msg = "Неизвестная ошибка"
                    msg.code = 500
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 500
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted requestLogin")
            }) {
                print("onDisposed requestLogin")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить информацию профиля
    static func requestProfileInfo(delegate: AppDelegate, email: String, callback: @escaping(UserInfoModel) -> Void) {
        delegate.providerProfile.rx.request(.profileInfo(email: email)).mapObject(UserInfoModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let info = UserInfoModel()
                info.code = 500
                info.msg = "Неизвестная ошибка"
                callback(info)
                return
            }
        }, onError: { (error) in
            let info = UserInfoModel()
            info.code = 500
            if let e = error as? MoyaError {
                info.msg = e.localizedDescription
            } else {
                info.msg = error.localizedDescription
            }
            callback(info)
            return
        }, onCompleted: {
            print("onCompleted requestProfileInfo")
        }) {
            print("onDisposed requestProfileInfo")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Запросить выход из аккаунта
    static func requestLogout(delegate: AppDelegate, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileLogout).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.code = 500
                msg.msg = "Неизвестная ошибка"
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestLogout")
        }) {
            print("onDisposed requestLogout")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Установить фото профиля
    static func requestSetImageProfile(delegate: AppDelegate, data: Data, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profilePhoto(photo: data)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.code = 500
                msg.msg = "Неизвестная ошибка"
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted SetImageProfile")
        }) {
            print("onDisposed SetImageProfile")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить Url фото профиля
    static func requestGetUrlPhotoProfile(delegate: AppDelegate, email: String, callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileGetUrlPhoto(email: email)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 500
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestGetUrlPhotoProfile")
        }) {
            print("onDisposed requestGetUrlPhotoProfile")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Изменить Имя Фамилия
    static func requsetChangeUserName(delegate: AppDelegate, nickname: String, pass: String, callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileChangeUserName(nickname: nickname, pwd: pass)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requsetChangeUserName")
        }) {
            print("onDisposed requsetChangeUserName")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Изменить пароль
    static func requestChangePassword(delegate: AppDelegate, newPwd: String, oldPwd: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileChangePassword(pwd: oldPwd, newPwd: newPwd)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestChangePassword")
        }) {
            print("onDisposed requestChangePassword")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Восстановить пароль
    static func requestResorePassword(delegate: AppDelegate, email: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileRestorePassword(email: email)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestResorePassword")
        }) {
            print("onDisposed requestResorePassword")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Search Users
    static func requestSearchUsers(delegate: AppDelegate, nickName: String, callback  : @escaping (String?, Int, [UsersModel]) -> Void ) {
        delegate.providerProfile.rx.request(.profileSearchUsers(nickname: nickName)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [UsersModel] = []
                    if let object = Mapper<UsersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [UsersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [UsersModel]())
            } else {
                callback(error.localizedDescription, 400, [UsersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestSerchUsers")
        }) {
            print("onDisposed requestSerchUsers")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Request Famous
    static func requestFamous(delegate: AppDelegate, callback: @escaping (String?, Int, [UsersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileFamous).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [UsersModel] = []
                    if let object = Mapper<UsersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [UsersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [UsersModel]())
            } else {
                callback(error.localizedDescription, 400, [UsersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestFamous ")
        }) {
            print("onDisposed requestFamous")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Request Follow-UP
    static func requestFollowUp(delegate: AppDelegate, email: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileFollowUp(email: email)).asObservable().mapObject(MessageModel.self).subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestFollowUp")
        }) {
            print("onDisposed requestFollowUp")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Поличить список подписок пользователя
    static func requestGetOwners(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [OwnersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileGetOwners(email: email)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [OwnersModel] = []
                    if let object = Mapper<OwnersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [OwnersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [OwnersModel]())
            } else {
                callback(error.localizedDescription, 400, [OwnersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestGetOwners")
        }) {
            print("onDisposed requestGetOwners")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить подписчиков пользователя
    static func requestGetFollowers(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [OwnersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileGetFollowers(email: email)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [OwnersModel] = []
                    if let object = Mapper<OwnersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [OwnersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [OwnersModel]())
            } else {
                callback(error.localizedDescription, 400, [OwnersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestGetFollowers")
        }) {
            print("onDisposed requestGetFollowers")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить новых подписчиков пользователя
    static func requestNewFollowers(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [OwnersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileNewFollowers).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [OwnersModel] = []
                    if let object = Mapper<OwnersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [OwnersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [OwnersModel]())
            } else {
                callback(error.localizedDescription, 400, [OwnersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestNewFollowers")
        }) {
            print("onDisposed requestNewFollowers")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить новые лайки пользователя
    static func requestNewLikes(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [HistoryVideo]) -> Void) {
        delegate.providerProfile.rx.request(.profileNewLikes).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [HistoryVideo] = []
                    if let object = Mapper<LikesNotificationMessage>().map(JSONString: strData),
                        let msg = object.msg {
                        uModel = msg
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [HistoryVideo]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [HistoryVideo]())
            } else {
                callback(error.localizedDescription, 400, [HistoryVideo]())
            }
        }, onCompleted: {
            print("onCompleted requestNewLikes")
        }) {
            print("onDisposed requestNewLikes")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить баланс пользователя
    static func requestBalance(delegate: AppDelegate, callback: @escaping (Balance) -> Void) {
        delegate.providerProfile.rx.request(.profileBalance).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : Balance?
                    if let object = Mapper<Balance>().map(JSONString: strData) {
                        uModel = object
                    }
                    callback(uModel!)
                    return
                }
            }
            callback(Balance())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(Balance())
            } else {
                callback(Balance())
            }
        }, onCompleted: {
            print("onCompleted requestNewLikes")
        }) {
            print("onDisposed requestNewLikes")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить актуальные видео
    static func requestActuals(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [OwnersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileGetFollowers(email: email)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [OwnersModel] = []
                    if let object = Mapper<OwnersModel>().mapArray(JSONString: strData) {
                        uModel = object
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description, responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description, responce.statusCode, [OwnersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription, 400, [OwnersModel]())
            } else {
                callback(error.localizedDescription, 400, [OwnersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestGetFollowers")
        }) {
            print("onDisposed requestGetFollowers")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Отписаться от пользователя
    static func requestSetUnFollow(delegate: AppDelegate, email: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profileSetUnfollow(email: email)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestSetUnFollow")
        }) {
            print("onDisposed requestSetUnFollow")
            }.disposed(by: delegate.disposeBag)
    }
    
    //
    static func requsetNotificationStatus(delegate: AppDelegate, callback: @escaping (NotificationModel) -> Void) {
        delegate.providerProfile.rx.request(ProfileServerAPI.profileNotify).mapObject(NotificationModel.self).asObservable().subscribe(onNext: { (model) in
            if model.code != nil {
                callback(model)
                return
            } else {
                let msg = NotificationModel()
                msg.msg = false
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (_) in
            let msg = NotificationModel()
            msg.code = 400
            msg.msg = false
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requestSetUnFollow")
        }) {
            print("onDisposed requestSetUnFollow")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Получить пользователей в кружках
    static func requestCircles(delegate: AppDelegate, email: String, callback: @escaping (String?, Int, [OwnersModel]) -> Void) {
        delegate.providerProfile.rx.request(.profileCircles(email: email)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    var uModel : [OwnersModel] = []
                    if let object = Mapper<CircleResponse>().map(JSONString: strData),
                        let circles = object.circles {
                        uModel = circles
                    }
                    if uModel.isEmpty {
                        callback(nil, 100, uModel)
                    } else {
                        callback(responce.description,
                                 responce.statusCode, uModel)
                    }
                    return
                }
            }
            callback(responce.description,
                     responce.statusCode,
                     [OwnersModel]())
        }, onError: { (error) in
            if let e = error as? MoyaError {
                callback(e.localizedDescription,
                         400,
                         [OwnersModel]())
            } else {
                callback(error.localizedDescription,
                         400,
                         [OwnersModel]())
            }
        }, onCompleted: {
            print("onCompleted requestNewFollowers")
        }) {
            print("onDisposed requestNewFollowers")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Сохранить пользователя в кругу
    static func requsetPutCircle(delegate: AppDelegate, email: String, callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(.profilePutCircle(email: email)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.msg = "Неизвестная ошибка"
                msg.code = 400
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 400
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted requsetChangeUserName")
        }) {
            print("onDisposed requsetChangeUserName")
            }.disposed(by: delegate.disposeBag)
    }
    
    // MARK: - Удалить пользователя с круга
    static func requestDeleteCircle(delegate: AppDelegate,
                                    ownerEmail: String,
                                    displayiedEmail: String,
                                    callback:  @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(
            .profileDeleteCircle(
                ownerEmail: ownerEmail,
                displayedEmail:displayiedEmail))
            .mapObject(MessageModel.self)
            .asObservable()
            .subscribe(onNext: { (responce) in
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.msg = "Неизвестная ошибка"
                    msg.code = 400
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 400
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted requsetChangeUserName")
            }) {
                print("onDisposed requsetChangeUserName")
            }.disposed(by: delegate.disposeBag)
    }
    
    static func bindingWallet(delegate: AppDelegate,
                              email: String,
                              address: String,
                              callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(
            .bindingWallet(email: email,
                           address: address))
            .mapObject(MessageModel.self)
            .asObservable()
            .subscribe(onNext: { (responce) in
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.msg = "Неизвестная ошибка"
                    msg.code = 400
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 400
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted bindingWallet")
            }) {
                print("onDisposed bindingWallet")
            }.disposed(by: delegate.disposeBag)
    }
    
    static func cancelBindingWallet(delegate: AppDelegate,
                                    email: String,
                                    address: String,
                                    callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(
            .bindingWallet(email: email,
                           address: address))
            .mapObject(MessageModel.self)
            .asObservable()
            .subscribe(onNext: { (responce) in
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.msg = "Неизвестная ошибка"
                    msg.code = 400
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 400
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted cancelBindingWallet")
            }) {
                print("onDisposed cancelBindingWallet")
            }.disposed(by: delegate.disposeBag)
    }
    
    static func requestBindingWallet(delegate: AppDelegate,
                                     address: String,
                                     callback: @escaping(MessageModel) -> Void) {
        delegate.providerProfile.rx.request(
            .requestBindingWallet(address: address))
            .mapObject(MessageModel.self)
            .asObservable()
            .subscribe(onNext: { (responce) in
                if responce.code != nil {
                    callback(responce)
                    return
                } else {
                    let msg = MessageModel()
                    msg.msg = "Неизвестная ошибка"
                    msg.code = 400
                    callback(msg)
                    return
                }
            }, onError: { (error) in
                let msg = MessageModel()
                msg.code = 400
                if let e = error as? MoyaError {
                    msg.msg = e.localizedDescription
                } else {
                    msg.msg = error.localizedDescription
                }
                callback(msg)
                return
            }, onCompleted: {
                print("onCompleted requestBindingWallet")
            }) {
                print("onDisposed requestBindingWallet")
            }.disposed(by: delegate.disposeBag)
    }
}
