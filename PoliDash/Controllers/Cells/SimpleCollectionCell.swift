//
//  SimpleCollectionCell.swift
//  PoliDash
//
//  Created by Ігор on 2/22/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import Alamofire

class SCCell: UICollectionViewCell {
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var avatar: UIImageView?
    var circleView: DowloadPreviewView?
    var circleBorder: CALayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.preview.layer.cornerRadius = 5.0
        self.avatar?.layer.borderColor = UIColor.white.cgColor
        self.avatar?.layer.borderWidth = 1.5
    }

    func addCircleView() {
        if circleView != nil {
            return
        }

        circleView = DowloadPreviewView.init(frame: self.preview.frame)
        guard let circleView = circleView else { return }
        self.preview.addSubview(circleView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateProgress(notification:)),
            name: NSNotification.Name("UPLOADING_PROGRESS_DID_CHANGE"),
            object: nil)
    }

    @objc func updateProgress(notification: Notification) {
        if let dict = notification.userInfo as? [String: Double], let progress = dict["progress"] {
            circleView?.changeProgress(progress: progress)
        }
    }
}

class SimpleCollectionCell: UITableViewCell {
    @IBOutlet weak var collection: UICollectionView!
    weak var delegate: MainViewController?
    var histories: [HistoryVideo]? {
        didSet {
            self.collection.reloadData()
            if let histories = histories, !histories.isEmpty {
            let lastItemIndex = self.collection.numberOfItems(inSection: 0) - 1
            let indexPath = IndexPath(row: lastItemIndex, section: 0)
            self.collection.scrollToItem(at: indexPath, at: .right, animated: false)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let histories = histories, !histories.isEmpty {
            let lastItemIndex = self.collection.numberOfItems(inSection: 0) - 1
            let indexPath = IndexPath(row: lastItemIndex, section: 0)
            self.collection.scrollToItem(at: indexPath, at: .right, animated: false)
        }
    }

    var likes: [AnyObject]? {
        didSet {
            self.collection.reloadData()
        }
    }

    var followers: [AnyObject]? {
        didSet {
            self.collection.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension SimpleCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.delegate?.activityType {
        case .likes?:
            return self.likes?.isEmpty ?? true ? 2 : (self.likes?.count)! + 1
        case .followers?:
            return self.followers?.isEmpty ?? true ? 2 : (self.followers?.count)! + 1
        default:
            return self.histories == nil ? 0 : (self.histories?.count)!
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.delegate?.activityType {
        case .likes?:
            let cellID = indexPath.row == 0 ? "like_placeholder" : self.likes?.isEmpty ?? true ? "empty" : "cell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SCCell
            cell.avatar?.isHidden = true
            if cellID == "cell"{
                let history = self.likes![indexPath.row - 1] as! HistoryVideo
                cell.preview.sd_setImage(with: URL(string: history.preview!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
            }
            cell.preview.isHidden = cell.reuseIdentifier == "empty"
            return cell
        case .followers?:
            let cellID = indexPath.row == 0 ? "followers_placeholder" : self.followers?.isEmpty ?? true ? "empty" : "cell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SCCell
            if cellID == "cell"{
                let follower = self.followers![indexPath.row-1] as! OwnersModel
                if (follower.video?.count)! > 0 {
                    if let video = follower.video?[0] {
                        cell.preview.sd_setImage(with: URL(string: video.preview!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
                    } else {
                        cell.preview?.sd_setImage(with: URL(string: follower.picture!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
                    }
                } else {
                    cell.preview?.sd_setImage(with: URL(string: follower.picture!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
                }
                cell.avatar?.sd_setImage(with: URL(string: follower.picture!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
            }
            cell.avatar?.isHidden = false
            cell.preview.isHidden = cell.reuseIdentifier == "empty"
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SCCell
            cell.avatar?.isHidden = true
            let history = histories![histories!.count - indexPath.row - 1]
            if history.preview == "placeholder"{
                cell.preview.image = self.delegate?.uploadingVideo?.0
                cell.addCircleView()
            } else {
                if cell.circleView?.superview != nil {
                    cell.circleView?.removeFromSuperview()
                    cell.circleView = nil
                }
            cell.preview.sd_setImage(with: URL(string: history.preview!), placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"), options: [], completed: nil)
            }
            cell.preview.isHidden = cell.reuseIdentifier == "empty"
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.delegate?.activityType {
        case .likes?:
            if indexPath.row == 0 || self.likes?.count == 0 {
                return
            }
            self.delegate?.openLikes(row: indexPath.row-1, likes: self.likes! as! [HistoryVideo])
        case .followers?:
            if indexPath.row == 0 || self.followers?.count == 0 {
                return
            }
            self.delegate?.ownerUser_Action(self.followers![indexPath.row-1] as! OwnersModel)
        default:
            let history = histories![histories!.count - indexPath.row - 1]
            if history.preview == "placeholder" {
                URLSession.shared.cancelTasks()
            } else {
                self.delegate?.openStories(row: indexPath.row, stories: self.histories!)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.delegate?.activityType {
        case .likes? where indexPath.row == 0, .followers? where indexPath.row == 0:
            return CGSize(width: 60.0, height: 98.0)
        case .likes? where self.likes?.count == 0, .followers? where self.followers?.count == 0:
            return CGSize(width: UIScreen.main.bounds.size.width - 120, height: 98.0)
        default:
            return CGSize(width: 56.0, height: 98.0)
        }
    }

    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }

}

extension URLSession {
     func cancelTasks() {
        getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        })
    }
}
