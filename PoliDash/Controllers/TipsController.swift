//
//  TipsController.swift
//  PoliDash
//
//  Created by Ігор on 2/28/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class TipsController: UIViewController {
    @IBOutlet weak var collection : UICollectionView!
    @IBOutlet weak var pageControll : UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // увеличение стандартного UIPageControl
        self.pageControll.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        // проверяем, если приложение уже открывалось - отображаем экран авторизации, иначе отображаем туториал
        let opened = AllUserDefaults.getOpenUD()
        if opened == true {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "login") as! AuthController
            controller.showSplash = true
            self.navigationController?.pushViewController(controller, animated: false)
        } else {
            AllUserDefaults.saveOpenUD()
        }
    }
    
    // переход на страницу авторизации
    @IBAction func authAction(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "login")
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    // переход на страницу регистрации
    @IBAction func regAction(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "reg")
        self.navigationController?.pushViewController(controller!, animated: true)
    }
}

extension TipsController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath)
            return cell
        }
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = self.collection.frame.size.width
        let h = self.collection.frame.size.height
        return CGSize(width: w, height: h)
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
        return 0.0
    }
}

extension TipsController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = self.collection.contentOffset.x/UIScreen.main.bounds.size.width
        self.pageControll.currentPage = Int(page)
    }
}

