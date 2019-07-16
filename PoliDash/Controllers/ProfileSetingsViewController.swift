//
//  ProfileSetingsViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 23.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift

class ProfileSetingsViewController: UIViewController{

    @IBOutlet weak var name_TField: UITextField!
    @IBOutlet weak var wait_View: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var balanceBtn: UIButton!
    @IBOutlet weak var upSettingsButton: UIButton!
    @IBOutlet weak var addWalletButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    
    let delegate =  UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()
    
    //MARK:- Request Logout
    var msg_Logout = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Change User Name
    var msg_ChangeUserName = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Change Password
    var msg_ChangePassword = Variable<MessageModel>(MessageModel())
    var userBalance = 0
    
    
    var profileInfo : Variable<UserInfoModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Profile_API.requestBalance(delegate: delegate) { (response) in
            self.userBalance = response.balance
            self.userBalance = 200
            self.balanceBtn.setTitle("Баланс \(self.userBalance) ups инфо", for: .normal)
            let circles = self.userBalance/40 > 5 ? 5 : self.userBalance/40
            self.upSettingsButton.setTitle("Настройки UP \(circles)", for: .normal)
        }
        subscribe()
        settingsKeyboard()
    }
    
    private func clearTextFields(){
       // password_TField.text = ""
       // newPassword_TField.text = ""
       // rePassword_TField.text = ""
    }
    
    private func endEditingFields(){
       // password_TField.endEditing(true)
       // newPassword_TField.endEditing(true)
       // rePassword_TField.endEditing(true)
        name_TField.endEditing(true)
       // password_TField.endEditing(true)
    }
    
    //MARK:- Actions
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upSettings(){
        if self.userBalance > 40 {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ups_settings") as? UpSettingsController
        controller?.balance = self.userBalance
        self.navigationController?.pushViewController(controller!, animated: true)
        } else {
            showAlertView(text: "Недостаточно Ups для настройки") {
            }
        }
    }
    
    @IBAction func upsBalance(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ups_balance") as? UpsBalanceController
        controller?.balance = self.userBalance
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    
    
    @IBAction func support_Action(_ sender: UIButton) {
    }
    
    @IBAction func helpCenter_Action(_ sender: UIButton) {
    }
    
    @IBAction func logout_BarItem(_ sender: UIBarButtonItem) {
        //Отправляем запрос на выход
        self.showWaitView(isWait: true)
        msg_Logout.value = MessageModel()
        Profile_API.requestLogout(delegate: delegate, callback: {[weak self] callbcak in
            if let ss = self{
                ss.showWaitView(isWait: false)
                ss.msg_Logout.value = callbcak
            }
        })
    }
    
    @IBAction func done_Action(_ sender: UIButton) {
        endEditingFields()
//        Проверка валидности всех полей
        //self.showWaitView(isWait: true)
        //msg_ChangeUserName.value = MessageModel()
        //            выполняем запрос на изменения имя пользователя
        Profile_API.requsetChangeUserName(delegate: delegate, nickname: name_TField.text ?? "", pass: AllUserDefaults.getPasswordUD() ?? "", callback: {[weak self] callback in
            if let ss = self{
                //ss.msg_ChangeUserName.value = callback
                //ss.showWaitView(isWait: false)
                ss.backAction()
            }
        })
    }

    @IBAction func openWalletViewController(_ sender: UIButton) {
        if let controller = self.storyboard?.instantiateViewController(
            withIdentifier: "walletSettings") as? WalletSettingsViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    deinit {
        print("deinit ProfileSetingsViewController")
    }
}
extension ProfileSetingsViewController{
    func subscribe(){
//        Наблюдатель изменения модели выхода пользователя
        msg_Logout.asObservable().skip(1).subscribe{
            [weak self] element in
            if let msg = element.element{
                if let code = msg.code, code >= 200 && code < 300{
                    //удаляем данные из UserDefaults и выходим
                    AllUserDefaults.removeLoginUD()
                    AllUserDefaults.removePasswordUD()
                    self?.dismiss(animated: true, completion: nil)
                }else{
//                    Обработчик ошибок сервера
                    if msg.code != nil || msg.msg != nil{
                        if let ss = self{
                            ss.showAlertView(text: msg.msg, callback: {
                                return
                            })
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)
        
//        Наблюдатель изменения информации о пользователе
        profileInfo.asObservable().subscribe{
            [weak self] element in
            if let val = element.element, let code = val.code, code >= 200 && code < 300{
                if let ss = self{
                    ss.showWaitView(isWait: false)
                    ss.name_TField.text = val.nickname
                }
            }
        }.disposed(by: disposeBag)
        
//        Наблюдатель изменения имени пользователя
        msg_ChangeUserName.asObservable().skip(1).subscribe{
            [weak self] element in
            if let msg = element.element{
                if let code = msg.code, code >= 200 && code < 300{
                    //уведомляем пользователя об успешной смене данных
                    if let ss = self{
                        ss.showAlertView(text: msg.msg, callback: {
                            return
                        })
                    }
                }else{
                    if let ss = self{
                        ss.showAlertView(text: msg.msg, callback: {
                            return
                        })
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
}

extension ProfileSetingsViewController: UITextFieldDelegate{
    //MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard(){
        name_TField.delegate = self
        
        changeColorPlaceholder()
        
        //event open keyboard
        registerForKeyboardNotification()
        
        //dissmis keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard))
        
        //event свернуть клавиатуру если был тап в пустую область
        view.addGestureRecognizer(tap)
    }
    
    func changeColorPlaceholder(){
        name_TField.changeColorTFiledOnWhite()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " "{
            return false
        }
        
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 18
    }
    
    func registerForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        print(scrollView.contentInset)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height+86
        scrollView.contentInset = contentInset
        print(contentInset)
        
    }
    
    @objc func kbWillHide(_ notification: Notification){
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        scrollView.resignFirstResponder() //прячем клавиатуру
        view.endEditing(true)
        removeNotificationKeyBoard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name_TField:
            textField.endEditing(true)
        default:
            textField.endEditing(true)
        }
        return true
    }
    
    
    func removeNotificationKeyBoard(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
}
