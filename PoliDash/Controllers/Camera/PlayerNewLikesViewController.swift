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

class PlayerNewLikesViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var overlayView: CustomView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var countLikeLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var photoUserImage: RoundedUIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var countHeart: UILabel!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!

    var stateControl = PlayerControl.play
    var isDoubleTap = false

    var emailUser = ""

    var delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()

    var indexUserStory = 0
    var numberPlayVideo = 0
    var hashVideo = ""
    var story = [UsersModel]()
    var sympathyData = SympathyModel()

    var tapRecognizer: UITapGestureRecognizer?
    var swipeRecognizer: UISwipeGestureRecognizer?
    var closeSwipeRecognizer: UISwipeGestureRecognizer?
    var longRecognizer: UILongPressGestureRecognizer?

    var updateUrl: ((String, Int) -> Void)?
    var updateUrlImage: ((String) -> Void)?
    var updateContol: ((PlayerControl) -> Void)?
    var updateContolImage: ((PlayerControl) -> Void)?
    var updateStopVideo : (() -> Void)?

    var timerImagePlay: Repeater?

    var currentProgress = UIProgressView()
    var isPlayVideo = false

    var flipping = DurationFlipping.next

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.avPlayerStrory.rawValue {
//          события проигрывания видео роликов
            if let vc = segue.destination as? AVPlayerStroryViewController {
                vc.nextWhanEnd = false
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
                    if time >= duration - 0.1 {
                        vc.player?.pause()
                        self?.indicator.isHidden = true
                    }
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
        } else {
//            события проигрывания фото
            if segue.identifier == SegueID.imagePlayer.rawValue {
                if let vc = segue.destination as? ImagePlayerViewController {
                    vc.duration = Double(FP_INFINITE)
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
    func updateTime(time: Double, duration: Double) {
        if duration.isNaN && stateControl == .play {
            currentProgress.progress = 0.0
            indicator.isHidden = false
            if isPlayVideo {
                indicator.color = UIColor.white
            } else {
                indicator.color = UIColor.black
            }
        } else {
            let newProgress = Float(time/Double(duration))
            if  stateControl == .pause || currentProgress.progress != newProgress {
                indicator.isHidden = true
                currentProgress.progress = newProgress
            } else {
                indicator.isHidden = false
                if isPlayVideo {
                    indicator.color = UIColor.white
                } else {
                    indicator.color = UIColor.black
                }
            }
        }
    }

    func videoEnd(status: Bool) {
        self.setWasSee()
        nextVideo()
        playing()
    }

    func updatePreviousVideo() {
        self.setWasSee()
        previousVideo()
        playing()
    }

    func setWasSee() {
        if let hashVideo = self.getHashVideo() {
            let key  = "WasSee_\(hashVideo)"
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.loadCircles()
    }

    func loadCircles() {
        ProfileAPI.requestCircles(delegate: delegate, email: AllUserDefaults.getLoginUD()!) { (_, _, circles) in
            for btn in self.buttonsView.arrangedSubviews {
                btn.isHidden = true
            }
            var i = 0
            for owner in circles {
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).owner = owner
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).isHidden = false
                i += 1
            }
        }
    }

    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.masksToBounds = false
    }

    @IBAction func selectRound(sender: RoundButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC_ID") as! MainViewController
        dismissKeyboard()
        if let email = sender.owner?.email {
            vc.emailProfile = email
            vc.isSaveVideo = false
            vc.hashVideo = ""
            let nav = self.navigationController
            if let stop = updateStopVideo {
                stop()
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
    private func getIndexUserStory() {
        var userIter = 0
        for uStory in story {
            if let uStoryVideo = uStory.video {
                if uStoryVideo.count > numberPlayVideo, let hUserStoryHash = uStoryVideo[numberPlayVideo].hash, hUserStoryHash == hashVideo {
                    indexUserStory = userIter
                    return
                }
            }
            userIter += 1
        }
        userIter = 0
    }

//  создаем колличство прогрессов воспроизведения по колличеству элементов в истории и добавляем их в стек
    private func createProgress() {
        if self.story.count > 0, self.story.count > indexUserStory, let sVideo = self.story[indexUserStory].video, sVideo.count > 1 {
//            начинаем с двух так как в стеке всегда есть один прогресс бар
            for _ in 2 ... sVideo.count {
                let progressView = UIProgressView()
                progressView.progressTintColor = UIColor.white
                progressView.progress = 0.0
                progressStack.addArrangedSubview(progressView)
            }
        }
    }

//    заполняем прогрессы для элементов которые были пропущены
    private func selectProgress() {
        var itr = 0
        for item in progressStack.arrangedSubviews {
            if itr == numberPlayVideo {
                currentProgress = item as! UIProgressView
                currentProgress.progress = 0
            } else {
                if itr < numberPlayVideo {
                    (item as! UIProgressView).progress = 1.0
                } else {
                    (item as! UIProgressView).progress = 0.0
                }
            }
            itr += 1
        }
    }

    // MARK: - Получаем список лайков
    private func getSympathy() {
        self.likesView.removeAllSubviews()
        self.countLikeLabel.text = "0"
        if let hashVideo = getHashVideo() {
            let key  = "WasSee_\(hashVideo)"
            let wasSee = UserDefaults.standard.bool(forKey: key)
            if wasSee == true {
                //            запрос на сервер для получения списка лайков
                VideoAPI.requestGetLikes(delegate: delegate, hash: hashVideo) { [weak self] (sympaty) in
                    if let countLike = sympaty.count {
                        if let ss = self {
                            ss.countLikeLabel.text = String(countLike)
                            ss.sympathyData = sympaty
                            ss.likesView.removeAllSubviews()
                            ss.drawAllHearts(xH: nil, yH: nil)
                        }
                    }
                }
            } else {
            VideoAPI.requestGetNewSympathy(delegate: delegate, hash: hashVideo) { [weak self] (sympaty) in
                if let countLike = sympaty.count {
                    if let ss = self {
                        ss.countLikeLabel.text = String(countLike)
                        ss.sympathyData = sympaty
                        ss.likesView.removeAllSubviews()
                        ss.drawAllHearts(xH: nil, yH: nil)
                    }
                }
            }
            }
        }
    }

//    Получить hash воспроизводимого элемента
    private func getHashVideo() -> String? {
        if let sVideo = getVideos() {
            if let hashVideo = sVideo[numberPlayVideo].hash {
                return hashVideo
            }
        }
        return nil
    }

//    Получить видео истории
    private func getVideos() -> [HistoryVideo]? {
        if self.story.count > indexUserStory && indexUserStory >= 0 {
            if let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo {
                return sVideo
            }
        }
        return nil
    }

    func playing() {
        selectProgress() //установка прогресса для текущего и предедущих видео
        if let usv = updateStopVideo {
            usv() //передаем контейнеру информацию об остановки текущего воспроизведения
        }
        if self.story.count > indexUserStory && indexUserStory >= 0 {
            if let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo {
//                если воспроизводимый контент является видео
                if let urlVideo = sVideo[numberPlayVideo].video, urlVideo != "", let duration = sVideo[numberPlayVideo].duration {
                    //получаем координаты лайков для теущего воспроизведения
                    getSympathy()
                    DispatchQueue.main.async {
//                        показываем контейнер с видео проигрывателем
                        self.containerView.isHidden = false
//                        скрываем контейнер с фото проигрывателем
                        self.imageContainerView.isHidden = true
                    }
                    isPlayVideo = true
                    stateControl = .play
                    if let upUrl = updateUrl {
//                        передаем ссылку на видео и длительность видео контейнеру
                        upUrl(urlVideo, duration)
                    }
                } else {
//                    если воспроизводимый контент является фото
                     //получаем координаты лайков для теущего воспроизведения
                    getSympathy()
                    DispatchQueue.main.async {
//                      скрываем контейнер с видео проигрывателем
                        self.containerView.isHidden = true
//                      показываем контейнер с фото проигрывателем
                        self.imageContainerView.isHidden = false
                    }
                    isPlayVideo = false
                    stateControl = .play
                    if let prew = sVideo[numberPlayVideo].preview {
                        if let upUrl = updateUrlImage {
                            upUrl(prew)
                        }
                    } else {
                        if let upUrl = updateUrlImage {
                            upUrl("")
                        }
                    }
                }
            }
        }
    }

//  Если истории пользователей закончились открываем истории следующего в списке пользователя и начинаем воспроизводить с первого элемента
    private func transitionVC(storys: [UsersModel], row: Int, hashVideo: String) {
        if let nav = self.navigationController {
            var vcArray = nav.viewControllers
            let storyboard = UIStoryboard(name: StoryboardName.videoPlayerStoryboard.rawValue, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.playerStorys.rawValue) as! PlayerStorysViewController
            vc.story = storys
            vc.numberPlayVideo = row
            vc.hashVideo = hashVideo
            vc.emailUser = emailUser
            vcArray.append(vc)
            if let usv = updateStopVideo {
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
    private func nextVideo() {
        flipping = .next
        if self.story.count > indexUserStory, let sVideo = self.story[indexUserStory].video, sVideo.count > numberPlayVideo {
            if sVideo.count-1 == numberPlayVideo || numberPlayVideo < 0 {
                //видео юзера закончились
                indexUserStory += 1
                if story.count > indexUserStory {
                    if let newVideo = self.story[indexUserStory].video, newVideo.count != 0, let hash = newVideo.first!.hash {
                        self.transitionVC(storys: self.story, row: 0, hashVideo: hash)
                        return
                    }
                }
                //закрываем
                self.closeViewContoller(isSaveVideo: false, hashVideo: "")
                return
            } else {
                self.numberPlayVideo += 1
                return
            }
        } else {
            if let nav = self.navigationController {
                if let stopVideo = updateStopVideo {
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
        if let email = story[indexUserStory].email {
            vc.emailProfile = email
            vc.isSaveVideo = false
            vc.hashVideo = ""
            let nav = self.navigationController
            if let stop = updateStopVideo {
                stop()
            }
            //nav?.popViewController(animated: false)
            nav?.pushViewController(vc, animated: true)
        }
    }

//   перейти к предидущему элементу истории
    private func previousVideo() {
        flipping = .previews
        if numberPlayVideo-1 < 0 {
            indexUserStory -= 1
            if indexUserStory >= 0 {
//                проверка на наличие окончания истории
                if let newVideo = self.story[indexUserStory].video, !newVideo.isEmpty, let hash = newVideo[newVideo.count-1].hash {
//                    переходим к историям предидущего пользователя
                    self.transitionVC(storys: self.story, row: newVideo.count-1, hashVideo: hash)
                }
            }
            //закрываем
            self.closeViewContoller(isSaveVideo: false, hashVideo: "")
            return
        } else {
            self.numberPlayVideo -= 1
            return
        }
    }

//    Добавить лайк на элемент воспроизведения
    private func addHeart(location: Coordinates) {
//        елси координаты существуют, стираем все сердца на воспроизводимом элементе и отрисовываем заново с сердцем которое добавили
        if let stringX = location.x, let stringY = location.y {
            guard var nX = Double(stringX) else { return }
            guard var nY = Double(stringY) else { return }
            likesView.removeAllSubviews()
            nX = (nX * Double(self.view.frame.size.width/100)) - 13.0
            nY = (nY * Double((self.view.frame.size.height)/100) - 13.0)
            self.drawAllHearts(xH: nX, yH: nY)
        }
    }

//отрисовка лайков
//в параметрах передаем координаты лайка который требуется показать остальные делаем прозрачными
    private func drawAllHearts(xH: Double?, yH: Double?) {
        if let likes = sympathyData.likes {
            for like in likes {
                if let likeX = like.x, let likeY = like.y, var nX = Double(likeX), var nY = Double(likeY) {
//                    смещаем на середину точки
                    nX = (nX * Double(likesView.frame.size.width/100)) - 13.0
                    nY = (nY * Double((likesView.frame.size.height)/100) - 13.0)
                    let imageHeart = UIImage(named: "Heart")
                    let imgView = UIImageView(image: imageHeart)

                    imgView.frame = CGRect(x: nX, y: nY, width: 26.0, height: 26.0)
                    if let xHeart = xH, let yHeart = yH, xHeart == nX, yHeart == nY {
                        imgView.isHidden = false
                        imgView.alpha = 1.0
                        likesView.addSubview(imgView)
                        UIView.animate(withDuration: 1.5, animations: {
                            imgView.alpha = self.likesAlpha()
                        })
                    } else {
                        likesView.addSubview(imgView)
                        imgView.alpha = self.likesAlpha()
                    }
                }
            }
        }
    }

//    обработчик нажатия на экран
    @objc func handleNavigation (rec: UITapGestureRecognizer) {
        let location = rec.location(in: self.overlayView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.isDoubleTap {
//                если было одно нажатие по правой стороне экрна
                print(self.overlayView.frame.size.width / 2)
                print(rec.location(in: self.overlayView).x)
                if location.x > (self.overlayView.frame.size.width / 2) {
//                  отправляем наблюдателю переключить элемент на следующий
                    if let pContol = self.updateContol, self.isPlayVideo {
                        pContol(.next)
                    } else {
                        if let pContol = self.updateContolImage {
                            pContol(.next)
                        }
                    }
                } else {
//                    если нажатие по экрану было слева от центра
                    if let pContol = self.updateContol, self.isPlayVideo {
                        pContol(.previous)
                    } else {
                        if let pContol = self.updateContolImage {
                            pContol(.previous)
                        }
                    }
                }
            } else {
                self.isDoubleTap = false
            }
        }
    }

    @objc func swipe (recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .down {
//            закрываем активность
            closeViewContoller(isSaveVideo: false, hashVideo: "")
        } else {
//            если вверх и текущим воспроизведением является видео то отправляем свой лайк на сервер
            if recognizer.direction == .up {
                //отправляем лайк на сервер
                if isPlayVideo {
                } else {
                    Toast(text: "Не видео").show()
                }
            }
        }
    }

//    при долгом нажатии ставим видео на паузу
    @objc func longPress (rec: UILongPressGestureRecognizer) {
        //print("long Press")
        if (rec.state == .began) {
//            ставим на паузу если видео
            stateControl = .pause
            if let pContol = updateContol, isPlayVideo {
                pContol(.pause)
            } else {
//                ставивим на паузу если фото и рисуем окружность для поиска лайков
                if let pContol = updateContolImage {
                    pContol(.pause)
                    //Рисуем Circle
                    countLikeLabel.text = "0"
                    countHeart.isHidden = true
                    let location = rec.location(in: self.overlayView)
//                    смещаем относитель размеров окружности и положением выше пальца
                    let loc2 = CGPoint(x: location.x - 30, y: location.y - 30)
//                    отрисовка откружности
                    let layer = drawCircle(location: loc2)
                    view.layer.addSublayer(layer)
                }
            }
        } else {

            if (rec.state == .ended) {
                stateControl = .play
//                если видео то продолжаем воспроизводить
                if let pContol = updateContol, isPlayVideo {
                    pContol(.play)
                } else {
//                    если фото то продолжаем воспроизведение и стираем окружность для поиска лайков
                    if let pContol = updateContolImage {
                        pContol(.play)
                        countHeart.text = "0"
                        countLikeLabel.text = "\(sympathyData.count ?? 0)"
                        countHeart.isHidden = true
                        if let sublayers = view.layer.sublayers, !sublayers.isEmpty {
                            view.layer.sublayers!.remove(at: sublayers.count-1)

                        }
                        for like in likesView.subviews {
                            like.alpha = self.likesAlpha()
                        }
                    }
                }
            } else {
//                если положение пальца изменилось
                if rec.state == .changed {
                    if !isPlayVideo {
                        //Рисуем передвижение Circle
                        if let sublayers = view.layer.sublayers, sublayers.count > 0 {
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
    private func cheakHeart(circle: UIBezierPath) {
        let circleWidth = Double(circle.bounds.width)
        let circleRadius = circleWidth / 2.0

        let circleX = Double(circle.bounds.origin.x) + circleRadius
        let circleY = Double(circle.bounds.origin.y) + circleRadius

        var countH = 0

        for like in likesView.subviews {
            let likeX = Double(like.frame.origin.x) + 13.0
            let likeY = Double(like.frame.origin.y) + 13.0
            let d = distance(CGPoint(x: circleX, y: circleY), CGPoint(x: likeX, y: likeY))
            if d < (circleRadius + 10) {
                //  показываем лайк
                countH += 1
                like.alpha = 1.0
                } else {
//                    скрываем лайк
                    like.alpha = self.likesAlpha()
                }
        }
//        в левом верхнем углу показываем колличесво лайков в окружности
        countLikeLabel.text = "\(countH)"
    }

    func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }

    func likesAlpha() -> CGFloat {
        var alpha: CGFloat = 0.0
        if let hashVideo = getHashVideo() {
            let key  = "WasSee_\(hashVideo)"
            let wasSee = UserDefaults.standard.bool(forKey: key)
            if wasSee == true {
                alpha = 0.0
            } else {
                alpha = 1.0
            }
        }
        return alpha
    }

    private func circlePath(location: CGPoint) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: location.x, y: location.y), radius: CGFloat(50), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

    }

//    рисуем окружность
    private func drawCircle(location: CGPoint) -> CAShapeLayer {
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

    override func viewDidLoad() {
        super.viewDidLoad()

//        настрока сохранения контента в галерею
        PHPhotoLibrary.shared().performChanges({})
        self.addShadow(view: self.moreButton)
        self.addShadow(view: self.closeButton)
        self.addShadow(view: self.countLikeLabel)

        addRecognizers()
        getIndexUserStory()
        //createProgress()

//        остановка видео
        if let usv = updateStopVideo {
            usv()
        }
        playing()

        if story.count > indexUserStory {
            photoUserImage.isHidden = false
            nameLabel.text = story[indexUserStory].nickname
//            загрузка фото профиля и установка времени последнего посещения
            downloadPicture(urlString: story[indexUserStory].picture)
            if let lastTime = story[indexUserStory].lastLogin {
                if let time = AuxiliaryPoliDash.lastTime(lastTime: lastTime) {
                    dateLabel.text = time
                } else {
                    //dateLabel.text = ""
                }
            }
        } else {
            nameLabel.text = ""
            photoUserImage.isHidden = true
            dateLabel.text = ""
        }

    }

    func addRecognizers() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleNavigation(rec:)))
        self.overlayView.addGestureRecognizer(tapRecognizer!)

        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(recognizer:)))
        swipeRecognizer?.direction = .up
        self.overlayView.addGestureRecognizer(swipeRecognizer!)

        closeSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(recognizer:)))
        closeSwipeRecognizer?.direction = .down
        self.overlayView.addGestureRecognizer(closeSwipeRecognizer!)

        longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(rec:)))
        longRecognizer?.minimumPressDuration = 0.2
        self.overlayView.addGestureRecognizer(longRecognizer!)

    }

//    загружаем фото профиля
    private func downloadPicture(urlString: String?) {
        if let urlImg = urlString {
            photoUserImage.sd_setImage(with: URL(string: "\(urlImg)"), placeholderImage: UIImage(named: "Placeholder"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        } else {
            photoUserImage.image = UIImage(named: "Placeholder")
        }
    }

//   закрываем контроллер
    private func closeViewContoller(isSaveVideo: Bool, hashVideo h: String) {
        if let nav = self.navigationController {
            if let stopVideo = updateStopVideo {
                stopVideo()
            }
//            анимация плавного закрытия по свайпу
            UIView.transition(with: nav.view, duration: 0.75, options: .transitionCrossDissolve, animations: {
                if  nav.viewControllers.count > 1, let vc = nav.viewControllers[nav.viewControllers.count-2] as? MainViewController {
                    vc.isSaveVideo = isSaveVideo
                    vc.hashVideo = h
                }
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

//    сохранени (фото видео) в галерию
    private func downloadVideo() {
        if let videos = getVideos() {
            var url = ""

            if isPlayVideo {
                if let videoUrl = videos[numberPlayVideo].video {
                    url = videoUrl
                }
            } else {
                if let imageUrl = videos[numberPlayVideo].preview {
                    url = imageUrl
                }
            }

            if let _ = URL(string: url) {
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
                                if let urlData = NSData(contentsOf: url) {
                                    if (self?.isPlayVideo)! {
                                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                        let filePath="\(documentsPath)/\(self?.getHashVideo() ?? "2345").mp4"
                                        DispatchQueue.main.async {
                                            urlData.write(toFile: filePath, atomically: true)
                                            PHPhotoLibrary.shared().performChanges({
                                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                                            }) { completed, error in
                                                if completed {
                                                    self?.showAlertView(text: "Видео удачно загружено", callback: {
                                                        if let pContol = self?.updateContol {
                                                            pContol(.play)
                                                        }
                                                    })
                                                } else {
                                                    self?.showAlertView(text: error?.localizedDescription, callback: {
                                                        if let pContol = self?.updateContol {
                                                            pContol(.play)
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    } else {
                                        if let image = UIImage(data: urlData as Data) {
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                            self?.showAlertView(text: "Фото удачно загружено", callback: {
                                                if let pContol = self?.updateContolImage {
                                                    pContol(.play)
                                                }
                                            })
                                        } else {
                                            self?.showAlertView(text: "Не удалось загрузить фото", callback: {
                                                if let pContol = self?.updateContolImage {
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
                                    if (self?.isPlayVideo)! {
                                        if let pContol = self?.updateContol {
                                            pContol(.play)
                                        }
                                    } else {
                                        if let pContol = self?.updateContolImage {
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

    // MARK: - Actions
//    настрока действий по нажатию на кнопку подробнее
    @IBAction func more_Action(_ sender: UIButton) {
        var moreAlert: MoreAlert!
//        ставим на паузу воспроизводимый контент
        if self.isPlayVideo {
            if let pContol = self.updateContol {
                pContol(.pause)
            }
        } else {
            if let pContol = self.updateContolImage {
                pContol(.pause)
            }
        }

//        устанавливаем возможные действия в зависемости от того кому принадлежит воспроизводимый контент
        if AllUserDefaults.getLoginUD() ?? "" != "" && AllUserDefaults.getLoginUD()! != emailUser {
            moreAlert = .save
        } else {
            moreAlert = .all
        }

        let alert = AuxiliaryPoliDash.showAlertMore(moreAlert: moreAlert) { [weak self] (moreAction) in
            switch moreAction {
            case .cancel:
                if (self?.isPlayVideo)! {
                    if let pContol = self?.updateContol {
                        pContol(.play)
                    }
                } else {
                    if let pContol = self?.updateContolImage {
                        pContol(.play)
                    }
                }
                return
            case .saveHistory:
                if let hashVideo = self?.hashVideo {
//                    закрываем окно воспроизведения и передаем главному экрану контент который хотим сохранить в историю
                    self?.closeViewContoller(isSaveVideo: true, hashVideo: hashVideo)
                }
                return
            case .delete:
                if let hashVideo = self?.getHashVideo() {
                    self?.showWaitView(isWait: true)
//                    запрос на удаление видео
                    VideoAPI.requestDeleteVideo(delegate: (self?.delegate)!, hash: hashVideo, callback: { [weak self] (callback) in
                        self?.showWaitView(isWait: false)
                        if let code = callback.code, code >= 200 && code < 300, let msg = callback.msg {
                            self?.showAlertView(text: msg, callback: {
                                self?.closeViewContoller(isSaveVideo: false, hashVideo: "")
                            })
                        } else {
//                            обработка ошибок
                            if let code = callback.code, code < 200 || code >= 300, let msg = callback.msg {
                                self?.showAlertView(text: msg, callback: {
                                    if (self?.isPlayVideo)! {
                                        if let pContol = self?.updateContol {
                                            pContol(.play)
                                        }
                                    } else {
                                        if let pContol = self?.updateContolImage {
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
                print("все сердечки")
            }
        }
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func close_Action(_ sender: UIButton) {
        closeViewContoller(isSaveVideo: false, hashVideo: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
//        останавливаем воспроизведения для разрушения контроллера из памяти
        if let st = updateStopVideo {
            st()
        }
        print("PlayerStorys is deinit")
    }

    @objc func dismissKeyboard() {
        view.resignFirstResponder()
        view.endEditing(true)
    }

}
