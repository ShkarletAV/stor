//
//  WalletSettingsViewController.swift
//  PoliDash
//
//  Created by olya on 10/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class WalletSettingsViewController: UIViewController {

    let delegate =  UIApplication.shared.delegate as! AppDelegate

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
            self.addressTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            self.addressTextField.returnKeyType = .done
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func cancelWalletRelation(_ sender: UIButton) {

    }

    @IBAction func goToBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func createWalletRelation(_ sender: UIButton) {
        dismissKeyboard()
        ProfileAPI.requsetAddWallet(delegate: delegate, email: AllUserDefaults.getLoginUD()!,
                                     address: self.addressTextField.text!) { (_) in
                                        self.showAlertView(text: "Запрос выполнен", callback: {

                                    })
        }
    }

    @IBAction func showQRRecognizer(_ sender: UIButton) {
        let vc = ScannerViewController()
        self.navigationController?.pushViewController(vc, animated: true)

        vc.completion = { [weak self] result in
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

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(WalletSettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
