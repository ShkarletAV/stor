//
//  UsersTableViewCell.swift
//  PoliDash
//
//  Created by David Minasyan on 30.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhoto_Image: RoundedUIImageView!
    @IBOutlet weak var moon_Image: UIImageView!
    @IBOutlet weak var titleName_Label: UILabel!
    @IBOutlet weak var collectionViewStorys: UICollectionView!
    @IBOutlet weak var user_Button: UIButton!
    @IBOutlet weak var lastTime_Label: UILabel!
    @IBOutlet weak var dotView: UIImageView!
    
    private(set) var disposeBagCell = DisposeBag()
    var tableRow = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBagCell = DisposeBag()        
    }

}
