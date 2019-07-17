//
//  AppDelegate.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let disposeBag = DisposeBag()

    // MARK: - Providers
    let providerProfile = MoyaProvider<ProfileServerAPI>(
        plugins: [NetworkLoggerPlugin(verbose: true, cURL: false)])
    let providerVideo = MoyaProvider<VideoServerAPI>(
        plugins: [NetworkLoggerPlugin(verbose: true, cURL: false)])

    var profileInfo = UserInfoModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if !DEBUG
            Fabric.with([Crashlytics.self])
        #endif

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

}
