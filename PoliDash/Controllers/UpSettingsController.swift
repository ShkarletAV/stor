//
//  UpSettingsController.swift
//  PoliDash
//
//  Created by Ігор on 3/17/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RoundButton: UIButton {
    var avaView: UIImageView?
    var owner: OwnersModel? {
        didSet {
            if owner != nil {
            self.setupAva()
            } else {
                self.avaView?.removeFromSuperview()
                self.avaView = nil
            }
        }
    }

    func setupAva() {
        if self.avaView?.superview == nil {
            self.clipsToBounds = true
            self.imageView?.contentMode = .scaleAspectFill
            self.avaView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 33, height: 33))
            self.avaView?.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            self.avaView?.layer.cornerRadius = 16.5
            self.avaView?.clipsToBounds = true
            self.avaView?.contentMode = .scaleAspectFill
            self.addSubview(self.avaView!)
        }
        self.avaView?.sd_setImage(with: URL(string: (owner?.picture)!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"))
    }
}

class UpsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    var owner: OwnersModel? {
        didSet {
            nameLabel.text = owner?.nickname
            var url: URL?
            if let picture = owner?.picture {
                url = URL(string: picture)
            }
            avatar.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"))
        }
    }
}

class UpSettingsController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var buttonsView: UIStackView!

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    var selectedOwners = [Int: OwnersModel]()

    var allOwners = [OwnersModel]()
    var selectedRound: RoundButton?
    var selectedOwner: OwnersModel?
    var ownersUser = Variable<[OwnersModel]>([])
    var msgOwners = Variable<MessageModel>(MessageModel())
    let delegate =  UIApplication.shared.delegate as! AppDelegate
    var balance = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.infoLabel.isHidden = false
        self.tableView.isHidden = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        searchBar.leftView = paddingView
        searchBar.leftViewMode = .always
        searchBar.attributedPlaceholder = NSAttributedString(string: "Поиск",
                                                             attributes: [NSAttributedString.Key.foregroundColor: self.searchBar.textColor as Any])
        searchBar.tintColor = searchBar.textColor
        searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBar.delegate = self
        let maxCircle = self.balance/40
        for btn in self.buttonsView.arrangedSubviews {
            btn.isHidden = !(btn.tag < maxCircle)
        }

        if maxCircle == 0 {
            self.infoLabel.text = "Недостаточно Ups"
        }

        loadCircles()
    }

    func loadCircles() {
        ProfileAPI.requestCircles(delegate: delegate, email: AllUserDefaults.getLoginUD()!) { (_, _, circles) in
            print(circles)
            var i = 0
            for owner in circles {
                self.selectedOwners[i] = owner
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).owner = owner
                i += 1
            }
            self.loadOwners()
        }
    }

    func loadOwners() {
        ProfileAPI.requestGetOwners(delegate: delegate, email: AllUserDefaults.getLoginUD()!) { [weak self] (msg, statusCode, ownerModel) in
            self?.allOwners = ownerModel
            self?.ownersUser.value = [OwnersModel]()
            self?.filterOwners()
            let msgOwner = MessageModel()
            msgOwner.msg = msg
            msgOwner.code = statusCode
            self?.msgOwners.value = msgOwner
            if let owners = self?.ownersUser.value {
                self?.headerLabel.text = "ПОДПИСКИ \((owners.count))"
            }
        }
    }

    func filterOwners() {
        self.ownersUser.value.removeAll()
        for owner in self.allOwners {
            var canAdd = true
            for so in self.selectedOwners.values {
                if so.email == owner.email {
                    canAdd = false
                    break
                }
            }
            if (self.searchBar.text?.count)! > 0 {
                if owner.nickname?.lowercased().contains((self.searchBar!.text?.lowercased())!) == false {
                    canAdd = false
                }
            }

            if canAdd == true {
                self.ownersUser.value.append(owner)
            }
        }
        self.tableView.reloadData()
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func selectRound(sender: RoundButton) {
        if self.selectedOwners.values.count >= self.balance/40 && sender.owner == nil {
            showAlertView(text: "Недостаточно Ups для выбора пользователя") {
            }
        } else {
        for btn in buttonsView.subviews {
            (btn as? RoundButton)?.isSelected = false
        }
        if self.selectedRound != sender {
            self.selectedRound = sender
            self.infoLabel.isHidden = true
            self.tableView.isHidden = false
            self.searchBar.isHidden = false
            sender.isSelected = true
            if sender.owner != nil {
                self.cancelBtn.isHidden = false
                self.cancelBtn.setTitle("удалить", for: .normal)
                self.cancelBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            } else {
                self.cancelBtn.isHidden = true
                self.acceptBtn.isHidden = true
            }
        } else {
            self.selectedRound = nil
            self.infoLabel.isHidden = false
            self.tableView.isHidden = true
            self.acceptBtn.isHidden = true
            self.cancelBtn.isHidden = true
            self.searchBar.isHidden = true
            self.searchBar.resignFirstResponder()
        }
        }
    }

    @IBAction func acceptAction() {
        if self.selectedRound?.owner != nil {
            if let email = self.selectedRound?.owner?.email {
                ProfileAPI.requestDeleteCircle(delegate: delegate, ownerEmail: AllUserDefaults.getLoginUD()!, displayiedEmail: email) { (msg) in
                    if msg.code == 200 {
                        self.selectedRound?.owner = nil
                    self.acceptAction()
                    } else {
                        self.showAlertView(text: msg.msg, callback: {
                        })
                    }
                }
            }
        } else {
            guard let ownerEmail = self.selectedOwner?.email else {
                self.showAlertView(text: "E-mail выделенного пользователя не определён")
                return
            }
            ProfileAPI.requsetPutCircle(delegate: delegate, email: ownerEmail) { (msg) in
                if msg.code == 200 {
                    self.selectedRound?.owner = self.selectedOwner
                    self.selectedOwners[(self.selectedRound?.tag)!] = self.selectedOwner
                    self.cancelBtn.setTitle("удалить", for: .normal)
                    self.acceptBtn.isHidden = true
                    self.cancelBtn.removeTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
                    self.cancelBtn.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
                    self.loadOwners()
                } else {
                    self.showAlertView(text: msg.msg, callback: nil)
                }
            }
        }
    }

    @IBAction func cancelAction() {
        self.selectedOwner = nil
        self.acceptBtn.isHidden = true
        if self.selectedRound?.owner != nil {
            self.cancelBtn.setTitle("удалить", for: .normal)
            self.cancelBtn.isHidden = false
            self.cancelBtn.removeTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            self.cancelBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        } else {
            self.cancelBtn.isHidden = true
            self.cancelBtn.removeTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        }
    }

    @IBAction func deleteAction() {
        if self.selectedRound?.owner != nil {
            if let email = self.selectedRound?.owner?.email {
                ProfileAPI.requestDeleteCircle(delegate: delegate, ownerEmail: AllUserDefaults.getLoginUD()!, displayiedEmail: email) { (msg) in
                    if msg.code == 200 {
                        self.selectedRound?.owner = nil
                        self.selectedOwners.removeValue(forKey: (self.selectedRound?.tag)!)
                        self.cancelBtn.isHidden = true
                        self.cancelBtn.removeTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
                        self.loadOwners()
                    } else {
                        self.showAlertView(text: msg.msg)
                    }
                }
            }
        }
    }
}

extension UpSettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ownersUser.value.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UpsCell
        cell?.owner = ownersUser.value[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOwner = self.ownersUser.value[indexPath.row]
        self.cancelBtn.isHidden = false
        self.cancelBtn.setTitle("отмена", for: .normal)
        self.acceptBtn.isHidden = false
        self.cancelBtn.removeTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    }
}

extension UpSettingsController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.filterOwners()
    }
}
