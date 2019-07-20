//
//  WalletSettingsViewController.swift
//  PoliDash
//
//  Created by olya on 10/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class WalletSettingsViewController: UIViewController {

    // MARK: - params -
    let delegate =  UIApplication.shared.delegate as? AppDelegate

    let companyEMail = "unitedStories@gmail.com"
    let companyWallet = "0xeEC45871c22C63dED0E723A71f2b408e6A9A9709"
    
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

    @IBOutlet weak var companyWalletInfoView: UIImageView! {
        didSet{
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
        didSet {
            self.updateViewInfo(with: walletStatus)
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

    // MARK: - functions -

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewInfo(with: walletStatus)
        checkWalletStatus()
    }

    // MARK: actions

    @IBAction func goToBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func copyCompanyAddress() {
        UIPasteboard.general.string = self.companyWallet
    }

    func setWalletStatus(model: WalletStatusResponseModel) {
        if model.status == 1 {
            self.walletStatus = .bound
            self.requestBalance()
        } else {
            self.walletStatus = .waiting
            self.companyInfoLabel.text = "код \(model.orderId)\n\(companyEMail)"
        }
        self.addressTextField.text = model.address
    }

    func updateViewInfo(with status: WalletStatus) {

        balanceView.isHidden = true
        waitStatusView.isHidden = true
        companyWalletInfoView.isHidden = true

        switch status {
        case .waiting:
            cancelButton.isHidden = false
            addWalletButton.isHidden = true
            waitStatusView.isHidden = false
            companyWalletInfoView.isHidden = false
        case .bound:
            setTextFieldEditable(false)
            addWalletButton.setTitle("заменить",
                                     for: .normal)
            cancelButton.isHidden = true
            addWalletButton.isHidden = false
            companyInfoLabel.text = ""
        case .none:
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
        addressTextField.isEnabled = state
        qrButton.isEnabled = state
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

        ProfileAPI.requestBalance(delegate: delegate) { (response) in
            self.balanceLabel.text = "Баланс \(response.balance) upishek"
            self.balanceView.isHidden = false
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
