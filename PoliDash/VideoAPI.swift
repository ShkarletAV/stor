//
//  Video_API.swift
//  PoliDash
//
//  Created by David Minasyan on 25.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import Moya
import Moya_ObjectMapper
import RxSwift
import ObjectMapper
import Alamofire

class VideoAPI {
    // MARK: - Загрузка видео истории

    static func downloadVideoWithProgress(delegate: AppDelegate, video: Data?, image: Data, callback: @escaping (MessageVideoProgress) -> Void) {

        delegate.providerVideo.rx.requestWithProgress(.downloadVideo(upvideo: video, upimage: image)).asObservable().subscribe(onNext: { (responce) in
            if responce.progressObject != nil {
                let msg = MessageVideoProgress()
                msg.progress = responce.progressObject
                callback(msg)
                return
            } else {
                let msg = MessageVideoProgress()
                msg.msg = "Неизвестная ошибка"
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageVideoProgress()
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            NotificationCenter.default.post(name: NSNotification.Name("UPLOADING_PROGRESS_DID_END"), object: nil, userInfo: nil)
            print("onCompleted downloadVideo")
        }) {
            print("onDisposed downloadVideo")
            }.disposed(by: delegate.disposeBag)
    }

    static func downloadVideo(delegate: AppDelegate, video: Data?, image: Data, callback: @escaping (MessageVideoModel) -> Void) {

        delegate.providerVideo.rx.request(.downloadVideo(upvideo: video, upimage: image)).mapObject(MessageVideoModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageVideoModel()
                msg.code = 500
                msg.msg = "Неизвестная ошибка"
                callback(msg)
                return
            }
        }, onError: { (error) in
            let msg = MessageVideoModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(msg)
            return
        }, onCompleted: {
            print("onCompleted downloadVideo")
        }) {
            print("onDisposed downloadVideo")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - Запросить истории пользователя
    static func requestHistory(delegate: AppDelegate, email: String, callback: @escaping (HistorysVideoModel) -> Void) {
        delegate.providerVideo.rx.request(.historyVideo(email: email)).asObservable().subscribe(onNext: { (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    if let h = Mapper<HistorysVideoModel>().map(JSONString: strData) {
                        h.statusCode = responce.statusCode
                        callback(h)
                        return
                    }
                }
            }
            let h = HistorysVideoModel()
            h.error = responce.description
            h.statusCode = responce.statusCode
            callback(h)
            return
        }, onError: { (error) in
            let h = HistorysVideoModel()
            h.statusCode = 400
            if let e = error as? MoyaError {
                h.error = e.localizedDescription
            } else {
                h.error = error.localizedDescription
            }
            callback(h)
            return
        }, onCompleted: {
            print("onCompleted requestHistory")
        }) {
            print("onDisposed requestHistory")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - Запросить сохранение видео в актуальное
    static func requestConfirmToSave(delegate: AppDelegate, hash: String, circle: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerVideo.rx.request(.confirmToSave(hash: hash, circle: circle)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
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
            print("onCompleted requestConfirmToSave")
        }) {
            print("onDisposed requestConfirmToSave")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - Получить координаты лайков
    static func requestGetLikes(delegate: AppDelegate, hash: String, callback: @escaping (SympathyModel) -> Void) {
        delegate.providerVideo.rx.request(.getLikes(hash: hash)).asObservable().subscribe(onNext: {  (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    if let h = Mapper<SympathyModel>().map(JSONString: strData) {
                        callback(h)
                        return
                    }
                }
            }
            callback(SympathyModel())
            return
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(SympathyModel())
            return
        }, onCompleted: {
            print("onCompleted requestGetSympathy")
        }) {
            print("onDisposed requestGetSympathy")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - Получить координаты лайков
    static func requestGetNewSympathy(delegate: AppDelegate, hash: String, callback: @escaping (SympathyModel) -> Void) {
        delegate.providerVideo.rx.request(.getNewLikes(hash: hash)).asObservable().subscribe(onNext: {  (responce) in
            if responce.statusCode >= 200 && responce.statusCode < 300 {
                let dataResoponse = responce.data
                if let strData = String(data: dataResoponse, encoding: String.Encoding.utf8) {
                    if let h = Mapper<SympathyModel>().map(JSONString: strData) {
                        callback(h)
                        return
                    }
                }
            }
            callback(SympathyModel())
            return
        }, onError: { (error) in
            let msg = MessageModel()
            msg.code = 500
            if let e = error as? MoyaError {
                msg.msg = e.localizedDescription
            } else {
                msg.msg = error.localizedDescription
            }
            callback(SympathyModel())
            return
        }, onCompleted: {
            print("onCompleted requestGetSympathy")
        }) {
            print("onDisposed requestGetSympathy")
            }.disposed(by: delegate.disposeBag)
    }

// MARK: - отправить координаты лайка на сервер
    static func requestPutSympathy(delegate: AppDelegate, hash: String, action: Sympathy, cx: String, cy: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerVideo.rx.request(.putLike(action: action.value, coordX: cx, coordY: cy, hash: hash)).asObservable().mapObject(MessageModel.self).subscribe(onNext: { (responce) in
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
            print("onCompleted requestPutSympathy")
        }) {
            print("onDisposed requestPutSympathy")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - удалить видео
    static func requestDeleteVideo(delegate: AppDelegate, hash: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerVideo.rx.request(.deleteVideo(hash: hash)).mapObject(MessageModel.self).asObservable().subscribe(onNext: { (responce) in
            if responce.code != nil {
                callback(responce)
                return
            } else {
                let msg = MessageModel()
                msg.code = 400
                msg.msg = "Неизвестная ошибка"
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
            print("onCompleted requestDeleteVideo")
        }) {
            print("onDisposed requestDeleteVideo")
        }.disposed(by: delegate.disposeBag)
    }

    // MARK: - добавить скрытые лайки
    static func requestLikesVideo(delegate: AppDelegate, hash: String, callback: @escaping (MessageModel) -> Void) {
        delegate.providerVideo.rx.request(.hearts(hash: hash)).asObservable().subscribe(onNext: { (_) in

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
            print("onCompleted requestDeleteVideo")
        }) {
            print("onDisposed requestDeleteVideo")
            }.disposed(by: delegate.disposeBag)
    }

    //получить скрытые лайки
}
