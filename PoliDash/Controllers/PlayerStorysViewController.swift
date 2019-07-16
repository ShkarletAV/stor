//
//  PlayerStorysViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 27.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage
import Repeat
import Digger
import Photos
import Toaster


class CustomView: UIView {
    
}


class PlayerStorysViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var heart_btn: UIImageView!
    
    
    @IBOutlet weak var likes_View: UIView!
    @IBOutlet weak var overlayView: CustomView!
    @IBOutlet weak var image_ContainerView: UIView!
    @IBOutlet weak var more_Button: UIButton!
    @IBOutlet weak var countLike_Label: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var photoUser_Image: RoundedUIImageView!
    @IBOutlet weak var date_Label: UILabel!
    @IBOutlet weak var name_Label: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var countHeart: UILabel!
    @IBOutlet weak var buttonsView : UIStackView!
    
    var statusBar: UIView!
    
    var stateControl = PlayerControl.play
    var isDoubleTap = false
    
    var emailUser = ""
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()
    
    var indexUserStory = 0
    var numberPlayVideo = 0
    var hashVideo = ""
    var story = [UsersModel]()
    var sympathyData = Sympathy_Model()
    
    var doubleTapRecognizer : UITapGestureRecognizer? = nil
    var tapRecognizer : UITapGestureRecognizer? = nil
    var swipeRecognizer  : UISwipeGestureRecognizer? = nil
    var closeSwipeRecognizer  : UISwipeGestureRecognizer? = nil
    var longRecognizer : UILongPressGestureRecognizer? = nil
    
    
    var updateUrl : ((String, Int) -> ())? = nil
    var updateUrlImage : ((String) -> ())? = nil
    var updateContol : ((PlayerControl) -> ())? = nil
    var updateContolImage : ((PlayerControl) -> ())? = nil
    var updateStopVideo : (() -> ())? = nil
    
    
    var timerImagePlay : Repeater?
    
    var currentProgress = UIProgressView()
    var isPlayVideo = false
    
    var flipping = DurationFlipping.next
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.avPlayerStrory.rawValue {
//          события проигрывания видео роликов
            if let vc = segue.destination as? AVPlayerStroryViewController {
//                событие окончания видео
                vc.videoEnd = {
                    [weak self] v in
                    self?.videoEnd(status: v)
                }
//                событие измения воспроизведения текущего видео
                updateUrl = {url, duration in
                    vc.getURL(url: url, duration: duration )
                }
                
//               событие изменения текущего времени
                vc.updateTime = {
                    [weak self] time, duration in
                    self?.updateTime(time: time, duration: duration)
                }
               
//                событие свайпа следующее, предидущее, плей, пауза
                updateContol = {
                    control in
                    vc.getPlayerContol(control: control)
                }
                
//                событие проигрывание предидущего видео
                vc.videoPrevious = {
                    [weak self] in
                    self?.updatePreviousVideo()
                }
                
//                событие остановки видео
                updateStopVideo = {
                    vc.updateStopVideo()
                }
                
            }
        }else{
//            события проигрывания фото
            if segue.identifier == SegueID.imagePlayer.rawValue{
                if let vc = segue.destination as? ImagePlayerViewController{
//                событие измения воспроизведения текущего видео
                    updateUrlImage = {url in
                        vc.getURL(url: url)
                    }
                    
//               событие измения текущего времени
                    vc.updateTime = {
                        [weak self] (time, duration) in
                        self?.updateTime(time: time, duration: duration)
                    }
                    
//                    событие окночания воспроизведения
                    vc.videoEnd = {
                        [weak self] (status) in
                        self?.videoEnd(status: status)
                    }
                    
//                  событие свайпа следующее, предидущее, плей, пауза
                    updateContolImage = {
                        control in
                        vc.getPlayerContol(control: control)
                    }

//                событие проигрывание предидущего видео
                    vc.videoPrevious = {
                        [weak self] in
                        self?.updatePreviousVideo()
                    }
                }
            }
        }
    }
    
//    отображаем прогресс проигрывания эелемента по времени
    func updateTime(time:Double, duration: Double) {
        if duration.isNaN && stateControl == .play{
            currentProgress.progress = 0.0
            indicator.isHidden = false
            if isPlayVideo{
                indicator.color = UIColor.white
            }else{
                indicator.color = UIColor.black
            }
        }else{
            let newProgress = Float(time/Double(duration))
            if  stateControl == .pause || currentProgress.progress != newProgress{
                indicator.isHidden = true
                currentProgress.progress = newProgress
            }else{
                indicator.isHidden = false
                if isPlayVideo{
                    indicator.color = UIColor.white
                }else{
                    indicator.color = UIColor.black
                }
            }
        }
    }
    
    func videoEnd(status: Bool){
        nextVideo()
        playing()
    }
    
    func updatePreviousVideo(){
        previousVideo()
        playing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
        statusBar.isHidden = true
        stateControl = .play
        //  если видео то продолжаем воспроизводить
        if let pContol = updateContol, isPlayVideo{
            pContol(.play)
        }else{
            // если фото то продолжаем воспроизведение и стираем окружность для поиска лайков
            if let pContol = updateContolImage{
                pContol(.play)
            }
        }
        self.loadCircles()
    }
    
    func loadCircles(){
        Profile_API.requestCircles(delegate: delegate, email: AllUserDefaults.getLoginUD()!) { (_, _, circles) in
            for btn in self.buttonsView.arrangedSubviews {
                btn.isHidden = true
            }
            var i = 0
            for owner in circles {
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).owner = owner
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).isHidden = false
                i = i + 1
            }
        }
    }
    
    @IBAction func selectRound(sender:RoundButton){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC_ID") as! MainViewController
        dismissKeyboard()
        if let email = sender.owner?.email{
            vc.emailProfile = email
            vc.isSaveVideo = false
            vc.hashVideo = ""
            let nav = self.navigationController
            
            stateControl = .pause
            if let pContol = updateContol, isPlayVideo{
                pContol(.pause)
            }else{
                //                ставивим на паузу если фото и рисуем окружность для поиска лайков
                if let pContol = updateContolImage{
                    pContol(.pause)
                }
            }
            
            //nav?.popViewController(animated: false)
            nav?.pushViewController(vc, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//   Получаем номер видео в массиве историй с которого требуется начать воспроизводить контент
//   если видео не удалось найти по hash то воспроизведения истории начинается с первого элемента в истории
    private func getIndexUserStory(){
        var userIter = 0
        for uStory in story{
            if let uStoryVideo = uStory.video{
                if uStoryVideo.count > numberPlayVideo, let hUserStoryHash = uStoryVideo[numberPlayVideo].hash, hUserStoryHash == hashVideo{
                    indexUserStory = userIter
                    return
                }
            }
            userIter += 1
        }
        userIter = 0
    }
    
//  создаем колличство прогрессов воспроизведения по колличеству элементов в истории и добавляем их в стек
    private func createProgress(){
        if self.story.count > 0,  self.story.count > indexUserStory, let sVideo = self.story[indexUserStory].video, sVideo.count > 1{
//            начинаем с двух так как в стеке всегда есть один прогресс бар
            for _ in 2 ... sVideo.count{
                let progressView = UIProgressView()
                progressView.progressTintColor = UIColor.white
                progressView.progress = 0.0
                progressStack.addArrangedSubview(progressView)
            }
        }
    }
    
//    заполняем прогрессы для элементов которые были пропущены
    private func selectProgress(){
        var itr = 0
        for item in progressStack.arrangedSubviews{
            if itr == numberPlayVideo{
                currentProgress = item as! UIProgressView
                currentProgress.progress = 0
            }else{
                if itr < numberPlayVideo{
                    (item as! UIProgressView).progress = 1.0
                }else{
                    (item as! UIProgressView).progress = 0.0
                }
            }
            itr += 1
        }
    }
    
    //MARK:-    Получаем список лайков
    private func getSympathy(){
        if let hashVideo = getHashVideo(){
//            запрос на сервер для получения списка лайков
            Video_API.requestGetSympathy(delegate: delegate, hash: hashVideo) { [weak self] (sympaty) in
                if let countLike = sympaty.count{
                    if let ss = self{
                        ss.countLike_Label.text = String(countLike)
                        ss.sympathyData = sympaty
                        ss.likes_View.removeAllSubviews()
                        ss.drawAllHearts(xH: nil, yH: nil, put: false)
                    }
                }
            }
        }
    }
    
//    Отправляем координаты поставленного лайка
    private func putSympathyVideo(){
        if let hashVideo = getHashVideo(){
            Video_API.requestPutSympathy(delegate: delegate, hash: hashVideo, action: .like, cx: "0", cy: "0") { [weak self] (messageModel) in
                if let code = messageModel.code, code >= 200, code < 300, let msg = messageModel.msg{
                    if let ss = self{
                        ss.showAlertView(text: msg, callback: {})
                        ss.getSympathy()
                    }
                }else{
                    if let code = messageModel.code, code < 200 || code >= 300, let msg = messageModel.msg{
                        if let ss = self{
                            ss.showAlertView(text: msg, callback: {})
                        }
                    }
                }
            }
        }
    }
    
//    Получить hash воспроизводимого элемента
    private func getHashVideo() -> String?{
        if let sVideo = getVideos(){
            if let hashVideo = sVideo[numberPlayVideo].hash{
                return hashVideo
            }
        }
        return nil
    }
 
//    Получить видео истории
    private func getVideos() -> [HistoryVideo]?{
        if self.story.count > indexUserStory && indexUserStory >= 0{
            if let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo{
                return sVideo
            }
        }
        return nil
    }
    
    
    func playing(){
        selectProgress() //установка прогресса для текущего и предедущих видео
        if let usv = updateStopVideo{
            usv() //передаем контейнеру информацию об остановки текущего воспроизведения
        }
        if self.story.count > indexUserStory && indexUserStory >= 0{
            if let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo{
//                если воспроизводимый контент является видео
                if let urlVideo = sVideo[numberPlayVideo].video, urlVideo != "", let duration = sVideo[numberPlayVideo].duration{
                    //получаем координаты лайков для теущего воспроизведения
                    getSympathy()
                    DispatchQueue.main.async {
//                        показываем контейнер с видео проигрывателем
                        self.containerView.isHidden = false
//                        скрываем контейнер с фото проигрывателем
                        self.image_ContainerView.isHidden = true
                    }
                    isPlayVideo = true
                    stateControl = .play
                    if let upUrl = updateUrl{
//                        передаем ссылку на видео и длительность видео контейнеру
                        upUrl(urlVideo, duration)
                    }
                }
                else{
//                    если воспроизводимый контент является фото
                     //получаем координаты лайков для теущего воспроизведения
                    getSympathy()
                    DispatchQueue.main.async {
//                      скрываем контейнер с видео проигрывателем
                        self.containerView.isHidden = true
//                      показываем контейнер с фото проигрывателем
                        self.image_ContainerView.isHidden = false
                    }
                    isPlayVideo = false
                    stateControl = .play
                    if let prew = sVideo[numberPlayVideo].preview{
                        if let upUrl = updateUrlImage{
                            upUrl(prew)
                        }
                    }else{
                        if let upUrl = updateUrlImage{
                            upUrl("")
                        }
                    }
                }
            }
        }
    }
    
//  Если истории пользователей закончились открываем истории следующего в списке пользователя и начинаем воспроизводить с первого элемента
    private func transitionVC(storys: [UsersModel], row: Int, hashVideo: String){
        if let nav = self.navigationController{
            var vcArray = nav.viewControllers
            let storyboard = UIStoryboard(name: Storyboard_Name.VideoPlayer_Stroeyboard.rawValue, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.PlayerStorys.rawValue) as! PlayerStorysViewController
            vc.story = storys
            vc.numberPlayVideo = row
            vc.hashVideo = hashVideo
            vc.emailUser = emailUser
            vcArray.append(vc)
            if let usv = updateStopVideo{
                usv()
            }
            vcArray.remove(at: vcArray.count-2)
            UIView.transition(with: (self.navigationController?.view)!, duration: 0.75, options: flipping.animate, animations: {
                nav.setViewControllers(vcArray, animated: true)
            })
            //            nav.setViewControllers(vcArray, animated: true)
        }
    }
    
//    пропустить или перейти по окончанию из одного элемента истории в другой
    private func nextVideo(){
        flipping = .next
        if self.story.count > indexUserStory, let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo{
            if sVideo.count-1 == numberPlayVideo || numberPlayVideo < 0{
                //видео юзера закончились
                indexUserStory += 1
                if story.count > indexUserStory{
                    if let newVideo = self.story[indexUserStory].video, newVideo.count != 0, let hash = newVideo.first!.hash{
                        self.transitionVC(storys: self.story, row: 0, hashVideo: hash)
                        return
                    }
                }
                //закрываем
                self.closeViewContoller(isSaveVideo: false, hashVideo: "")
                return
            }
            else{
                self.numberPlayVideo += 1
                return
            }
        }else{
            if let nav = self.navigationController{
                if let stopVideo = updateStopVideo{
                    stopVideo()
                }
                nav.popViewController(animated: true)
            }
            return
        }
    }
    
//    перейти на страницу  пользователя
    @IBAction func showUserProfile(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC_ID") as! MainViewController
        dismissKeyboard()
        if let email = story[indexUserStory].email{
            vc.emailProfile = email
            vc.isSaveVideo = false
            vc.hashVideo = ""
            let nav = self.navigationController
            stateControl = .pause
            if let pContol = updateContol, isPlayVideo{
                pContol(.pause)
            }else{
                //                ставивим на паузу если фото и рисуем окружность для поиска лайков
                if let pContol = updateContolImage{
                    pContol(.pause)
                }
            }
            //nav?.popViewController(animated: false)
            nav?.pushViewController(vc, animated: true)
        }
    }
    
//   перейти к предидущему элементу истории
    private func previousVideo(){
        flipping = .previews
        if numberPlayVideo-1 < 0{
            indexUserStory -= 1
            if indexUserStory >= 0{
//                проверка на наличие окончания истории
                if let newVideo = self.story[indexUserStory].video, newVideo.count != 0, let hash = newVideo[newVideo.count-1].hash{
//                    переходим к историям предидущего пользователя
                    self.transitionVC(storys: self.story, row: newVideo.count-1, hashVideo: hash)
                }
            }
            //закрываем
            self.closeViewContoller(isSaveVideo: false, hashVideo: "")
            return
        }
        else{
            self.numberPlayVideo -= 1
            return
        }
    }
    
//    Добавить лайк на элемент воспроизведения
    private func addHeart(location: Coordinates){
//        елси координаты существуют, стираем все сердца на воспроизводимом элементе и отрисовываем заново с сердцем которое добавили
        if let stringX = location.x, let stringY = location.y{
            guard var nX = Double(stringX) else { return }
            guard var nY = Double(stringY) else { return }
            likes_View.removeAllSubviews()
            nX = (nX * Double(self.view.frame.size.width/100)) - 13.0
            nY = (nY * Double((self.view.frame.size.height)/100) - 13.0)
            self.drawAllHearts(xH: nX, yH: nY,put:true)
        }
    }

//отрисовка лайков
//в параметрах передаем координаты лайка который требуется показать остальные делаем прозрачными
    private func drawAllHearts(xH: Double?, yH: Double?, put:Bool){
        if let likes = sympathyData.likes{
            for like in likes{
                if let likeX = like.x, let likeY = like.y, var nX = Double(likeX), var nY = Double(likeY){
//                    смещаем на середину точки
                    nX = (nX * Double(likes_View.frame.size.width/100)) - 13.0
                    nY = (nY * Double((likes_View.frame.size.height)/100) - 13.0)
                    let imageHeart = UIImage(named: "Heart")
                    let imgView = UIImageView(image: imageHeart)
                    
                    imgView.frame = CGRect(x: nX, y: nY, width: 26.0, height: 26.0)
                    if let xHeart = xH, let yHeart = yH, xHeart == nX, yHeart == nY{
                        imgView.isHidden = false
                        imgView.alpha = 1.0
                        likes_View.addSubview(imgView)
                        UIView.animate(withDuration: 1.5, animations: {
                            imgView.alpha = 0.0
                        })
                    }else{
                        likes_View.addSubview(imgView)
                        imgView.alpha = 0.0
                    }
                }
            }
        }
    }
    
//    поставить лайк и получить позицию установки
    @objc func doubleTap(rec : UITapGestureRecognizer){
        print("Double tap")
        self.isDoubleTap = true
        
//        если воспроизводимый контент не является видео
//        на видео НЕ требуется запоминать куда поставили лайк
        if !isPlayVideo{
            //рисуем лайк
            let location = rec.location(in: self.view)
//            получаем процентное соотношения размера экрана  и местом куда поставили лайк
            let xPercentage = "\(location.x / (self.view.frame.size.width / 100))"
            let yPercentage = "\(location.y / ((self.view.frame.size.height) / 100))"
            if self.story.count > indexUserStory && indexUserStory >= 0{
                if let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo{
                    if let hashImage = sVideo[numberPlayVideo].hash{
//                        отправляем лайк на сервер
                        Video_API.requestPutSympathy(delegate: delegate, hash: hashImage, action: Sympathy.like, cx: xPercentage, cy: yPercentage) { [weak self] (message) in
                            
                            self?.showAlertView(text: message.msg, callback: {
                            })
                            
//                            при успешной отправки запрашиваем заново все лайки с сервера
                            Video_API.requestGetSympathy(delegate: (self?.delegate)!, hash: hashImage, callback: { [weak self] (sympathy) in
                                self?.sympathyData = sympathy
                                if let countLike = sympathy.count{
                                    self?.countLike_Label.text = String(countLike)
                                }
                                let coordin = Coordinates()
                                coordin.x = xPercentage
                                coordin.y = yPercentage
//                                отрисовывем
                                self?.addHeart(location: coordin)
                            })
                        }
                    }
                }
            }
        }
    }
    
//    обработчик нажатия на экран
    @objc func singleTap (rec: UITapGestureRecognizer){
        let location = rec.location(in: self.overlayView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.isDoubleTap{
//                если было одно нажатие по правой стороне экрна
                print(self.overlayView.frame.size.width / 2)
                print(rec.location(in: self.overlayView).x)
                if location.x > (self.overlayView.frame.size.width / 2){
//                  отправляем наблюдателю переключить элемент на следующий
                    if let pContol = self.updateContol, self.isPlayVideo{
                        pContol(.next)
                    }else{
                        if let pContol = self.updateContolImage{
                            pContol(.next)
                        }
                    }
                }else{
//                    если нажатие по экрану было слева от центра
                    if let pContol = self.updateContol, self.isPlayVideo{
                        pContol(.previous)
                    }else{
                        if let pContol = self.updateContolImage{
                            pContol(.previous)
                        }
                    }
                }
            }else{
                self.isDoubleTap = false
            }
        }
    }
    
    @objc func swipe (rec: UISwipeGestureRecognizer){
        if rec.direction == .down{
//            закрываем активность
            closeViewContoller(isSaveVideo: false, hashVideo: "")
        }else{
//            если вверх и текущим воспроизведением является видео то отправляем свой лайк на сервер
            if rec.direction == .up{
                //отправляем лайк на сервер
                if isPlayVideo{
                    putSympathyVideo()
                } else {
                    Toast(text: "Не видео").show()
                }
            }
        }
    }
    
//    при долгом нажатии ставим видео на паузу
    @objc func longPress (rec: UILongPressGestureRecognizer){
        print("long Press")
        if (rec.state == .began){
//            ставим на паузу если видео
            stateControl = .pause
            if let pContol = updateContol, isPlayVideo{
                pContol(.pause)
            }else{
//                ставивим на паузу если фото и рисуем окружность для поиска лайков
                if let pContol = updateContolImage{
                    pContol(.pause)
                    //Рисуем Circle
                    countLike_Label.text = "0"
                    countHeart.isHidden = true
                    let location = rec.location(in: self.overlayView)
//                    смещаем относитель размеров окружности и положением выше пальца
                    let loc2 = CGPoint(x: location.x - 30, y: location.y - 30)
//                    отрисовка откружности
                    let layer = drawCircle(location: loc2)
                    view.layer.addSublayer(layer)
                }
            }
        }else{
            
            if (rec.state == .ended){
                stateControl = .play
//                если видео то продолжаем воспроизводить
                if let pContol = updateContol, isPlayVideo{
                    pContol(.play)
                }else{
//                    если фото то продолжаем воспроизведение и стираем окружность для поиска лайков
                    if let pContol = updateContolImage{
                        pContol(.play)
                        countHeart.text = "0"
                        countLike_Label.text = "\((sympathyData.count)!)"
                        countHeart.isHidden = true
                        if let sublayers = view.layer.sublayers, sublayers.count > 0{
                            view.layer.sublayers!.remove(at: sublayers.count-1)
                            
                        }
                        for like in likes_View.subviews{
                            like.alpha = 0
                        }
                    }
                }
            }
            else{
//                если положение пальца изменилось
                if rec.state == .changed{
                    if !isPlayVideo{
                        //Рисуем передвижение Circle
                        if let sublayers = view.layer.sublayers, sublayers.count > 0{
                            let location = rec.location(in: self.overlayView)
                            let loc2 = CGPoint(x: location.x - 30, y: location.y - 30)
                            let layer = view.layer.sublayers![sublayers.count-1] as! CAShapeLayer
                            let circle = circlePath(location: loc2)
                            layer.path = circle.cgPath
//                          проверка попадает ли лайкм в нарисованную окружность если да то показываем лайки которые попали, если нет то скрываем
                            cheakHeart(circle: circle)
                        }
                    }
                }
            }
        }
    }

//  проверка попадает ли лайкм в нарисованную окружность если да то показываем лайки которые попали, если нет то скрываем
    private func cheakHeart(circle: UIBezierPath){
        let circleWidth = Double(circle.bounds.width)
        let circleRadius = circleWidth / 2.0
        
        let circleX = Double(circle.bounds.origin.x) + circleRadius
        let circleY = Double(circle.bounds.origin.y) + circleRadius
         var countH = 0
        for like in likes_View.subviews{
            let likeX = Double(like.frame.origin.x) + 13.0
            let likeY = Double(like.frame.origin.y) + 13.0
            
            let d = distance(CGPoint(x: circleX, y: circleY), CGPoint(x: likeX, y: likeY))
            if d < (circleRadius + 10) {
                //  показываем лайк
                countH += 1
                like.alpha = 1.0
            }else{
                //                    скрываем лайк
                like.alpha = 0.0
            }
        }
//        в левом верхнем углу показываем колличесво лайков в окружности
        countLike_Label.text = "\(countH)"
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    private func circlePath(location: CGPoint) -> UIBezierPath{
        return UIBezierPath(arcCenter: CGPoint(x: location.x,y: location.y), radius: CGFloat(50), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
    }
    
//    рисуем окружность
    private func drawCircle(location: CGPoint) -> CAShapeLayer{
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath(location: location).cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.init(white: 1.0, alpha: 0.4).cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor(red: 239.0/255.0, green: 60.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        return shapeLayer
    }
    
    func addShadow(view:UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.masksToBounds = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        настрока сохранения контента в галерею
        PHPhotoLibrary.shared().performChanges({})
        
        self.addShadow(view: self.more_Button)
        self.addShadow(view: self.close_btn)
        //self.addShadow(view: self.heart_btn)
        self.addShadow(view: self.countLike_Label)
        
//        настрока жестов
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap(rec:)))
        doubleTapRecognizer?.numberOfTapsRequired = 2
        doubleTapRecognizer?.cancelsTouchesInView = false
        self.overlayView.addGestureRecognizer(doubleTapRecognizer!)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap(rec:)))
        self.overlayView.addGestureRecognizer(tapRecognizer!)
        
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(rec:)))
        swipeRecognizer?.direction = .up
        self.overlayView.addGestureRecognizer(swipeRecognizer!)
        
        closeSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(rec:)))
        closeSwipeRecognizer?.direction = .down
        self.overlayView.addGestureRecognizer(closeSwipeRecognizer!)
        
        longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(rec:)))
        longRecognizer?.minimumPressDuration = 0.2
        self.overlayView.addGestureRecognizer(longRecognizer!)
        
        getIndexUserStory()
        createProgress()
        
//        остановка видео
        if let usv = updateStopVideo{
            usv()
        }
        playing()
        
        if story.count > indexUserStory{
            photoUser_Image.isHidden = false
            name_Label.text = story[indexUserStory].nickname
//            загрузка фото профиля и установка времени последнего посещения
            downloadPicture(urlString: story[indexUserStory].picture)
            if let lastTime = story[indexUserStory].last_login{
                if let time = Auxiliary_PoliDash.lastTime(lastTime: lastTime){
                    date_Label.text = time
                }else{
                    //date_Label.text = ""
                }
            }
        }else{
            name_Label.text = ""
            photoUser_Image.isHidden = true
            date_Label.text = ""
        }
        
    }
  
//    загружаем фото профиля
    private func downloadPicture(urlString: String?){
        if let urlImg = urlString{
            photoUser_Image.sd_setImage(with: URL(string: "\(urlImg)"), placeholderImage: UIImage(named: "Placeholder"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        }
        else{
            photoUser_Image.image = UIImage(named: "Placeholder")
        }
    }
    
    
//   закрываем контроллер
    private func closeViewContoller(isSaveVideo: Bool, hashVideo h: String){
        if let nav = self.navigationController{
            if let stopVideo = updateStopVideo{
                stopVideo()
            }
//            анимация плавного закрытия по свайпу
            UIView.transition(with: nav.view, duration: 0.75, options: .transitionCrossDissolve, animations: {
                if  nav.viewControllers.count > 1, let vc = nav.viewControllers[nav.viewControllers.count-2] as? MainViewController{
                    vc.isSaveVideo = isSaveVideo
                    vc.hashVideo = h
                }
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
   
//    сохранени (фото видео) в галерию
    private func downloadVideo(){
        if let videos = getVideos(){
            var url = ""
            
            if isPlayVideo{
                if let videoUrl = videos[numberPlayVideo].video{
                    url = videoUrl
                }
            }else{
                if let imageUrl = videos[numberPlayVideo].preview{
                    url = imageUrl
                }
            }
            
            
            if let _ = URL(string: url){
                PHPhotoLibrary.shared().performChanges({
                    DiggerCache.cleanDownloadFiles()
                    DiggerCache.cleanDownloadTempFiles()
                    Digger.download(url)
                        .progress({ (progresss) in
                            print(progresss.fractionCompleted)
                            
                        })
                        .speed({ (speed) in
                            print(speed)
                        })
                        .completion { [weak self] (result) in
                            switch result {
                            case .success(let url):
                                if let urlData = NSData(contentsOf: url){
                                    if (self?.isPlayVideo)!{
                                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                        let filePath="\(documentsPath)/\(self?.getHashVideo() ?? "2345").mp4"
                                        DispatchQueue.main.async {
                                            urlData.write(toFile: filePath, atomically: true)
                                            PHPhotoLibrary.shared().performChanges({
                                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                                            }) { completed, error in
                                                if completed {
                                                    self?.showAlertView(text: "Видео удачно загружено", callback: {
                                                        if let pContol = self?.updateContol{
                                                            pContol(.play)
                                                        }
                                                    })
                                                }else{
                                                    self?.showAlertView(text: error?.localizedDescription, callback: {
                                                        if let pContol = self?.updateContol{
                                                            pContol(.play)
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    }else{
                                        if let image = UIImage(data: urlData as Data){
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                            self?.showAlertView(text: "Фото удачно загружено", callback: {
                                                if let pContol = self?.updateContolImage{
                                                    pContol(.play)
                                                }
                                            })
                                        }else{
                                            self?.showAlertView(text: "Не удалось загрузить фото", callback: {
                                                if let pContol = self?.updateContolImage{
                                                    pContol(.play)
                                                }
                                            })
                                        }
                                    }
                                }
                                //                                if let pContol = self?.updateContol{
                                //                                    pContol(.play)
                            //                                }
                            case .failure(let error):
                                self?.showAlertView(text: error.localizedDescription, callback: {
                                    if (self?.isPlayVideo)!{
                                        if let pContol = self?.updateContol{
                                            pContol(.play)
                                        }
                                    }else{
                                        if let pContol = self?.updateContolImage{
                                            pContol(.play)
                                        }
                                    }
                                })
                            }
                    }
                })
            }
        }
    }
    
    
    //MARK:- Actions
//    настрока действий по нажатию на кнопку подробнее
    @IBAction func more_Action(_ sender: UIButton) {
        var moreAlert : MoreAlert!
//        ставим на паузу воспроизводимый контент
        if self.isPlayVideo{
            if let pContol = self.updateContol{
                pContol(.pause)
            }
        }else{
            if let pContol = self.updateContolImage{
                pContol(.pause)
            }
        }
        
//        устанавливаем возможные действия в зависемости от того кому принадлежит воспроизводимый контент
        if AllUserDefaults.getLoginUD() ?? "" != "" && AllUserDefaults.getLoginUD()! != emailUser{
            moreAlert = .save
        }else{
            moreAlert = .all
        }
        
        let alert = Auxiliary_PoliDash.showAlertMore(moreAlert: moreAlert) { [weak self] (moreAction) in
            switch moreAction {
            case .cancel:
                if (self?.isPlayVideo)!{
                    if let pContol = self?.updateContol{
                        pContol(.play)
                    }
                }else{
                    if let pContol = self?.updateContolImage{
                        pContol(.play)
                    }
                }
                return
            case .saveHistory:
                if let hashVideo = self?.hashVideo{
//                    закрываем окно воспроизведения и передаем главному экрану контент который хотим сохранить в историю
                    self?.closeViewContoller(isSaveVideo: true, hashVideo: hashVideo)
                }
                return
            case .delete:
                if let hashVideo = self?.getHashVideo(){
                    self?.showWaitView(isWait: true)
//                    запрос на удаление видео
                    Video_API.requestDeleteVideo(delegate: (self?.delegate)!, hash: hashVideo, callback: { [weak self] (callback) in
                        self?.showWaitView(isWait: false)
                        if let code = callback.code, code >= 200 && code < 300, let msg = callback.msg{
                            self?.showAlertView(text: msg, callback: {
                                self?.closeViewContoller(isSaveVideo: false, hashVideo: "")
                            })
                        }else{
//                            обработка ошибок
                            if let code = callback.code, code < 200 || code >= 300, let msg = callback.msg{
                                self?.showAlertView(text: msg, callback: {
                                    if (self?.isPlayVideo)!{
                                        if let pContol = self?.updateContol{
                                            pContol(.play)
                                        }
                                    }else{
                                        if let pContol = self?.updateContolImage{
                                            pContol(.play)
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
                return
            case .download:
//                сохраняем контент в галереии устройства
                self?.downloadVideo()
                return
            case .allLikes:
                print("Все сердечки")
                return
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close_Action(_ sender: UIButton) {
        closeViewContoller(isSaveVideo: false , hashVideo: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusBar.isHidden = false
    }
    
    deinit{
//        останавливаем воспроизведения для разрушения контроллера из памяти
        if let st = updateStopVideo{
            st()
        }
        print("PlayerStorys is deinit")
    }
    
    @objc func dismissKeyboard(){
        view.resignFirstResponder()
        view.endEditing(true)
    }
    
}


