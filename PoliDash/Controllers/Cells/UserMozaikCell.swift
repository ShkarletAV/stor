//
//  UserMozaikCell.swift
//  PoliDash
//
//  Created by Ігор on 3/5/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class UserSaveStoryCell : UICollectionViewCell {
    @IBOutlet weak var bgImage : UIImageView!
    var video : SavedVideo? {
        didSet{
            bgImage.sd_setImage(with: URL(string: (video?.videos?.first?.preview)!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
        }
    }
}

class UserMozaikCell: UICollectionViewCell {
    @IBOutlet weak var bgImage : UIImageView!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    var owner : Owners_Model? {
        didSet {
            
            guard let owner = owner else {
                return
            }

            nameLabel.isHidden = false
            avatar.isHidden = false
            nameLabel.text = owner.nickname
            bgImage.sd_setImage(with: self.storyPreview(),
                                placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"),
                                options: [], completed: nil)
            var ownerUrl: URL? = nil
            if let url = URL(string: owner.picture ?? "") {
                ownerUrl = url
            }

            avatar.sd_setImage(with: ownerUrl,
                               placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"),
                               options: [],
                               completed: nil)
        }
    }
    
    var user : UsersModel? {
        didSet {
            nameLabel.isHidden = false
            avatar.isHidden = false
            
            guard let user = user else {
                return
            }
            nameLabel.text = user.nickname
            bgImage.sd_setImage(with: self.storyUserPreview(),
                                placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"),
                                options: [],
                                completed: nil)
            
            var userUrl: URL? = nil
            if let url = URL(string: user.picture ?? "") {
                userUrl = url
            }
            avatar.sd_setImage(with: userUrl,
                               placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"),
                               options: [],
                               completed: nil)
            
        }
    }
    
    var video : SavedVideo? {
        didSet{
            nameLabel.isHidden = true
            avatar.isHidden = true
            bgImage.sd_setImage(with: URL(string: (video?.videos?.first?.preview)!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgImage.layer.cornerRadius = 5.0
        bgImage.clipsToBounds = true
        avatar.layer.cornerRadius = 20.0
        avatar.clipsToBounds = true
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.borderWidth = 2
    }
    
    func storyPreview() -> URL? {
        var urlString : String?
        guard let owner = owner else {
            return nil
        }
        if let count = owner.video?.count, count > 0 {
            urlString = owner.video?[0].preview
        } else if owner.picture != nil {
            urlString = owner.picture
        }
        return URL(string: urlString ?? "")
    }
    
    func storyUserPreview() -> URL? {
        var urlString : String?

        guard let user = user else {
            return nil
        }
        if (user.video?.count)! > 0 {
            urlString = user.video?[0].preview
        } else if user.picture != nil {
            urlString = user.picture
        }
        return URL(string: urlString ?? "")
    }
    
}
