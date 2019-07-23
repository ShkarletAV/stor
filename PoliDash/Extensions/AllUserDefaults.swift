//
//  AllUserDefaults.swift
//  PoliDash
//
//  Created by David Minasyan on 23.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import UIKit

class AllUserDefaults {
    static func getLoginUD() -> String? {
        if let val = UserDefaults.standard.value(forKey: UserDefaultKeys.login.rawValue) as? String {
            return val
        } else {
            return nil
        }
    }
    
    static var mainTutorialWasShow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.showMainTutorial.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.showMainTutorial.rawValue)
        }
    }

    static func getPasswordUD() -> String? {
        if let val = UserDefaults.standard.value(forKey: UserDefaultKeys.password.rawValue) as? String {
            return val
        } else {
            return nil
        }
    }

    static func saveLoginInUD(login: String) {
        UserDefaults.standard.set(login, forKey: UserDefaultKeys.login.rawValue)
    }

    static func savePasswordInUD(password: String) {
        UserDefaults.standard.set(password, forKey: UserDefaultKeys.password.rawValue)
    }

    static func removePasswordUD() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.password.rawValue)
    }

    static func removeLoginUD() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.login.rawValue)
    }

    static func getOpenUD() -> Bool? {
        return UserDefaults.standard.bool(forKey: UserDefaultKeys.opened.rawValue)
    }

    static func saveOpenUD() {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.opened.rawValue)
    }

}
