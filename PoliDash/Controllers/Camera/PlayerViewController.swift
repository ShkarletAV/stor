//
//  PlayerViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 23.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import AVKit
import RxSwift

class PlayerViewController: UIViewController {

    @IBOutlet weak var containerPlayer: UIView!
    @IBOutlet weak var playBtn: UIButton!

    var videoURL: URL?
    var previewImage: UIImage?

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let disposeBag = DisposeBag()

    var swipeRecognizerRight: UISwipeGestureRecognizer?
    var swipeRecognizerDown: UISwipeGestureRecognizer?

    // MARK: - Request Download Video
    var msgDownloadVideo = Variable<MessageVideoModel>(MessageVideoModel())

    var messageAlert = UIView()

    var player: FPlayerViewController?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //передаем ссылку на видео AVPlayer контейнера
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPlayerViewController {
            vc.videoURL = self.videoURL
            vc.root = self
            player = vc
        }
    }

    @IBAction func play() {
        player?.player?.play()
        playBtn.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()

//        возвращаемся назад при свайпе вправо
        swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(recognizer:)))
        swipeRecognizerRight?.direction = .right
        self.view.addGestureRecognizer(swipeRecognizerRight!)

   //        возвращаемся назад при свайпе вниз
        swipeRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(recognizer:)))
        swipeRecognizerDown?.direction = .down
        self.view.addGestureRecognizer(swipeRecognizerDown!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func getVideoData(quality: QualityAction) {
        if let vURL = videoURL {
//            сжимаем видео
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
            compressVideo(inputURL: vURL, quality: quality, outputURL: compressedURL)
        }
    }

    // MARK: - Duration Video
    private func getDurationVideo(videoUrl url: URL) -> String {
        let player = AVPlayer(url: url)
//        получаем длительность видео в секундах
        if let sec = player.currentItem?.asset.duration.seconds {
            return String(Int(sec*1000))
        }
        return ""
    }

//    метод для сжатия видео по url
    private func compressVideo(inputURL: URL, quality: QualityAction, outputURL: URL) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        do {
            let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
            let cgImage = try imgGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            self.previewImage = UIImage(cgImage: cgImage ,
                                        scale: 1.0 ,
                                        orientation: .right)

        } catch {
            self.showAlertView(text: "Неизвестная ошибка, попробуйте еще раз", callback: {})
        }

        guard let sdav = SDAVAssetExportSession(asset: urlAsset) else {
            return
        }

        sdav.outputFileType = AVFileType.mp4.rawValue
        sdav.outputURL = outputURL
        if quality == .low {
        sdav.videoSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: 720,
            AVVideoHeightKey: 1280,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 13500000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
            ]
        ]
        } else {
            sdav.videoSettings = [
                AVVideoCodecKey: AVVideoCodecH264,
                AVVideoWidthKey: 720,
                AVVideoHeightKey: 1280,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 3500000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
                ]
            ]
        }

        sdav.audioSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 64000
        ]

        sdav.exportAsynchronously(completionHandler: {
            if sdav.status == AVAssetExportSessionStatus.completed {
                print("complite")

                guard let compressedData = NSData(contentsOf: sdav.outputURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length )) mb")
//                получаем привьюв фото видео
                if let image = self.previewImage {
                    DispatchQueue.main.async {
                        self.returnToMainScreen(image: image, video: compressedData)
                    }
                } else {
                    self.showAlertView(text: "Неизвестная ошибка, попробуйте еще раз", callback: {})
                }

            } else {
//                обработчик ошибок сжатия видео
                if sdav.status == AVAssetExportSessionStatus.cancelled {
                     print("cancel")
                     self.showWaitView(isWait: false)
                } else {
                    self.showWaitView(isWait: false)
                    self.showAlertView(text: sdav.error.localizedDescription, callback: {})
                    print(sdav.error.localizedDescription)
                }
            }

        })

    }

    func returnToMainScreen(image: UIImage, video: NSData) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        if viewControllers[viewControllers.count - 3] is MainViewController {
            let controller = viewControllers[viewControllers.count - 3] as! MainViewController
            controller.downloadVideo(image: image, video: video as Data)
            self.navigationController!.popToViewController(controller, animated: false)
        }
    }

    // MARK: - Actions
    @IBAction func share_Action(_ sender: IBDesignableButton) {
//        показать диалог степени сжатия видео

        self.getVideoData(quality: .low)
        self.showWaitView(isWait: true)

//        let alert = Auxiliary_PoliDash.showAlertQuality { [weak self] (quality) in
//            if quality != .cancel{
//                //self?.showWaitView(isWait: true)
//            }
//        }
//        present(alert, animated: true, completion: nil)
    }

    @IBAction func back_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - back if swipe right
    @objc func swipe (rec: UISwipeGestureRecognizer) {
        if rec.direction == .right || rec.direction == .down {
            UIView.transition(with: (self.navigationController?.view)!, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        print("Player is deinit")
    }
}

extension PlayerViewController {
    private func subscribe() {
//        Наблюдатель результатов отправки видео
        msgDownloadVideo.asObservable().skip(1).subscribe(onNext: { [weak self] (element) in
            if let code = element.code, code < 200 || code >= 300, let msg = element.msg {
                            self?.showAlertView(text: msg, callback: {})
                            } else {
                                if let code = element.code, code >= 200 && code < 300, let msg = element.msg {
                                    if let ss = self {
                                        if let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg, tittle: "", actionBtn: "ОК", callback: {
                                            if let sss = self {
//                                                возвращаемся на главный экран
                                                let viewControllers: [UIViewController] = sss.navigationController!.viewControllers as [UIViewController]
                                                sss.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
                                            }
                                        }) {
                                            ss.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
