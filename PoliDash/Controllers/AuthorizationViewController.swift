//
//  AuthorizationViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var splashView: UIImageView! //LaunchScreen
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailCodeTField: UITextField!
    @IBOutlet weak var nameTField: UITextField!
    @IBOutlet weak var passwordTField: UITextField!
    @IBOutlet weak var doneButton: IBDesignableButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var tipsController: TipsController?

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()

    var isRegistrationState = false

    // MARK: - Request SignUP
    var msgRequestSignUP = Variable<MessageModel>(MessageModel())

    // MARK: - Request Login
    var msgLogin = Variable<MessageModel>(MessageModel())

    // MARK: - Request Restore Password
    var msgRestorePassword = Variable<MessageModel>(MessageModel())

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeProfile()
        settingsKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        setFields()
        if let login = AllUserDefaults.getLoginUD(), let pass = AllUserDefaults.getPasswordUD() {
            emailCodeTField.text = login
            passwordTField.text = pass
            isPressDone()
        } else {
            splashView.isHidden = true
        }
    }

    //устанавливаем отобржение полей на фоме (поля регистрации или авторизации)
    func setFields() {
        dismissKeyboard()
        if isRegistrationState {
            setBackgroundImageButton_SignUp()
            nameTField.isHidden = false
            //удаляем заданные значения в полях
            clearFields()
        } else {
            setBackgroundImageButton_Login()
            nameTField.isHidden = true
            //удаляем заданные значения в полях
            clearFields()
        }
    }

    func clearFields() {
        emailCodeTField.text = ""
        emailCodeTField.isEnabled = true
        nameTField.text = ""
        passwordTField.text = ""
    }

    // MARK: - Метод регистрации или авторизации
    func isPressDone() {
        self.showWaitView(isWait: true)
        dismissKeyboard()
        if isRegistrationState {
            //отправляем данные регистрации на сервер
            msgRequestSignUP.value = MessageModel()
            ProfileAPI.requestSignUp(delegate: delegate, regemail: emailCodeTField.text!, nickname: nameTField.text!, password: passwordTField.text!, callback: {
                [weak self] (callback) in
                if let ss = self {
                    ss.showWaitView(isWait: false)
                    if let code = callback.code {
                        if code < 200 || code >= 300 {
                            //скрываем LaunchScreen для отображения полей ввода логина
                            ss.splashView.isHidden = true
                        }
                    }
                    ss.msgRequestSignUP.value = callback
                }
            })
        } else {
            //отправляем запрос авторизации на сервер
            msgLogin.value = MessageModel()
            ProfileAPI.requestLogin(delegate: delegate, email: emailCodeTField.text!, password: passwordTField.text!, callback: {[weak self] (callback) in
                if let ss = self {
                    ss.showWaitView(isWait: false)
                    if let code = callback.code {
                        if code < 200 || code >= 300 {
                            //скрываем LaunchScreen для отображения полей ввода логина
                            ss.splashView.isHidden = true
                        }
                    }
                    ss.msgLogin.value = callback
                }
            })
        }
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
        signUpButton.setBackgroundImage(nil, for: UIControlState.normal)
        loginButton.setBackgroundImage(UIImage(named: "ButtonBG"), for: UIControlState.normal)
    }

    //выделяем текщее нажатия на кнпку "Зарегистрироваться" и убираем выделения с кнопки "Войти"
    func setBackgroundImageButton_SignUp() {
        loginButton.setBackgroundImage(nil, for: UIControlState.normal)
        signUpButton.setBackgroundImage(UIImage(named: "ButtonBG"), for: UIControlState.normal)
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
                                //скрываем LaunchScreen для отображения полей ввода логина
                                ss.splashView.isHidden = true
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

    //переключиться на ввод данных регистрациии
    @IBAction func signUpAction(_ sender: UIButton) {
        isRegistrationState = true
        setFields()
    }

    //Переключиться на ввод данных авторизации
    @IBAction func logInAction(_ sender: UIButton) {
        isRegistrationState = false
        setFields()
    }

    //Готово
    @IBAction func doneAction(_ sender: IBDesignableButton) {
//       создаем запрос на регистрацию или авторизацию в зависемости от выбранного действия
       isPressDone()
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

extension AuthorizationViewController {
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
                        //иметируем нажатие на кнопку "Войти", чтобы при попытке "Выхода" пользователь уведел интерфейс входа
                        self?.setBackgroundImageButton_Login()
                    }
                } else {
                    //обработка ошибок
                    if msg.code != nil || msg.msg != nil {
                        if let ss = self {
                            ss.showWaitView(isWait: false)
                            ss.showAlertView(text: msg.msg, callback: {
                                return
                            })
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)

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

extension AuthorizationViewController: UITextFieldDelegate {
    // MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard() {

        emailCodeTField.delegate = self
        nameTField.delegate = self
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

    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func kbWillShow(_ notification: Notification) {
        var userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        print(scrollView.contentInset)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height+86
        scrollView.contentInset = contentInset
        print(contentInset)

    }

    @objc func kbWillHide(_ notification: Notification) {
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        scrollView.resignFirstResponder() //прячем клавиатуру
        removeNotificationKeyBoard()
        view.endEditing(true)
    }

    //переход к незаполненным полям
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailCodeTField:
            if nameTField.isHidden == false {
                nameTField.becomeFirstResponder()
            } else {
                passwordTField.becomeFirstResponder()
            }
        case nameTField:
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
