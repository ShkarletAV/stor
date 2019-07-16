//
//  SearchViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 30.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import KafkaRefresh

class SearchViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()
    
    //MARK:- Request Search User
    var searchUsers = Variable<[UsersModel]>([])
    
    @IBOutlet weak var indicator: UIActivityIndicatorView! //default is Hidden
    
    @IBOutlet weak var tableViewUsers: UITableView!
    
    var searchText: String?
//    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        setupPullToRefresh()
        
//        if !refreshControl.isRefreshing{
//            refreshControl.beginRefreshing()
//        }
        requiredRequest()
    }
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func requiredRequest(){
        if let searchT = searchText{
//            Запросить пользователя по нику
            Profile_API.requestSearchUsers(delegate: delegate, nickName: searchT, callback: {[weak self] (msg, statusCode, searchModel) in
                self?.tableViewUsers.headRefreshControl.endRefreshing()
                self?.searchUsers.value = searchModel
            })
        }
    }
    
//    Перегрузить таблицу
    @objc func didPullToRefresh() {
        print("Refersh")
//        refreshControl.endRefreshing()
        requiredRequest()
    }
    
//    Настрока анимации pull to refresh
    func setupPullToRefresh(){
        self.tableViewUsers.bindHeadRefreshHandler({
            [weak self] in self?.didPullToRefresh()
            }, themeColor: UIColor.red, refreshStyle: KafkaRefreshStyle.animatableRing)
        self.tableViewUsers.headRefreshControl.stretchOffsetYAxisThreshold = 1
    }
    
    
//    переходим к профилю пользователя
    private func transitionVC(email: String){
        let storyboard = UIStoryboard(name: Storyboard_Name.Main_Storyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.mainViewController.rawValue) as! MainViewController
        vc.emailProfile = email
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    открываем истории пользователя
    private func transitionAStory(mail: String, storys: [UsersModel], row: Int, hashVideo : String){
        let storyboard = UIStoryboard(name: Storyboard_Name.VideoPlayer_Stroeyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.PlayerStorys.rawValue) as! PlayerStorysViewController
        vc.emailUser = mail
        vc.story = storys
        vc.numberPlayVideo = row
        vc.hashVideo = hashVideo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK:- Actions
    @IBAction func userCell_Action(_ sender: UIButton) {
        let row = sender.tag
        if row < searchUsers.value.count{
            if let email = searchUsers.value[row].email{
                transitionVC(email: email)
            }
        }
    }
    
    
    deinit{
        print("SearchViewController is deinit")
    }
}

extension SearchViewController: UITableViewDelegate, UICollectionViewDelegate{
    func subscribe(){
//        Наблюдатель изменения модели пользователей
        searchUsers.asObservable().bind(to: tableViewUsers.rx.items){
            [unowned self] (tableView, row, model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.userCellID.rawValue) as! UsersTableViewCell
            cell.titleName_Label.text = model.nickname
            cell.user_Button.tag = row
            if let urlImg = model.picture{
                cell.userPhoto_Image.sd_setImage(with: URL(string: "\(urlImg)"), placeholderImage: UIImage(named: "User_placeholder"), options: SDWebImageOptions(rawValue: 0), completed: nil)
            }
            else{
                cell.userPhoto_Image.image = UIImage(named: "User_placeholder")
            }
            
            if let videos = model.video{
//                Наблюдатель измения историй
                Observable.just(videos).asObservable().bind(to: cell.collectionViewStorys!.rx.items){
                    (collectionView, rowCollection, data) in
                    let indexPath = IndexPath(row: rowCollection, section: 0)
                    let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.storysCellID.rawValue, for: indexPath) as! StoryCollectionViewCell
                    if let urlImg = data.preview{
                        cell2.imagePreview_Image.sd_setImage(with: URL(string: "\(urlImg)"), placeholderImage: UIImage(named: "Placeholder"), options: SDWebImageOptions(rawValue: 0), completed: nil)
                    }
                    else{
                        cell2.imagePreview_Image.image = UIImage(named: "Placeholder")
                    }
                    return cell2
                }.disposed(by: cell.disposeBagCell)
            }
            
//          наблюдатель выбора истории
            Observable.zip(cell.collectionViewStorys.rx.itemSelected, cell.collectionViewStorys.rx.modelSelected(HistoryVideo.self)).bind{ [unowned self] (indexPath, mod) in
                var uMod = [UsersModel]()
                for item in self.searchUsers.value{
                    if item.video != nil, item.video!.count > 0{
                        uMod.append(item)
                    }
                }
//                воспроизводим историю если имеется hash у выбранного видео
                if let h = mod.hash{
                    self.transitionAStory(mail: "", storys: uMod, row: indexPath.row, hashVideo: h)
                }
            }.disposed(by: cell.disposeBagCell)
            
            return cell
        }.disposed(by: disposeBag)
    }
    
}
