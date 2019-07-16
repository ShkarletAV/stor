//
//  MainViewVerticalCollectionCell.swift
//  PoliDash
//
//  Created by Ігор on 2/22/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import ADMozaicCollectionViewLayout
import SDWebImage

class MainViewVerticalCollectionCell: UITableViewCell, ADMozaikLayoutDelegate, UICollectionViewDataSource {
    fileprivate let ADMozaikCollectionViewLayoutExampleImagesCount = 22
    @IBOutlet var mozaikLayout: ADMozaikLayout!
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var layoutType: ADMozaikLayoutType = .portrait
    weak var delegate: MainViewController?
    var models: [UsersModel]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadDelegate()
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
        return (models?.count)!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ADMozaikLayoutCell", for: indexPath) as? UserMozaikCell
        cell?.user = self.models![indexPath.row]
        return cell!
    }

    func collectonView(_ collectionView: UICollectionView, mozaik layoyt: ADMozaikLayout, geometryInfoFor section: ADMozaikLayoutSection) -> ADMozaikLayoutSectionGeometryInfo {
        let rowHeight: CGFloat = (UIScreen.main.bounds.size.width-3.2) / 3.0
        let rowWidth: CGFloat = (UIScreen.main.bounds.size.width-7.2) / 5.0
        let columns = [ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth), ADMozaikLayoutColumn(width: rowWidth)]
        let geometryInfo = ADMozaikLayoutSectionGeometryInfo(rowHeight: rowHeight,
                                                             columns: columns,
                                                             minimumInteritemSpacing: 1.2,
                                                             minimumLineSpacing: 0.8,
                                                             sectionInset: UIEdgeInsets(top: 0, left: 1.2, bottom: 0, right: 1.2),
                                                             headerHeight: 0, footerHeight: 0)
        return geometryInfo
    }

    func storyPreview(user: UsersModel) -> String? {
        var url: String?
        if (user.video?.count)! > 0 {
            url = user.video?[0].preview
        } else if user.picture != nil {
            url = user.picture
        }
        return url
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.favoritsUser_Action(models![indexPath.row])
    }

}
