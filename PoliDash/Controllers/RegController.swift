//
//  RegController.swift
//  PoliDash
//
//  Created by Ігор on 3/1/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import RxSwift

class RegController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!          //Кнопка регистрации
    @IBOutlet weak var emailCodeTField: UITextField!   // поле ввода мейла
    @IBOutlet weak var nameTField: UITextField!         // поле ввода никнейма
    @IBOutlet weak var passwordTField: UITextField!     // поле ввода пароля
    @IBOutlet weak var password1TField: UITextField!    // поле ввода подтверждения пароля
    @IBOutlet weak var seeBtn: UIButton!                 // кнопка "Показать пароль"
    @IBOutlet weak var errorLabel: UILabel!              // информационная метка

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()

    // MARK: - Request SignUP
    var msgRequestSignUP = Variable<MessageModel>(MessageModel())

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeProfile()
        settingsKeyboard()

        //добавляем функцию отслеживание изменения пароля
        self.passwordTField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        setFields()
        if let login = AllUserDefaults.getLoginUD(), let pass = AllUserDefaults.getPasswordUD() {
            emailCodeTField.text = login
            passwordTField.text = pass
            isPressDone()
        }
    }

    //устанавливаем отобржение полей на фоме (поля регистрации или авторизации)
    func setFields() {
        dismissKeyboard()
            //удаляем заданные значения в полях
            clearFields()
    }

    func clearFields() {
        self.errorLabel.text = ""
        emailCodeTField.text = ""
        emailCodeTField.isEnabled = true
        nameTField.text = ""
        passwordTField.text = ""
    }

    // MARK: - Метод регистрации 
    func isPressDone() {
        self.showWaitView(isWait: true)
        dismissKeyboard()
        //отправляем данные регистрации на сервер
        msgRequestSignUP.value = MessageModel()
        ProfileAPI.requestSignUp(delegate: delegate, regemail: emailCodeTField.text!, nickname: nameTField.text!, password: passwordTField.text!, callback: {
            [weak self] (callback) in
            if let ss = self {
                ss.showWaitView(isWait: false)
                if let code = callback.code {
                    if code < 200 || code >= 300 {

                    }
                }
                ss.msgRequestSignUP.value = callback
            }
        })
    }

    func transitionVC(infoUser: Variable<UserInfoModel>) {
        self.showWaitView(isWait: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "MainNavigationID") as! MainNavigationViewController

        (nav.viewControllers.first as! MainViewController).emailProfile = AllUserDefaults.getLoginUD() ?? ""
        (nav.viewControllers.first as! MainViewController).profileInfo = infoUser

        present(nav, animated: true, completion: nil)
    }

    // MARK: - Запрос на получения профиля пользователя после успешной авотризации
    func requiredRequests() {
        ProfileAPI.requestProfileInfo(delegate: delegate, email: AllUserDefaults.getLoginUD() ?? "", callback: {[weak self] callback in
            if let ss = self {
                ss.showWaitView(isWait: true)
            }
            if let code = callback.code, code >= 200 && code < 300 {
                let info = Variable<UserInfoModel>(callback)
                //переходим к главной активности и передаем ей информацию о пользователе типа - UserModel
                self?.transitionVC(infoUser: info)
            } else {
                if let msg = callback.msg {
                    if let ss = self {
                        ss.showWaitView(isWait: false)
                        if let code = callback.code {
                            if code < 200 || code >= 300 {

                            }
                        }
                        ss.showAlertView(text: msg, callback: {
                            return
                        })
                    }
                }
            }
        })
    }

    // MARK: - Actions

    @IBAction func showPassword(_ sender: UIButton) {
        self.passwordTField.isSecureTextEntry = !self.passwordTField.isSecureTextEntry
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    //создаем запрос на регистрацию
    @IBAction func signupAction(_ sender: UIButton) {

        let fields = [nameTField, emailCodeTField, passwordTField, password1TField]
        for field in fields {
            checkIfError(textField: field!)
            if self.errorLabel.text?.isEmpty == false {
                return
            }
        }
        isPressDone()
    }

    deinit {
        print("deinit AuthorizationViewController")
    }

    override func viewDidAppear(_ animated: Bool) {
        print("did app")
    }

}

extension RegController {
    func subscribeProfile() {
        // MARK: - Регистрация нового пользователя
        //Наблюдатель изменения переменной о создании профиля
        msgRequestSignUP.asObservable().skip(1).subscribe {
            [weak self] element in
            if let msg = element.element {
                if let code = msg.code, code >= 200 && code < 300 {
                    //все ок проходим в login
                    if let ss = self {
                        ss.showWaitView(isWait: false)
                        let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: "Профиль успешно создан, необходимо подтвердить email", tittle: "", actionBtn: "ОК", callback: {})
                        if let alertController = alert {
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    //обработка ошибок
                    if msg.code != nil || msg.msg != nil {
                        if let ss = self {
                            self?.errorLabel.text = msg.msg
                            ss.showWaitView(isWait: false)
                            /*ss.showAlertView(text: msg.msg, callback: {
                                return
                            })*/
                        }
                    }
                }
            }
            }.disposed(by: disposeBag)
    }
}

extension RegController: UITextFieldDelegate {
    // MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard() {

        emailCodeTField.delegate = self
        nameTField.delegate = self
        passwordTField.delegate = self
        password1TField.delegate = self

        //event open keyboard
        registerForKeyboardNotification()

        //dissmis keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(AuthorizationViewController.dismissKeyboard))

        //event свернуть клавиатуру если был тап в пустую область
        view.addGestureRecognizer(tap)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        self.updateErrorLabel(error: nil,
                              textField: textField)
        if textField == nameTField && string == " " {
            return false
        }
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        self.updateErrorLabel(error: nil,
                              textField: textField)
        if textField == self.passwordTField {
              // проверка, если введенных символов один и больше, то появляеться кнопка "Показать пароль"
            self.seeBtn.isHidden =  textField.text?.count == 0
        }
    }

    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func kbWillShow(_ notification: Notification) {
        /*var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        print(scrollView.contentInset)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height+86
        scrollView.contentInset = contentInset
        print(contentInset)*/

    }

    @objc func kbWillHide(_ notification: Notification) {
        /*scrollView.contentOffset = CGPoint.zero
        scrollView.contentInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)*/
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //scrollView.resignFirstResponder() //прячем клавиатуру
        removeNotificationKeyBoard()
        view.endEditing(true)
    }

    //переход к незаполненным полям
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailCodeTField:
                passwordTField.becomeFirstResponder()
        case nameTField:
            emailCodeTField.becomeFirstResponder()
        case passwordTField:
            password1TField.becomeFirstResponder()
        case password1TField:
            password1TField.endEditing(true)
        default:
            textField.endEditing(true)
            isPressDone()
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.checkIfError(textField: textField)
        return true
    }

    // проверка правильности заполнения полей
    func checkIfError(textField: UITextField) {
        var error: String?
        switch textField {
        case nameTField:
            error = Validation.shared.checkNick(nick: textField.text!)
        case emailCodeTField:
            error = Validation.shared.checkEmail(email: textField.text!)
        case passwordTField:
            error = Validation.shared.checkPassword(password: textField.text!)
        case password1TField:
            error = passwordTField.text != password1TField.text ? AlertMessages.inValidPasswordConfirm.localized() : nil
        default:
            break
        }
        self.updateErrorLabel(error: error, textField: textField)
    }

    func updateErrorLabel(error: String?, textField: UITextField) {
        if error != nil {
            //если поле заполнено неправильно подсвечиваем красным и показываем описание, что не так
            self.errorLabel.text = error
            textField.textColor = self.errorLabel.textColor
        } else {
            //если поле заполнено правильно убираем подсвечивание
            self.errorLabel.text = ""
            textField.textColor = UIColor(white: 0.35, alpha: 1.0)
        }
    }

    func removeNotificationKeyBoard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

}
