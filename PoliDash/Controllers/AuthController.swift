//
//  AuthController.swift
//  PoliDash
//
//  Created by Ігор on 3/1/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import RxSwift

class AuthController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!          // кнопка регистрации
    @IBOutlet weak var loginButton: UIButton!           // кнопка авторизации
    @IBOutlet weak var splash: UIImageView!              // заставка
    @IBOutlet weak var emailCodeTField: UITextField!   // поле ввода мейла
    @IBOutlet weak var passwordTField: UITextField!     // поле ввода пароля
    @IBOutlet weak var doneButton: IBDesignableButton!
    @IBOutlet weak var seeBtn: UIButton!                 //кнопка "Показать пароль"
    var showSplash = false

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()

    // MARK: - Request Login
    var msgLogin = Variable<MessageModel>(MessageModel())

    // MARK: - Request Restore Password
    var msgRestorePassword = Variable<MessageModel>(MessageModel())

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeProfile()
        settingsKeyboard()
        self.splash.isHidden = !showSplash
        self.passwordTField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        setFields()
        if let login = AllUserDefaults.getLoginUD(), let pass = AllUserDefaults.getPasswordUD() {
            emailCodeTField.text = login
            passwordTField.text = pass
            isPressDone()
        } else {
            self.splash.isHidden = true
        }
    }

    //устанавливаем отобржение полей на фоме (поля регистрации или авторизации)
    func setFields() {
        dismissKeyboard()
            clearFields()
    }

    func clearFields() {
        emailCodeTField.text = ""
        emailCodeTField.isEnabled = true
        passwordTField.text = ""
    }

    // MARK: - Метод авторизации
    func isPressDone() {
        self.showWaitView(isWait: true)
        dismissKeyboard()
        //отправляем запрос авторизации на сервер
        msgLogin.value = MessageModel()
        ProfileAPI.requestLogin(delegate: delegate, email: emailCodeTField.text!, password: passwordTField.text!, callback: {[weak self] (callback) in
            if let ss = self {
                ss.showWaitView(isWait: false)
                if let code = callback.code {
                    if code < 200 || code >= 300 {
                    }
                }
                ss.msgLogin.value = callback
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

    //выделяем текщее нажатия на кнпку "Войти" и убираем выделения с кнопки "Зарегистрироваться"
    func setBackgroundImageButton_Login() {
        signupButton.setBackgroundImage(nil, for: UIControlState.normal)
        loginButton.setBackgroundImage(UIImage(named: "ButtonBG"), for: UIControlState.normal)
    }

    //выделяем текщее нажатия на кнпку "Зарегистрироваться" и убираем выделения с кнопки "Войти"
    func setBackgroundImageButton_SignUp() {
        loginButton.setBackgroundImage(nil, for: UIControlState.normal)
        signupButton.setBackgroundImage(UIImage(named: "ButtonBG"), for: UIControlState.normal)
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

    //Показать/спрятать пароль
    @IBAction func showPassword(_ sender: UIButton) {
       self.passwordTField.isSecureTextEntry = !self.passwordTField.isSecureTextEntry
    }

    //Действие при нажатии на кнопку авторизации
    @IBAction func loginAction(_ sender: UIButton) {

        #if DEBUG
//        emailCodeTField.text = "lfc2515@gmail.com"
//        passwordTField.text = "12345678"
        emailCodeTField.text = "aravika08@mail.ru"
        passwordTField.text = "qwerty123"

        #endif
        // проверяем корректность введенного мейла
        if self.emailCodeTField.text?.isEmpty == true {
            self.showAlertView(text: AlertMessages.inValidEmail.localized()) {
            }
            return
        }
        // проверяем корректность введенного пароля
        if self.passwordTField.text?.isEmpty == true {
            self.showAlertView(text: AlertMessages.inValidPasswordIncorrect.localized()) {
            }
            return
        }
        //       создаем запрос на авторизацию
        isPressDone()
    }

    // переход на экран регистрации
    @IBAction func regAction() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "reg")
        self.navigationController?.pushViewController(controller!, animated: true)
    }

    //Восстановить пароль
    @IBAction func restorePassword_Action(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Восстановить пароль", message: "Укажите эл. почту аккаунта восстановления, на которую будет отправлен новый пароль", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (emailTField) in
            emailTField.placeholder = "email"
        }

        let cancelAlertAction = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel, handler: nil)
        let sendAlertAction = UIAlertAction(title: "Отправить", style: UIAlertActionStyle.default) { [weak self] (_) in
            let firstTextField = alertController.textFields![0] as UITextField
            //проверяем вылидность введенного email и отправляем запрос на сервер
            if let emailField = firstTextField.text {
                if let ss = self {
                    ss.showWaitView(isWait: true)
                    ss.msgRestorePassword.value = MessageModel()
                }
                ProfileAPI.requestResorePassword(delegate: (self?.delegate)!, email: emailField, callback: {[weak self] callback in
                    if let ss = self {
                        ss.showWaitView(isWait: false)
                        ss.msgRestorePassword.value = callback
                    }
                })
            }
        }
        alertController.addAction(cancelAlertAction)
        alertController.addAction(sendAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    deinit {
        print("deinit AuthorizationViewController")
    }

    override func viewDidAppear(_ animated: Bool) {
        print("did app")
    }

}

extension AuthController {
    func subscribeProfile() {
        // MARK: - Проверка авторизации
        //Наблюдатель изменения переменной о состоянии входа
        msgLogin.asObservable().skip(1).subscribe {
            [weak self] element in
            if let msg = element.element {
                if let statusCode = msg.code, statusCode >= 200 && statusCode < 300 {
                    //сохраняем данные
                    if let login = self?.emailCodeTField.text!, let pass = self?.passwordTField.text! {
                        //запоминаем данные для последующего автоматического входа
                        AllUserDefaults.saveLoginInUD(login: login)
                        AllUserDefaults.savePasswordInUD(password: pass)
                    }
                    self?.requiredRequests()
                } else {
                    //обработка ошибок
                    if msg.code != nil || msg.msg != nil {
                        if let ss = self {
                            self?.splash.isHidden = true
                            ss.showWaitView(isWait: false)
                            let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg.msg, tittle: "", actionBtn: "ОК", callback: {})
                            if let alertController = alert {
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            }.disposed(by: disposeBag)

        // MARK: - Восстановление пароля
        //Наблюдатель изменения переменной о состоянии восстановления пароля
        msgRestorePassword.asObservable().skip(1).subscribe {
            [weak self] element in
            if let msg = element.element {
                if let statusCode = msg.code, statusCode >= 200 && statusCode < 300 {
                    if let ss = self {
                        ss.showWaitView(isWait: false)
                        let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg.msg, tittle: "", actionBtn: "ОК", callback: {})
                        if let alertController = alert {
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    //обработка ошибок
                    if msg.code != nil || msg.msg != nil {
                        if let ss = self {
                            ss.showWaitView(isWait: false)
                            let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg.msg, tittle: "Ошибка", actionBtn: "ОК", callback: {})
                            if let alertController = alert {
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            }.disposed(by: disposeBag)
    }
}

extension AuthController: UITextFieldDelegate {
    // MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard() {

        emailCodeTField.delegate = self
        passwordTField.delegate = self

        //event open keyboard
        registerForKeyboardNotification()

        //dissmis keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard))

        //event свернуть клавиатуру если был тап в пустую область
        view.addGestureRecognizer(tap)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
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
       /* var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        print(scrollView.contentInset)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height+86
        scrollView.contentInset = contentInset
        print(contentInset)*/

    }

    @objc func kbWillHide(_ notification: Notification) {
       // scrollView.contentOffset = CGPoint.zero
       // scrollView.contentInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.resignFirstResponder() //прячем клавиатуру
        removeNotificationKeyBoard()
        view.endEditing(true)
    }

    //переход к незаполненным полям
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailCodeTField:
                passwordTField.becomeFirstResponder()
        case passwordTField:
            passwordTField.endEditing(true)
        default:
            textField.endEditing(true)
            isPressDone()
        }
        return true
    }

    func removeNotificationKeyBoard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

}
