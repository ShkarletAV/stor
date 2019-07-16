//
//  TextFieldValidator.swift
//  PoliDash
//
//  Created by Ігор on 3/11/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

enum Alert {        //for failure and success results
    case success
    case failure
    case error
}
//for success or failure of validation with alert message
enum Valid {
    case success
    case failure(Alert, AlertMessages)
}
enum ValidationType {
    case email
    case nick
    case password
    case passwordWithNumber

}
enum RegEx: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Email
    case password = "^[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]{8,30}$" // Password length 8-30
    case nick = "^[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]{4,18}$" // Nick lenght 4-18
    case passwordWithNumber = ".*[0-9]+.*"
}

enum AlertMessages: String {
    case inValidEmail = "Не корректный email-адрес"

    case inValidPasswordWithoutNumber = "Пароль должен содержать хотя бы одну цифру."
    case inValidPasswordIncorrect = "Пароль может содержать любые латинские символы, любые цифры, специальные символы"
    case inValidPasswordShort = "Пароль слишком короткий"
    case inValidPasswordLong = "Пароль слишком длинный"
    case inValidPasswordConfirm = "Пароли не совпадают"

    case inValidNickShort = "Ник слишком короткий"
    case inValidNickLong = "Ник слишком длинный"
    case inValidNickIncorrect = "Ник может содержать любые латинские символы, любые цифры, специальные символы"

    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

class Validation: NSObject {

    public static let shared = Validation()

    func checkNick(nick: String) -> String? {
        let response = Validation.shared.validate(values: (ValidationType.nick, nick))
        switch response {
        case .success:
            return nil
        case .failure(_, let message):
            var error = message
            if nick.count < 4 {
                error = AlertMessages.inValidNickShort
            } else if nick.count > 18 {
                error = AlertMessages.inValidNickLong
            }
            return error.localized()
        }
    }

    func checkPassword(password: String) -> String? {
        let response = Validation.shared.validate(values: (ValidationType.password, password), (ValidationType.passwordWithNumber, password))
        switch response {
        case .success:
            return nil
        case .failure(_, let message):
            var error = message
            if password.count < 8 {
                error = AlertMessages.inValidPasswordShort
            } else if password.count > 30 {
                error = AlertMessages.inValidPasswordLong
            }
            return error.localized()
        }
    }

    func checkEmail(email: String) -> String? {
        let response = Validation.shared.validate(values: (ValidationType.email, email))
        switch response {
        case .success:
            return nil
        case .failure(_, let message):
            return message.localized()
        }
    }

    func validate(values: (type: ValidationType, inputValue: String)...) -> Valid {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .email:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .email, .inValidEmail)) {
                    return tempValue
                }
            case .nick:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .nick, .inValidNickIncorrect)) {
                    return tempValue
                }
            case .password:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .password, .inValidPasswordIncorrect)) {
                    return tempValue
                }
            case .passwordWithNumber:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .passwordWithNumber, .inValidPasswordWithoutNumber)) {
                    return tempValue
                }
            }
        }
        return .success
    }

    func isValidString(_ input: (text: String, regex: RegEx, invalidAlert: AlertMessages)) -> Valid? {
        if isValidRegEx(input.text, input.regex) != true {
            return .failure(.error, input.invalidAlert)
        }
        return nil
    }

    func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
}
