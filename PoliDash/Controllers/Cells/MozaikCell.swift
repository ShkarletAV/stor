//
//  MozaikCell.swift
//  PoliDash
//
//  Created by Ігор on 2/22/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import ADMozaicCollectionViewLayout

enum ADMozaikLayoutType {
    case portrait
    case landscape
}

class MozaikCell: UICollectionViewCell, ADMozaikLayoutDelegate, UICollectionViewDataSource {
    fileprivate let ADMozaikCollectionViewLayoutExampleImagesCount = 22
    @IBOutlet var mozaikLayout: ADMozaikLayout!
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var layoutType: ADMozaikLayoutType = .portrait
    weak var delegate: MainViewController?
    var itemsCount = 0
    var indexCell = 0
    var isActuals = false
    var isSaveVideo = false {
        didSet {
            if self.isSaveVideo == true && self.isActuals == true {
                self.itemsCount = itemsCount + 1
                self.collectionView.reloadData()
            }
        }
    }

    var owners: [OwnersModel]? {
        didSet {
            self.isActuals = false
            self.itemsCount = (self.owners?.count)!
            self.collectionView.reloadData()
        }
    }

    var videos: [SavedVideo]? {
        didSet {
            self.isActuals = true
            self.itemsCount = (self.videos?.count)!
            self.collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //mozaikLayout.delegate = self
    }

    fileprivate var portraitLayout: ADMozaikLayout {
        let layout = ADMozaikLayout(delegate: self)
        return layout
    }

    fileprivate var landscapeLayout: ADMozaikLayout {
        let layout = ADMozaikLayout(delegate: self)
        return layout
    }

    func loadDelegate() {
         self.setCollectionViewLayout(animated: false, of: layoutType)
        self.collectionView.reloadData()
    }

    fileprivate func setCollectionViewLayout(animated: Bool, of type: ADMozaikLayoutType) {
        self.collectionView.collectionViewLayout.invalidateLayout()
        if type == .landscape {
            self.collectionView.setCollectionViewLayout(self.landscapeLayout, animated: animated)
        } else {
            self.collectionView.setCollectionViewLayout(self.portraitLayout, animated: animated)
        }
    }

    func collectionView(_ collectionView: UICollectionView, mozaik layout: ADMozaikLayout, mozaikSizeForItemAt indexPath: IndexPath) -> ADMozaikLayoutSize {
        if indexPath.item == 0 || indexPath.item == 5 || indexPath.item % 9 == 0 || ((indexPath.item - 5) % 9) == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 2, numberOfRows: 2)
        } else {
            return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isActuals == true && self.isSaveVideo == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SaveStoryCell", for: indexPath) as? UserSaveStoryCell
            if (self.videos?.count)! > indexPath.row {
                cell?.video = self.videos![indexPath.row]
            } else {
                cell?.bgImage.image = nil
            }
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ADMozaikLayoutCell", for: indexPath) as? UserMozaikCell
            if self.isActuals == true {
                cell?.video = self.videos![indexPath.row]
            } else {
                cell?.owner = self.owners![indexPath.row]
            }
            return cell!
        }
    }

    func collectonView(_ collectionView: UICollectionView, mozaik layoyt: ADMozaikLayout, geometryInfoFor section: ADMozaikLayoutSection) -> ADMozaikLayoutSectionGeometryInfo {
        let rowHeight: CGFloat = (UIScreen.main.bounds.size.width-23.2) / 3.0
        let rowWidth: CGFloat = (UIScreen.main.bounds.size.width-6.2) / 5.0
        let columns = [ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth)]
        let geometryInfo = ADMozaikLayoutSectionGeometryInfo(rowHeight: rowHeight,
                                                             columns: columns,
                                                             minimumInteritemSpacing: 1.2,
                                                             minimumLineSpacing: 0.8,
                                                             sectionInset: UIEdgeInsets(top: 0, left: 1.2, bottom: 0, right: 1.2),
                                                             headerHeight: 0, footerHeight: 0)
        return geometryInfo
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isActuals == true {
            if self.isSaveVideo == false {
            self.delegate?.openActualStory(model: self.videos![indexPath.row])
            } else {
                let btn = UIButton()
                if indexPath.row < (self.videos?.count)! {
                    btn.tag = self.videos![indexPath.row].id!
                } else {
                    btn.tag = maxStoryID()
                }
                self.delegate?.currentAStorys_Action(btn)
            }
        } else {
            let owner = self.owners![indexPath.row]
            self.delegate?.ownerUser_Action(owner)
        }
    }

    func maxStoryID() -> Int {
        var idVideo = 0
        for item in (self.delegate!.userCurrentAStorys.value) {
            if let itemId = item.id, idVideo < itemId {
                idVideo = itemId
            }
        }
        idVideo += 1
        return idVideo
    }
}
