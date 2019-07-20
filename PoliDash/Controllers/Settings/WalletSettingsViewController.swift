//
//  WalletSettingsViewController.swift
//  PoliDash
//
//  Created by olya on 10/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class WalletSettingsViewController: UIViewController {

    
    //MARK: - params -
    let delegate =  UIApplication.shared.delegate as? AppDelegate

    enum WalletStatus {
        case none
        case waiting
        case bound
    }
    
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

    var walletStatus: WalletStatus = .none {
        didSet {
            self.updateViewInfo(with: walletStatus)
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

    //MARK: - functions -

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestBalance()
        checkWalletStatus()
    }

    //MARK: actions

    @IBAction func goToBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setWalletStatus(model: WalletStatusResponseModel){
        if model.status == 1 {
            self.walletStatus = .bound
        } else {
            self.walletStatus = .waiting
        }
        self.addressTextField.text = model.address
    }

    func updateViewInfo(with status: WalletStatus) {
        switch status {
        case .waiting:
            self.cancelButton.isHidden = false
            self.addWalletButton.isHidden = true
        case .bound:
            self.setTextFieldEditable(false)
            self.addWalletButton.setTitle("заменить",
                                          for: .normal)
            self.cancelButton.isHidden = true
            self.addWalletButton.isHidden = false
        case .none:
            self.setTextFieldEditable(true)
            self.addressTextField.text = ""
            self.cancelButton.isHidden = true
            self.addWalletButton.isHidden = false
            self.addWalletButton.setTitle("привязать",
                                          for: .normal)
        }
    }

    func setTextFieldEditable(_ state: Bool) {
        self.addressTextField.isEnabled = state
        self.qrButton.isEnabled = state
        let imgName = state ? "qrcode": "accepted"

        self.qrButton.setImage(UIImage(named: imgName), for: .normal)
    }

    func showErrorView() {
        _ = InfoView(title: "Ой, ваш адрес не найден",
                     subtitle: "Попробуйте проверить номер или связаться с нами",
                     image: UIImage(named: "Heart"))
    }
    
    func showConfirmView() {
        
    }
    
    @IBAction func showQRRecognizer(_ sender: UIButton) {
        let viewController = ScannerViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        
        viewController.completion = { [weak self] result in
            self?.addressTextField.text = result
            self?.addWalletButton.isHidden = false
        }
    }


    
    
    //MARK: network

    func requestBalance() {
        guard let delegate = delegate else { return }

        ProfileAPI.requestBalance(delegate: delegate) { (response) in
            self.balanceLabel.text = "Баланс \(response.balance) upishek"
        }
    }

    @IBAction func cancelBindingWallet(_ sender: UIButton) {
        dismissKeyboard()
        guard let address = self.addressTextField.text,
            let email = AllUserDefaults.getLoginUD(),
            let delegate = delegate else { return }
        ProfileAPI.cancelBindingWallet(
            delegate: delegate,
            email: email,
            address: address) { [weak self] response in
                self?.showAlertView(text: response.msg)
                switch response.code {
                case 200:
                    self?.walletStatus = .none
                default: break
                }
        }
    }

    func checkWalletStatus() {
        guard let address = self.addressTextField.text,
            let email = AllUserDefaults.getLoginUD(),
            let delegate = delegate else { return }
        ProfileAPI.checkBindingWallet(
            delegate: delegate,
            email: email,
            address: address) { [weak self] (response) in
                if let model = response as? WalletStatusResponseModel {
                    switch model.code {
                    case 200:
                        self?.setWalletStatus(model: model)
                    default: break
                    }
                }
            }
    }

    @IBAction func getBingingWallet(_ sender: UIButton) {
        dismissKeyboard()

        //self.addressTextField.text = "0x4e83362442b8d1bec281594cea3050c8eb01311c"
        guard let address = self.addressTextField.text,
            let delegate = delegate else { return }

        self.showWaitView(isWait: true)
        ProfileAPI.requestBindingWallet(
            delegate: delegate,
            address: address) { [weak self] (response) in
                self?.showWaitView(isWait: false)
                self?.showAlertView(text: response.msg)
                switch response.code {
                case 400: break
                case 200:
                    self?.walletStatus = .waiting
                default: break
                }
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

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == self.addressTextField {
            let hiddenButton = textField.text?.count == 0
            self.addWalletButton.isHidden = hiddenButton
            self.cancelButton.isHidden = true
        }
    }

    @objc func dismissKeyboard() {
        view.resignFirstResponder()
        view.endEditing(true)
    }
}
