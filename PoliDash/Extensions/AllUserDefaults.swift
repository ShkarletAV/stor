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
        if let val = UserDefaults.standard.value(forKey: KeysUD.keyLogin.rawValue) as? String {
            return val
        } else {
            return nil
        }
    }

    static func getPasswordUD() -> String? {
        if let val = UserDefaults.standard.value(forKey: KeysUD.keyPass.rawValue) as? String {
            return val
        } else {
            return nil
        }
    }

    static func saveLoginInUD(login: String) {
        UserDefaults.standard.set(login, forKey: KeysUD.keyLogin.rawValue)
    }

    static func savePasswordInUD(password: String) {
        UserDefaults.standard.set(password, forKey: KeysUD.keyPass.rawValue)
    }

    static func removePasswordUD() {
        UserDefaults.standard.removeObject(forKey: KeysUD.keyPass.rawValue)
    }

    static func removeLoginUD() {
        UserDefaults.standard.removeObject(forKey: KeysUD.keyLogin.rawValue)
    }

    static func getOpenUD() -> Bool? {
        return UserDefaults.standard.bool(forKey: KeysUD.keyOpened.rawValue)
    }

    static func saveOpenUD() {
        UserDefaults.standard.set(true, forKey: KeysUD.keyOpened.rawValue)
    }

}
