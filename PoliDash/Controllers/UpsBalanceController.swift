//
//  UpsBalanceController.swift
//  PoliDash
//
//  Created by Ігор on 3/17/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class UpsBalanceController: UIViewController {
    @IBOutlet weak var roundCountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    var balance = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let circles = self.balance/40 > 5 ? 5 : self.balance/40
        balanceLabel.text = balanceLabel.text?.replacingOccurrences(of: "0", with: "\(balance)")
        roundCountLabel.text = "\(circles)"
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
