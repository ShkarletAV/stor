//
//  WalletSettingsViewController.swift
//  PoliDash
//
//  Created by XXXX on 10/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class WalletSettingsViewController: UIViewController {

    // MARK: - params -
    let delegate =  UIApplication.shared.delegate as? AppDelegate

    let companyEMail = "unitedStories@gmail.com"
    let companyWallet = "0xeEC45871c22C63dED0E723A71f2b408e6A9A9709"

    var isAlreadyBinding: Bool = false

    enum WalletStatus {
        case none
        case waiting
        case bound
        case error
    }

    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.frame.height/2
            self.cancelButton.isHidden = true
        }
    }

    @IBOutlet weak var companyWalletInfoView: UIView! {
        didSet {
            let tapRecognizer = UIGestureRecognizer(
                target: self,
                action: #selector(copyCompanyAddress))
            companyWalletInfoView.isHidden = true
            companyWalletInfoView.addGestureRecognizer(tapRecognizer)
        }
    }

    @IBOutlet weak var addWalletButton: UIButton! {
        didSet {
            addWalletButton.layer.cornerRadius = addWalletButton.frame.height/2
            self.addWalletButton.isHidden = true
        }
    }

    var walletStatus: WalletStatus = .none {
        willSet {
            self.updateViewInfo(with: newValue)
        }
    }

    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var companyInfoLabel: UILabel! {
        didSet {
            companyInfoLabel.text = ""
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

    @IBOutlet weak var waitStatusView: UIButton! {
        didSet {
            self.waitStatusView.isHidden = true
        }
    }
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var ourAdressField: UITextField! {
        didSet {
            self.ourAdressField.delegate = self
            self.ourAdressField.inputView = UIView()
            self.ourAdressField.tintColor = .clear
        }
    }

    // MARK: - functions -

    var skipCheck: Bool = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        skipCheckF()
    }
    
    // MARK : - если приложение ушло в бэкграунд, то прячем БалансВью
    @objc func appDidEnterBackground() {
      //  balanceView.isHidden = true
    }
    
    // MARK : - через этот метод проверяется статус кошелька, если приложение до этого момента было в бэкграунде и было переведено в foreground
    @objc func appWillEnterForeground() {
        skipCheckF()
    }
    
    func skipCheckF() {
        if !skipCheck {
            checkWalletStatus()
        }
        
        skipCheck = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewInfo(with: walletStatus)
        checkWalletStatus()
        
        NotificationCenter.default.addObserver(self, selector:#selector(appWillEnterForeground), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(appDidEnterBackground), name:
            NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    // MARK: actions

    @IBAction func goToBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func copyCompanyAddress() {
        UIPasteboard.general.string = self.companyWallet
    }

    func setWalletStatus(model: WalletStatusResponseModel) {
        if model.statusState == WalletStatusResponseModel.StatusStates.Accepted {
            self.walletStatus = .bound
            if let balance = AllUserDefaults.userBalance, balance == 0 {
                self.requestBalance()
            } else if let balance = AllUserDefaults.userBalance {
                setBalance(amount: balance)
            }
        } else {
            self.walletStatus = .waiting
            self.ourAdressField.text = companyWallet
            self.companyInfoLabel.text = "код \(model.orderId), наш адрес: \(companyEMail)"
        }
        self.addressTextField.text = model.address
    }

    func updateViewInfo(with status: WalletStatus) {

    //    balanceView.isHidden = true
        waitStatusView.isHidden = true
        companyWalletInfoView.isHidden = true

        switch status {
        case .waiting:
            cancelButton.isHidden = false
            addWalletButton.isHidden = true
            waitStatusView.isHidden = false
            companyWalletInfoView.isHidden = false
        case .bound:
            isAlreadyBinding = true
            setTextFieldEditable(false)
            addWalletButton.setTitle("заменить",
                                     for: .normal)
            cancelButton.isHidden = true
            addWalletButton.isHidden = false
            companyInfoLabel.text = ""
        case .none:
            isAlreadyBinding = false
            setTextFieldEditable(true)
            addressTextField.text = ""
            cancelButton.isHidden = true
            addWalletButton.isHidden = false
            addWalletButton.setTitle("привязать",
                                    for: .normal)
            companyInfoLabel.text = ""
        case .error:
            companyInfoLabel.text = ""
        }
    }

    func setTextFieldEditable(_ state: Bool) {
        //addressTextField.isEnabled = state
        //qrButton.isEnabled = state
        let imgName = state ? "qrcode": "accepted"

        self.qrButton.setImage(UIImage(named: imgName), for: .normal)
    }

    @IBAction func showQRRecognizer(_ sender: UIButton) {
        let viewController = ScannerViewController()
        self.navigationController?.pushViewController(viewController, animated: true)

        viewController.completion = { [weak self] result in
            self?.addressTextField.text = result
            self?.addWalletButton.isHidden = false
        }
    }

    // MARK: network

    func requestBalance() {
        guard let delegate = delegate else { return }

        ProfileAPI.requestBalance(delegate: delegate) { [weak self] (response) in
            self?.setBalance(amount: response.balance)
        }
    }
    
    func setBalance(amount: Int) {
        self.balanceLabel.text = "Баланс \(amount) upishek"
        self.balanceView.isHidden = false
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
                    AllUserDefaults.userBalance = 0
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
            address: address, already: isAlreadyBinding) { [weak self] (response) in
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}

extension WalletSettingsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
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
        if textField.isEqual(self.ourAdressField) {
            return false
        }
        
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
