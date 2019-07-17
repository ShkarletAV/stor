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

    @IBOutlet weak var userPhotoImage: RoundedUIImageView!
    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var collectionViewStorys: UICollectionView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var lastTimeLabel: UILabel!
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
