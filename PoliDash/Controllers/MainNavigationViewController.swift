//
//  MainNavigationViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 30.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift

class MainNavigationViewController: UINavigationController {

    var profileInfo: Variable<UserInfoModel>!
    var emailProfile = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
}
