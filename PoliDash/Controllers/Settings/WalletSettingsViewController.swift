//
//  WalletSettingsViewController.swift
//  PoliDash
//
//  Created by olya on 10/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class WalletSettingsViewController: UIViewController {

    let delegate =  UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.frame.height/2
            self.cancelButton.isHidden = true
        }
    }

    @IBOutlet weak var addWalletButton: UIButton! {
        didSet {
            addWalletButton.layer.cornerRadius = addWalletButton.frame.height/2
            self.addWalletButton.isHidden = true
        }
    }

    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.text = ""
        }
    }
    @IBOutlet weak var addressTextField: UITextField! {
        didSet {
            self.addressTextField.delegate = self
            self.addressTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                            for: .editingChanged)
            self.addressTextField.returnKeyType = .done
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        checkWalletStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestBalance()
    }
    
    func requestBalance() {
        guard let delegate = delegate else { return }

        ProfileAPI.requestBalance(delegate: delegate) { (response) in
            self.balanceLabel.text = "Баланс \(response.balance) upishek"
        }
    }

    @IBAction func goToBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelBindingWallet(_ sender: UIButton) {
        dismissKeyboard()
        guard let address = self.addressTextField.text,
            let email = AllUserDefaults.getLoginUD(),
            let delegate = delegate else { return }
        ProfileAPI.cancelBindingWallet(
            delegate: delegate,
            email: email,
            address: address) { (response) in
                switch response.code {
                case 400:
                    self.showErrorView()
                case 500: break
                case 200: break
                default: break
                    //показать подтверждение
                }
                self.showAlertView(text: "Запрос выполнен", callback: {
                })
        }
    }

    func showErrorView() {
        let _ = InfoView(title: "Ой, ваш адрес не найден",
                         subtitle: "Попробуйте проверить номер или связаться с нами",
                         image: UIImage(named: "Heart"))
    }

    func showConfirmView() {

    }

    func checkWalletStatus() {
        guard let address = self.addressTextField.text,
            let email = AllUserDefaults.getLoginUD(),
            let delegate = delegate else { return }
        ProfileAPI.bindingWallet(
            delegate: delegate,
            email: email,
            address: address) { [weak self] (response) in
                switch response.code {
                case 400: break
                    //self?.showAlertView(text: "Ой, ваш адрес не найден", callback: {})
                case 500: break
                case 200: break
                    //self?.showConfirmView()
                default: break
                }
        }
    }

    @IBAction func getBingingWallet(_ sender: UIButton) {
        dismissKeyboard()

        guard let address = self.addressTextField.text,
            let delegate = delegate else { return }

        ProfileAPI.requestBindingWallet(
            delegate: delegate,
            address: address) { [weak self] (response) in
                switch response.code {
                case 400:
                    self?.showAlertView(text: response.msg, callback: {})
                case 500: break
                case 200:
                    self?.showConfirmView()
                default: break
                }
        }
    }

    @IBAction func showQRRecognizer(_ sender: UIButton) {
        let viewController = ScannerViewController()
        self.navigationController?.pushViewController(viewController, animated: true)

        viewController.completion = { [weak self] result in
            self?.addressTextField.text = result
            self?.addWalletButton.isHidden = false
        }
    }
}

extension WalletSettingsViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            self.addWalletButton.isHidden = true
            self.cancelButton.isHidden = true
        } else {
            self.addWalletButton.isHidden = false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard() {

        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(WalletSettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tapRecognizer)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == self.addressTextField {
            // проверка, если введенных символов один и больше, то появляеться кнопка "Показать пароль"
            let hiddenButton = textField.text?.count == 0
            self.addWalletButton.isHidden = hiddenButton
            self.cancelButton.isHidden = true
        }
    }

    @objc func dismissKeyboard() {
        view.resignFirstResponder() //прячем клавиатуру
        view.endEditing(true)
    }
}
