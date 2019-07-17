//
//  MainViewHorizontalCollectionCell.swift
//  PoliDash
//
//  Created by Ігор on 2/22/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class MainViewHorizontalCollectionCell: UITableViewCell {
     @IBOutlet weak var collection: UICollectionView!
    weak var delegate: MainViewController?
    var itemsCount = 0
    var cellsCount = 0
    var isActuals = false
    var isSaveVideo = false {
        didSet {
            cellsCount = itemsCount / 9 + (itemsCount % 9 == 0 ? 0 : 1)
            if isSaveVideo == true && isActuals {
                itemsCount += 1
                cellsCount = itemsCount / 9 + (itemsCount % 9 == 0 ? 0 : 1)
                collection.reloadData()
            }
        }
    }

    var users: [OwnersModel]? {
        didSet {
            isActuals = false
            itemsCount = (self.users?.count)!
            cellsCount = (self.users?.count)! / 9 + ((users?.count)! % 9 == 0 ? 0 : 1)
            self.collection.reloadData()
        }
    }

    var videos: [SavedVideo]? {
        didSet {
            isActuals = true
            itemsCount = (self.videos?.count)!
            cellsCount = (self.videos?.count)! / 9 + ((videos?.count)! % 9 == 0 ? 0 : 1)
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

extension MainViewHorizontalCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MozaikCell
        cell.indexCell = indexPath.row
        cell.delegate = self.delegate
        if self.isActuals == true {
            cell.videos = self.videosForCell(index: indexPath.row)
        } else {
            cell.owners = self.ownersForCell(index: indexPath.row)
        }
        cell.isSaveVideo = self.isSaveVideo
        cell.loadDelegate()
        return cell
    }

    func ownersForCell(index: Int) -> [OwnersModel] {
        let min = index * 9
        let max = (index + 1) * 9
        if (self.users?.count)! > max {
            let arraySlice = self.users?[min..<max]
            return Array(arraySlice!)
        } else {
            let arraySlice = self.users?[min...]
            return Array(arraySlice!)
        }
    }

    func videosForCell(index: Int) -> [SavedVideo] {
        let min = index * 9
        let max = (index + 1) * 9
        if (self.videos?.count)! > max {
            let arraySlice = self.videos?[min..<max]
            return Array(arraySlice!)
        } else {
            let arraySlice = self.videos?[min...]
            return Array(arraySlice!)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = UIScreen.main.bounds.size.width + 1
        let count = itemsCount / 9
        let delta = itemsCount % 9
        if indexPath.row < count {
        return CGSize(width: side, height: side)
        } else {
            switch delta {
            case 3:
                return CGSize(width: side*0.8, height: side)
            case 2:
                return CGSize(width: side*0.6, height: side)
            case 1:
                return CGSize(width: side*0.4, height: side)
            default:
                return CGSize(width: side, height: side)
            }
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
        return 1.0
    }

}
