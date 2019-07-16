//
//  MainViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 20.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import KafkaRefresh

enum ListType : Int {
    case owners
    case followers
    case activities
}

enum ActivityType : Int {
    case normal
    case followers
    case likes
}

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var avatar : UIImageView!  // аватар пользователя
    @IBOutlet weak var userName : UILabel!    // никнейм пользователя
    @IBOutlet weak var moreBtn : UIButton!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var subscribeBtn : UIButton!
    @IBOutlet weak var options_arrow : UIImageView!
    
    @IBOutlet weak var notif_likes_view : UIView!
    @IBOutlet weak var notif_follow_view : UIView!
    @IBOutlet weak var notif_likes_label : UILabel!
    @IBOutlet weak var notif_follow_label : UILabel!
    
    @IBOutlet weak var header_panel : UIView!
    
    @IBOutlet weak var isLookingView : UIView!
    
    @IBOutlet weak var followersBtn : UIButton!
    @IBOutlet weak var likesBtn : UIButton!
    //@IBOutlet weak var followersView : UIView!
    //@IBOutlet weak var likesView : UIView!
    
    var firstList : SimpleCollectionCell?
    
    @IBOutlet weak var tableView: UITableView!
    var listType = ListType.owners             // тип контента для ленты 2
    var activityType = ActivityType.normal
    
    let delegate =  UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()
    
    var userHistoryes = Variable<[HistoryVideo]>([HistoryVideo()]) //подписки пользователя
    var userCurrentAStorys = Variable<[SavedVideo]>([SavedVideo]()) //история пользователя
 
    var emailProfile = ""
    var isSaveVideo = false
    
    var hashVideo = ""
    var newLikes = [HistoryVideo]()//новые лайки пользователя
    var newFollowers = [Owners_Model]()// новые подписчики
    
    
    var imagePicker = UIImagePickerController()
    
    //MARK:= Requtst Set Image Profile
    var msg_SetImageProfile = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Get Url Photo Profile
    var msg_GetUrlPhotoProfile = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Get Notification Profile
    var msg_GetNotificationProfile = Variable<NotificationModel>(NotificationModel())
    
    //MARK:- Request Profile Info
    var profileInfo = Variable<UserInfoModel>(UserInfoModel())
    
    //MARK:- Request Historys User
    var historys = Variable<HistorysVideoModel>(HistorysVideoModel())
    
    //MARK:- Request Actuals
    var actuals = Variable<HistorysVideoModel>(HistorysVideoModel())
    
    //MARK:- Request FollowUp
    var msg_followUP = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request UnFollow
    var msg_unFollow = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Famous Users
    var famous_User = Variable<[UsersModel]>([])
    var msg_Famous = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Owners Users
    var owners_User = Variable<[Owners_Model]>([])
    var msg_Owners = Variable<MessageModel>(MessageModel())
    
    //MARK:- Request Owners Users
    var followers_User = Variable<[Owners_Model]>([])
    var msg_Followers = Variable<MessageModel>(MessageModel())
    
    var owners = Variable<[Owners_Model]>([])
    var users = Owner.isOwner
    
    var uploadingVideo : (UIImage,Data?)?
    
    
    //MARK:- Requst ConfirmToSave
    var msg_ConfirmToSave = Variable<MessageModel>(MessageModel())
    var tap: UITapGestureRecognizer?
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.setContentOffset(.zero, animated: false)
        self.moreBtn.isHidden = (self.navigationController?.viewControllers.count)! > 1
        self.subscribeBtn.isHidden = (self.navigationController?.viewControllers.count)! == 1
        self.backBtn.isHidden = (self.navigationController?.viewControllers.count)! == 1
        self.options_arrow.isHidden = (self.navigationController?.viewControllers.count)! == 1
        if emailProfile != ""{
            requiredRequests()
        }
        
        if self.isSaveVideo == true {
            self.listType = .activities
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatar.layer.cornerRadius = 20.0
        self.avatar.layer.borderColor = UIColor.white.cgColor
        self.avatar.layer.borderWidth = 2.0
        
        self.header_panel.layer.cornerRadius = 20.0
        self.header_panel.layer.borderColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
        self.header_panel.layer.borderWidth = 1.0
        self.header_panel.layer.masksToBounds = false
        self.header_panel.layer.shadowRadius = 5.0
        self.header_panel.layer.shadowOpacity = 0.16
        //searchBar.delegate = self
        setupPullToRefresh()
        settingsKeyboard()
        subscribe()
        dataSourceUser()
    }
    
    func setupPullToRefresh(){
        self.tableView.bindHeadRefreshHandler({
            [weak self] in self?.didPullToRefresh()
        }, themeColor: .red, refreshStyle: KafkaRefreshStyle.animatableRing)
        self.tableView.headRefreshControl.stretchOffsetYAxisThreshold = 1
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    
    //MARK:- Перегружаем страницу по свайпу вниз экрана
    @objc func didPullToRefresh() {
        requiredRequests()
    }
    
    //MARK:- Запросы на сервер
    //Запрашиваем все необходимые данные
    @objc func requiredRequests(){
        /*
        msg_GetUrlPhotoProfile.value = MessageModel()
        profileInfo.value = UserInfoModel()
        historys.value = HistorysVideoModel()
        famous_User.value = [UsersModel]([])
        msg_Famous.value = MessageModel()
        
        owners_User.value = [Owners_Model]()
        msg_Owners.value = MessageModel()
        
        followers_User.value = [Owners_Model]()
        msg_Followers.value = MessageModel()*/
      
        //запрос на получения информации о пользователе
        Profile_API.requestProfileInfo(delegate: delegate, email: emailProfile, callback: {[weak self] callback in
            self?.profileInfo.value = callback
            self?.delegate.profileInfo = callback
            if let nickname = callback.nickname {
                self?.userName.text = nickname.trimmingCharacters(in: .whitespaces)
            }
            if let picture = callback.picture {
                self?.avatar.sd_setImage(with: URL(string: picture),
                                         placeholderImage: #imageLiteral(resourceName: "User_placeholder.png"),
                                         options: [], completed: nil) }
        })
        
        //запрос на получения истории пользователя
        self.loadUserHistory()
        
        //получаем подписчиков пользователя
        Profile_API.requestGetFollowers(delegate: delegate, email: emailProfile) { [weak self] (msg, statusCode, followerModel) in
            self?.followers_User.value = followerModel
            let msgFollower = MessageModel()
            msgFollower.msg = msg
            msgFollower.code = statusCode
            self?.msg_Followers.value = msgFollower
            self?.tableView.reloadData()
            self?.updateSubscribeBtn(see: (self?.checkIfSubscribed())!)
        }
        
        //запрос на получения списка подписок пользователя
        Profile_API.requestGetOwners(delegate: delegate, email: emailProfile) { [weak self] (msg, statusCode, ownerModel) in
            self?.owners_User.value = ownerModel
            let msgOwner = MessageModel()
            msgOwner.msg = msg
            msgOwner.code = statusCode
            self?.msg_Owners.value = msgOwner
            self?.tableView.reloadData()
        }
        
        //запрос на получения списка популярных пользователей
        Profile_API.requestFamous(delegate: delegate) {[weak self] (msg, statusCode, usersModel) in
            self?.famous_User.value = usersModel
            let msgF = MessageModel()
            msgF.msg = msg
            msgF.code = statusCode
            self?.msg_Famous.value = msgF
            self?.tableView.reloadData()
        }
        
        //запрос на получения ссылки на фото пользователя
        Profile_API.requestGetUrlPhotoProfile(delegate: delegate, email: emailProfile, callback: {[weak self] callback in
            self?.msg_GetUrlPhotoProfile.value = callback
        })
        
        Profile_API.requestNewLikes(delegate: delegate, email: emailProfile) { [weak self] (msg, statusCode, likes) in
            self?.newLikes = likes
            if self?.activityType == .likes{
            self?.tableView.reloadData()
            }
        }
 
        
        //запрос на получения уведомлений
        Profile_API.requsetNotificationStatus(delegate: delegate) { [weak self] (message) in
            self?.msg_GetNotificationProfile.value = message
            self?.notif_likes_view.isHidden = message.likes == 0
            if let likes = message.likes {
                self?.notif_likes_label.text = "\(likes)"
            }
            self?.notif_follow_view.isHidden = message.followers == 0
            
            if let followers = message.followers {
                self?.notif_follow_label.text = "\(followers)"
            }
        
        }
    }
    
    func requestNewFollowers() {
        Profile_API.requestNewFollowers(delegate: delegate, email: emailProfile) { [weak self] (msg, statusCode, ownerModel) in
            print(ownerModel)
            self!.newFollowers = ownerModel
            self?.tableView.reloadData()
        }
    }
    
    //Универсальный метод для отображения нужного контроллера
    private func transitionVC(identifier: VcStoryboarID, nameStoryboard : Storyboard_Name, str: String?){
        dismissKeyboard()
        let storyboard = UIStoryboard(name: nameStoryboard.rawValue, bundle: nil)
        var vc = UIViewController()
        switch identifier {
        case .camera:
            vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as! CameraViewController
        case .userSetings:
            vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as! ProfileSetingsViewController
            //передаем информацию о пользователе контроллеру настроек
            (vc as! ProfileSetingsViewController).profileInfo = profileInfo
        case .searchViewController:
            //
            vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as! SearchViewController
            (vc as! SearchViewController).searchText = str
        case .mainViewController:
            //загружаем подобный (этому) контроллер
            vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as! MainViewController
            (vc as! MainViewController).emailProfile = str ?? "" //указываем email по которому будут выполнятся необходимые запросы
            (vc as! MainViewController).isSaveVideo = false //запрет на сохранения видео других пользователей
            (vc as! MainViewController).hashVideo = ""
        default:
            print("\(identifier.rawValue) is default")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Плеер
    // открываем контроллер плеера и передаем ему истории пользователя
     func transitionAStory(mail: String, storys: [UsersModel], row: Int, hashVideo : String){
        let storyboard = UIStoryboard(name: Storyboard_Name.VideoPlayer_Stroeyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.PlayerStorys.rawValue) as! PlayerStorysViewController
        vc.emailUser = mail
        vc.story = storys //вся история
        vc.numberPlayVideo = row //текущий выбранный элемент
        vc.hashVideo = hashVideo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // открываем контроллер плеера и передаем ему непросмотренные лайки пользователя
    func likesStory(mail: String, storys: [UsersModel], row: Int, hashVideo : String){
        let storyboard = UIStoryboard(name: Storyboard_Name.VideoPlayer_Stroeyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.PlayerLikes.rawValue) as! PlayerNewLikesViewController
        vc.emailUser = mail
        vc.story = storys //вся история
        vc.numberPlayVideo = row //текущий выбранный элемент
        vc.hashVideo = hashVideo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK:- Галерея
    // Добавить фото профиля из галереи устройства и отправка фото на сервер
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = UIImageJPEGRepresentation(image, 0.3)
            if let imgData = data{
                
                self.showWaitView(isWait: true)
              
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                
                //загрузка фото профиля на сервер
                msg_SetImageProfile.value = MessageModel()
                Profile_API.requestSetImageProfile(delegate: delegate, data: imgData, callback: {[weak self] callback in
                    self?.msg_SetImageProfile.value = callback
                    if let ss = self{
                        ss.showWaitView(isWait: false)
                    }
                })
            }
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    //MARK:- Actions
    
    
    // возврат на пред страницу
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // возврат на пред страницу
    @IBAction func toRootAction(){
        if (self.navigationController?.viewControllers.count)! > 1 {
        self.navigationController?.popToRootViewController(animated: true)
        } else {
            let btn = UIButton()
            btn.tag = ActivityType.normal.rawValue
            self.changeActivityType(sender: btn)
        }
    }
    
    // переход к камере
    @IBAction func camera_Action(_ sender: UIButton) {
        transitionVC(identifier: .camera, nameStoryboard: .Main_Storyboard, str: nil)
    }

    @IBAction func userPhoto_Action(_ sender: UIButton) {
        //изменить фото профиля
        //если текущим отображается собственный профиль пользователя иначе включаем подписку на пользователя или отписку от него
        if emailProfile == AllUserDefaults.getLoginUD() ?? "" && emailProfile != ""{
            let alert = UIAlertController(title: "PoliDash", message: "Источник картинки", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(UIAlertAction(title: "Камера", style: UIAlertActionStyle.default, handler: { [weak self] (act) in
                    if UIImagePickerController.isSourceTypeAvailable(.camera){
                        self?.imagePicker.delegate = self
                        self?.imagePicker.sourceType = .camera;
                        self?.imagePicker.allowsEditing = true
                        if let picker = self?.imagePicker {
                            self?.present(picker, animated: true, completion: nil)
                        }
                    }
                }))
            alert.addAction(UIAlertAction(title: "Фотоальбом", style: UIAlertActionStyle.default, handler: {[weak self]  (act) in
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    self?.imagePicker.delegate = self
                    self?.imagePicker.sourceType = .savedPhotosAlbum;
                    self?.imagePicker.allowsEditing = false
                    if let picker = self?.imagePicker {
                        self?.present(picker, animated: true, completion: nil)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func checkIfSubscribed() -> See{
        var see = See.none
        for item in followers_User.value{
            if let ownerEmail = item.email{
                if ownerEmail == AllUserDefaults.getLoginUD() ?? ""{
                    see = .see
                    break
                }else{
                    see = .no_see
                }
            }
        }
        return see
    }
    
    func updateSubscribeBtn(see:See){
        switch see {
        case .see:
            self.subscribeBtn.setTitle("", for: .normal)
            self.subscribeBtn.setImage(#imageLiteral(resourceName: "subscribed_ico.png"), for: .normal)
        default:
            self.subscribeBtn.setTitle("", for: .normal)
            self.subscribeBtn.setImage(#imageLiteral(resourceName: "subscribe_ico.png"), for: .normal)
        }
    }
    
    @IBAction func subscribeAction(_ sender: UIButton) {
        let see = self.checkIfSubscribed()
        //подписываемся на пользователя
        self.showWaitView(isWait: true)
        //сохраняем состояние на сервере
        if see == .see{
            //отправляем запрос об отписки
            msg_unFollow.value = MessageModel()
            Profile_API.requestSetUnFollow(delegate: delegate, email: emailProfile) { [weak self] (callback) in
                if let ss = self{
                    ss.showWaitView(isWait: false)
                    ss.msg_unFollow.value = callback
                }
            }
            
        }else{
            //отправляем запрос подписаться
            msg_followUP.value = MessageModel()
            Profile_API.requestFollowUp(delegate: delegate, email: emailProfile) { [weak self] (callback) in
                if let ss = self{
                    ss.showWaitView(isWait: false)
                    ss.msg_followUP.value = callback
                }
            }
        }
    }
    
    @IBAction func currentAStorys_Action(_ sender: UIButton) {
        // если текущей страницей открыт собственный профиль пользователя то по нажатию на кнопку добаляем видео в историю пользователя
        if isSaveVideo{
            msg_ConfirmToSave.value = MessageModel()
            self.showWaitView(isWait: true)
            Video_API.requestConfirmToSave(delegate: delegate, hash: hashVideo, circle: String(sender.tag)) { [weak self] (callback) in
                if let ss = self{
                    ss.msg_ConfirmToSave.value = callback
                    ss.showWaitView(isWait: false)
                }
            }
        }
    }
    
    //открыть профиль подписчика по email
    func ownerUser_Action(_ owner:Owners_Model) {
            if let email = owner.email{
                transitionVC(identifier: .mainViewController, nameStoryboard: .Main_Storyboard, str: email)
            }
    }
    

//    открыть профиль популярной личности по email
    func favoritsUser_Action(_ user: UsersModel) {
        if let email = user.email{
            transitionVC(identifier: .mainViewController, nameStoryboard: .Main_Storyboard, str: email)
        }
    }
    
    
    @IBAction func settingsAction(){
        //перейти в управление (настройки) по нажатию на заголовок (имя пользователя) котроллера аккаунта, если текущим отображается собственный профиль пользователя
        if emailProfile == AllUserDefaults.getLoginUD() ?? "" && emailProfile != ""{
            transitionVC(identifier: .userSetings, nameStoryboard: .Main_Storyboard, str: nil)
        }
    }

    @IBAction func action(_ sender: Any) {
        //перейти в управление (настройки) аккаунтом, если текущим отображается собственный профиль пользователя
        if emailProfile == AllUserDefaults.getLoginUD() ?? "" && emailProfile != ""{
            transitionVC(identifier: .userSetings, nameStoryboard: .Main_Storyboard, str: nil)
        }
    }
    
    func openStories(row:Int,stories:[HistoryVideo]){
        let model = stories[row]
        //Формируем модель данных истории пользователя для ее передачи контроллеру воспроизведения истроии
        var userMod = [UsersModel]()
        let uMod = UsersModel()
        uMod.email = self.profileInfo.value.email
        uMod.id = self.profileInfo.value.id
        uMod.last_login = "Сейчас"
        uMod.nickname = self.profileInfo.value.nickname
        uMod.picture = self.profileInfo.value.picture
        //uMod.video = self.userHistoryes.value
        
        var histories = [HistoryVideo]()
        for item in self.userHistoryes.value {
            histories.insert(item, at: 0)
        }
        uMod.video = histories
        
        userMod.append(uMod)
        
        var mail = ""
        if AllUserDefaults.getLoginUD() ?? "" != "" , let first = userMod.first,  AllUserDefaults.getLoginUD()! == first.email ?? ""{
            mail = first.email!
        }
        
        //если полученная модель имеет hash видео то открываем котроллер воспроизведения истории
        if let h = model.hash{
            self.transitionAStory(mail: mail, storys: userMod, row: row, hashVideo: h)
        }
    }
    
    func openLikes(row:Int,likes:[HistoryVideo]){
        let model = likes[row]
        //Формируем модель данных истории пользователя для ее передачи контроллеру воспроизведения истроии
        var userMod = [UsersModel]()
        let uMod = UsersModel()
        uMod.email = self.profileInfo.value.email
        uMod.id = self.profileInfo.value.id
        uMod.last_login = "Сейчас"
        uMod.nickname = self.profileInfo.value.nickname
        uMod.picture = self.profileInfo.value.picture
        //uMod.video = self.userHistoryes.value
    
        var histories = [HistoryVideo]()
        for item in self.newLikes {
            histories.append(item)
        }
        uMod.video = histories
        
        userMod.append(uMod)
        
        var mail = ""
        if AllUserDefaults.getLoginUD() ?? "" != "" , let first = userMod.first,  AllUserDefaults.getLoginUD()! == first.email ?? ""{
            mail = first.email!
        }
        
        //если полученная модель имеет hash видео то открываем котроллер воспроизведения истории
        if let h = model.hash{
            self.likesStory(mail: mail, storys: userMod, row: row, hashVideo: h)
        }
    }
    
    deinit {
        print("deinit MainViewController")
    }
    
    func downloadVideo(image:UIImage, video:Data?){
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidDownload), name: NSNotification.Name("UPLOADING_PROGRESS_DID_END"), object: nil)
        uploadingVideo = (image,video)
        guard let data = UIImageJPEGRepresentation(image, 0.3) else { return }
        Video_API.downloadVideoWithProgress(delegate: self.delegate,
                                            video: video,
                                            image: data,
                                            callback: {[weak self] callback in
            DispatchQueue.main.async {
                if let ss = self {
                        self?.firstList?.collection.reloadData()
                        let progress = callback.progress
                        if progress?.isFinished == true || progress?.isCancelled == true || progress?.fractionCompleted == 1.0 {
                            ss.videoDidDownload()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name("UPLOADING_PROGRESS_DID_CHANGE"), object: nil, userInfo: ["progress":progress?.fractionCompleted as Any])
                            if progress?.fractionCompleted == 1.0 {
                                ss.uploadingVideo = nil
                                ss.loadUserHistory()
                            }
                        }
                        print(callback.progress?.fractionCompleted)
                }
            }
        })
    }
    
    @objc func videoDidDownload(){
        NotificationCenter.default.post(name: NSNotification.Name("UPLOADING_PROGRESS_DID_CHANGE"), object: nil, userInfo: ["progress":1.0 as Any])
        self.uploadingVideo = nil
        self.loadUserHistory()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UPLOADING_PROGRESS_DID_END"), object: nil)
    }
    
    func loadUserHistory(){
        Video_API.requestHistory(delegate: delegate, email: emailProfile, callback: {
            [weak self] callback in
            self?.historys.value = callback
            
            if self?.uploadingVideo != nil {
            let hvm = HistoryVideo()
            hvm.preview = "placeholder"
            self?.historys.value.historys?.insert(hvm, at: 0)
            }
            
            self?.tableView.reloadData()
        })
    }
    
}


extension MainViewController{
//    Наблюдатель изменения ссылки на фото профиля
    private func subscribe(){
        msg_SetImageProfile.asObservable().skip(1).subscribe{
            [weak self] element in
            if let msg = element.element{
                if let code = msg.code, code >= 200 && code < 300{
                    //запрашиваем фото профиля
                    self?.msg_GetUrlPhotoProfile.value = MessageModel()
                    Profile_API.requestGetUrlPhotoProfile(delegate: (self?.delegate)!, email: (self?.emailProfile)!, callback: {[weak self] callback in
                        self?.msg_GetUrlPhotoProfile.value = callback
                    })
                }else{
//                    обработка ошибок сервера
                    if msg.code != nil || msg.msg != nil{
                        if let ss = self{
                            ss.showAlertView(text: msg.msg, callback: {
                                return
                            })
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        
        msg_GetNotificationProfile.asObservable().subscribe{
            [weak self] event in
            if let msg = event.element {
                if let c = msg.msg {
                        self?.isLookingView.isHidden = c
                }
            }
        }
   
//    Наблюдатель получения ссылки на фото профиля
        msg_GetUrlPhotoProfile.asObservable().subscribe{
            [weak self] element in
            if let msg = element.element{
                if let code = msg.code, code >= 200 && code < 300{
                    //все ок
                    if let urlImg = msg.msg{
                        self?.avatar.sd_setImage(with: URL(string: "\(urlImg)"), placeholderImage: UIImage(named: "Placeholder"), options: SDWebImageOptions(rawValue: 0), completed: nil)
                        
                    }
                    else{
                        self?.avatar.image = UIImage(named: "Placeholder")
                    }
                }else{
//                    обработчик ошибок сервера
                    if msg.code != nil || msg.msg != nil{
                        if let ss = self{
                            ss.showAlertView(text: msg.msg, callback: {
                                return
                            })
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)
        
//        Наблюдатель изменения модели информации о пользователе
//        устанавливаем ник пользователя текущему контроллеру
        profileInfo.asObservable().skip(1).subscribe{
            [weak self] element in
            if let infoUser = element.element, let code = infoUser.code, code >= 200 && code < 300{
                self?.userName.text = "\(infoUser.nickname ?? "")".trimmingCharacters(in: .whitespaces)
            }
        }.disposed(by: disposeBag)
        
//        наблюдатель изменения модели историй и сохраненой истории
        historys.asObservable().subscribe{
            [weak self] element in
            if let hist = element.element, let statusCode = hist.statusCode, statusCode >= 200 && statusCode < 300{
                if let listHist = hist.historys{
                    self?.userHistoryes.value = listHist
                }
                if let aStorys = hist.saved{
                    self?.userCurrentAStorys.value = aStorys
                    self?.reloadHorizontalCollection()
                }
            }
        }.disposed(by: disposeBag)
        
//        Наблюдатель сообщающий результат сохранения элемента истории в сохраненные
        msg_ConfirmToSave.asObservable().skip(1).subscribe(onNext: { [weak self] (element) in
            if let statusCode = element.code, statusCode >= 200 && statusCode < 300{
                if let ss = self{
                    ss.isSaveVideo = false
                    ss.showWaitView(isWait: false)
                    if let msg = element.msg{
                        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "ОК", style: UIAlertActionStyle.default, handler: { [weak self] (_) in
                            ss.historys.value = HistorysVideoModel()
                            ss.showWaitView(isWait: true)
//                            Запрашиваем изменную истории с сервера
                            Video_API.requestHistory(delegate: (self?.delegate)!, email: ss.emailProfile, callback: { [weak self] (callback) in
                                if let sss = self{
                                    sss.historys.value = callback
                                    sss.showWaitView(isWait: false)
                                    self?.tableView.reloadData()
                                }
                            })
                        })
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
//                Обработка ошибок сервера
               if let statusCode = element.code, statusCode < 200 || statusCode >= 300, let msg = element.msg{
                    if let ss = self{
                        ss.isSaveVideo = false
                        ss.userCurrentAStorys.value = ss.userCurrentAStorys.value
                        self?.tableView.reloadData()
                        let alert = Auxiliary_PoliDash.showMessage(vc: ss, msg: msg, tittle: "Ошибка", actionBtn: "ОК", callback: {})
                        if let alertController = alert{
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
//        Наблюдатель обработки ошибок всех необходимых запросов
        Observable.zip(profileInfo.asObservable(), msg_GetUrlPhotoProfile.asObservable(), historys.asObservable(), msg_Famous.asObservable(), msg_Owners.asObservable(), msg_Followers.asObservable()){(profileInfo : UserInfoModel, msg_UrlImg: MessageModel, historys: HistorysVideoModel, msg_Popular: MessageModel, msg_Own: MessageModel, msg_Foll: MessageModel) -> (Bool) in
            if let codeInfo = profileInfo.code,
                let codeUrlImg = msg_UrlImg.code,
                let historyCode = historys.statusCode,
                let famousCode = msg_Popular.code,
                let ownersCode = msg_Own.code,
                let followersCode = msg_Foll.code,
                
                codeInfo >= 200 && codeInfo < 300,
                codeUrlImg == 400 || (codeUrlImg >= 200 && codeUrlImg < 300),
                historyCode >= 200 && historyCode < 300,
                famousCode >= 200 && famousCode < 300,
                ownersCode >= 200 && ownersCode < 300,
                followersCode >= 200 && followersCode < 300{
                return true
            }
            return false
            }.observeOn(MainScheduler.instance).subscribe{
                [weak self] value in
                if let status = value.element, status{
                    self?.tableView.headRefreshControl.endRefreshing()
                    return
                }else{
                    if let _ = self?.profileInfo.value.msg, let code = self?.profileInfo.value.code, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    } else if let _ = self?.msg_GetUrlPhotoProfile.value.msg, let code = self?.msg_GetUrlPhotoProfile.value.code, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    } else if let _ = self?.historys.value.error, let code = self?.historys.value.statusCode, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                        
                    } else if let _ = self?.msg_Famous.value.msg, let code = self?.msg_Famous.value.code, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    } else if let _ = self?.msg_Owners.value.msg, let code = self?.msg_Owners.value.code, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    } else if let _ = self?.msg_Followers.value.msg, let code = self?.msg_Followers.value.code, code < 200 || code >= 300{
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    } else {
                        self?.tableView.headRefreshControl.endRefreshing()
                        return
                    }
                }
            }.disposed(by: disposeBag)
        
//        Наблюдатель изменения модели подписок
        msg_followUP.asObservable().skip(1).subscribe(onNext: { [weak self] (element) in
            if let code = element.code, code >= 200 && code < 300{
                if let ss = self{
                    ss.showWaitView(isWait: true)
                    Profile_API.requestGetFollowers(delegate: ss.delegate, email: ss.emailProfile, callback: { (msg, code, model) in
                         ss.showWaitView(isWait: false)
                        ss.followers_User.value = model
                        let msgFollower = MessageModel()
                        msgFollower.msg = msg
                        msgFollower.code = code
                        ss.msg_Followers.value = msgFollower
                    })
                    self?.updateSubscribeBtn(see: See.see)
                    self?.userName.text = "\(ss.profileInfo.value.nickname ?? "")".trimmingCharacters(in: .whitespaces)
                    ss.showAlertView(text: element.msg, callback: {
                        return
                    })
                }
            } else {
//                Обработка ошибок сервера
                if let code = element.code, code < 100 || code >= 300{
                    if let ss = self{
                        ss.showWaitView(isWait: false)
                        self?.updateSubscribeBtn(see: See.none)
                        self?.userName.text = "\(ss.profileInfo.value.nickname ?? "")".trimmingCharacters(in: .whitespaces)
                        ss.showAlertView(text: element.msg, callback: {
                            return
                        })
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
//        Наблюдатель измения модели подписчиков
        msg_unFollow.asObservable().skip(1).asObservable().subscribe(onNext: { [weak self] (element) in
            if let code = element.code, code >= 200 && code < 300{
                if let ss = self{
                    ss.showWaitView(isWait: true)
                    Profile_API.requestGetFollowers(delegate: ss.delegate, email: ss.emailProfile, callback: { (msg, code, model) in
                        ss.showWaitView(isWait: false)
                        ss.followers_User.value = model
                        let msgFollower = MessageModel()
                        msgFollower.msg = msg
                        msgFollower.code = code
                        ss.msg_Followers.value = msgFollower
                    })
                    
                    self?.updateSubscribeBtn(see: See.no_see)
                    self?.userName.text = "\(ss.profileInfo.value.nickname ?? "")".trimmingCharacters(in: .whitespaces)
                    ss.showAlertView(text: element.msg, callback: {
                    })
                }
            } else {
//                Обработка ошибок
                if let code = element.code, code < 100 || code >= 300{
                    if let ss = self{
                        ss.showWaitView(isWait: false)
                        self?.updateSubscribeBtn(see: See.none)
                        self?.userName.text = "\(ss.profileInfo.value.nickname ?? "")".trimmingCharacters(in: .whitespaces)
                        ss.showAlertView(text: element.msg, callback: {
                        })
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

//MARK:- SearchBar
extension MainViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            let custom = searchBar as! SearchBar
            custom.searchButton?.isHidden = false
            custom.isHidden = true
            searchBar.endEditing(true)
            tap?.isEnabled = false
            transitionVC(identifier: .searchViewController, nameStoryboard: .Main_Storyboard, str: searchText)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tap?.isEnabled = true
        /*let cell = searchBar.superview?.superview?.superview as? UITableViewCell
            // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
        if let cell = cell, let index = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: index, at: .top, animated: true)
        }*/
    }
    
}

extension MainViewController {
    //MARK: - Настройка дейстий с клавиатурой
    func settingsKeyboard(){
        //event open keyboard
        registerForKeyboardNotification()
        
        //dissmis keyboard
        tap = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard))
        tap?.isEnabled = false
        
        //event свернуть клавиатуру если был тап в пустую область
        view.addGestureRecognizer(tap!)
    }
    
    func registerForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        print(tableView.contentInset)
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height-16
        tableView.contentInset = contentInset
        print(contentInset)
        
    }
    
    @objc func kbWillHide(_ notification: Notification){
        tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y)
        tableView.contentInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //scrollView.resignFirstResponder() //прячем клавиатуру
        tap?.isEnabled = false
        //removeNotificationKeyBoard()
        view.endEditing(true)
    }
    
    func removeNotificationKeyBoard(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            let count : Int = self.contentForFirstList().count
            return self.activityType != .normal ? 98 : count == 0 ? 0 : 98
        case 1,3:
            return 35
        case 2:
            //настройка ширины ленты номер 2 в зависимости от количества элементов в списке
            var models = 0
            switch self.listType {
            case .owners:
                models = self.owners_User.value.count
            case .activities:
                models = self.userCurrentAStorys.value.count + (self.isSaveVideo == true ? 1 : 0)
            default:
                models = self.followers_User.value.count
            }
            return models == 0 ? 0 : models < 6 ? UIScreen.main.bounds.size.width * 0.67 - 14 : UIScreen.main.bounds.size.width-20
        case 4:
            //настройка высоты ленты номер 3 в зависимости от количества элементов в списке
            let count = self.famous_User.value.count
            if count == 0 {
                return 0.0
            } else {
                let delta = count % 9
                let rows = count / 9
                let dif = delta == 0 ? 0 : delta < 6 ?  UIScreen.main.bounds.size.width * 0.67 : UIScreen.main.bounds.size.width
                return UIScreen.main.bounds.size.width * CGFloat(rows) + dif
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! SimpleCollectionCell
            cell.delegate = self
            self.configureFirstListCell(cell: cell)
            if firstList == nil {
                firstList = cell
            }
            return cell
        case 1:
            //смена тайтла для ленты 2, в зависимосты от выбраного типа контента
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MainViewHeaderCell
            switch self.listType {
            case .owners:
                let count = self.owners_User.value.count
                cell.label.text = "ПОДПИСКИ" + (count > 0 ? " \(count)" : "")
            case .activities:
                let count = self.userCurrentAStorys.value.count
                cell.label.text = "АКТУАЛЬНЫЕ" + (count > 0 ? " \(count)" : "")
            default:
                let count = self.followers_User.value.count
                cell.label.text = "ПОДПИСЧИКИ" + (count > 0 ? " \(count)" : "")
            }
            
            return cell
        case 2:
            //отображение контента ленты 2, в зависимосты от выбраного типа контента
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! MainViewHorizontalCollectionCell
            cell.delegate = self
            switch self.listType {
            case .owners:
                cell.users = self.owners_User.value
            case .activities:
                cell.videos = self.userCurrentAStorys.value
            default:
                cell.users = self.followers_User.value
            }
            cell.isSaveVideo = self.isSaveVideo
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! MainViewHeaderCell
            cell.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as! MainViewVerticalCollectionCell
            cell.delegate = self
            cell.models = self.famous_User.value
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! MainViewHeaderCell
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if listType == .followers {
                self.listType = .activities
            } else if listType == .owners {
                self.listType = .followers
            } else if listType == .activities {
                self.listType = .owners
            }
            /*CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.tableView.reloadData()
            })
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            CATransaction.commit()*/
             self.tableView.reloadData()
        }
    }
    
    private func dataSourceUser(){
        //MARK:- Data Source Current AStorys CollectionView
        //        Наблюдатель изменения модели сохраненной истории
        let collectionView = (tableView.dequeueReusableCell(
            withIdentifier: "cell3",
            for: IndexPath.init(row: 3,
                                section: 0)) as! MainViewHorizontalCollectionCell).collection
        userCurrentAStorys.asObservable().map { [weak self] (savedVideo) -> [SavedVideo] in
            if savedVideo.count == 0 && !(self?.isSaveVideo)!{
                return [SavedVideo]()
            } else {
                if self?.isSaveVideo ?? false {
                    var newSavedVideo = [SavedVideo]()
                    newSavedVideo = savedVideo
                    newSavedVideo.append(SavedVideo())
                    return newSavedVideo
                } else {
                    return savedVideo
                }
            }
        }
    }
    
    func openActualStory(model:SavedVideo){
        var sModel = [UsersModel]()
        for currentSt in (self.userCurrentAStorys.value){
            if currentSt.videos != nil, currentSt.videos!.count > 0{
                let uModel = UsersModel()
                uModel.email = self.profileInfo.value.email
                uModel.id = self.profileInfo.value.id
                uModel.last_login = "Сейчас"
                uModel.nickname = self.profileInfo.value.nickname
                uModel.picture = self.profileInfo.value.picture
                uModel.video = currentSt.videos
                sModel.append(uModel)
            }
        }
        
        var mail = ""
        if AllUserDefaults.getLoginUD() ?? "" != "" ,
            let first = sModel.first,
            let allUserDefaults = AllUserDefaults.getLoginUD(),
            allUserDefaults == first.email ?? "" {
            mail = first.email!
        }
        if let videos = model.videos, videos.count > 0,
            let video = videos.first {
            self.transitionAStory(mail: mail, storys: sModel, row: 0, hashVideo: video.hash ?? "")
        }
    }
    
    
    // Перегружаем горизонтальную коллекцию
    func reloadHorizontalCollection(){
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: IndexPath(row: 2, section: 0)) as? MainViewHorizontalCollectionCell {
            cell.isSaveVideo = self.isSaveVideo
        }
    }
    
    
    
    @IBAction func  changeActivityType(sender:UIButton){
        self.followersBtn.tintColor = UIColor.init(white: 0.4627, alpha: 1.0)
        self.likesBtn.tintColor = UIColor.init(white: 0.4627, alpha: 1.0)
        let type = ActivityType(rawValue: sender.tag)
        if self.activityType == type {
            self.activityType = .normal
            sender.tintColor = UIColor.init(white: 0.4627, alpha: 1.0)
        } else {
            self.activityType = type!
            sender.tintColor = .red
        }
        
        if self.activityType == .followers {
            self.requestNewFollowers()
        } else {
            self.tableView.reloadData()
        }
    }
    
    func contentForFirstList()->[AnyObject]{
        switch self.activityType {
        case .likes:
            return self.newLikes
        case .followers:
            return self.newFollowers
        default:
            if let content = self.historys.value.historys {
                return content
            }
            return [HistoryVideo]()
        }
    }
    
    
    func configureFirstListCell(cell:SimpleCollectionCell){
        switch self.activityType {
        case .likes:
            cell.likes = self.contentForFirstList()
        case .followers:
            cell.followers = self.contentForFirstList()
        default:
            cell.histories = self.contentForFirstList() as? [HistoryVideo]
        }
    }
}
