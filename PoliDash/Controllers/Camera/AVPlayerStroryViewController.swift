//
//  AVPlayerStroryViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 27.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import AVKit
import Repeat

class AVPlayerStroryViewController: AVPlayerViewController {
    var app = UIApplication.shared.delegate as! AppDelegate
    var nextWhanEnd = true
    var updateTime: ((Double, Double) -> Void)? //передаем контроллеру воспроизведения время воспроизведения
    var videoEnd: ((Bool) -> Void)? //передаем контроллеру воспроизведения состояние остановки видео
    var videoPrevious : (() -> Void)? //передаем контроллеру воспроизведения состояние проигрывание предедущего видео

    var numberPlayVideo = 0
    var items = [AVPlayerItem]()
    var indexUserStory = 0

    var timerVideoPlay: Repeater?

    var notificationObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        self.player?.externalPlaybackVideoGravity = AVLayerVideoGravity.resizeAspectFill
        self.showsPlaybackControls = false
    }

    func getPlayerContol(control: PlayerControl) {
        switch control {
        case .next:
            if let vEnd = videoEnd {
                stopVideo()
                vEnd(true)
            }
        case .previous:
            if let previousV = videoPrevious {
                stopVideo()
                previousV()
            }
        case .play:
            if let p = self.player {
                self.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                p.play()
            }
        case .pause:
            if let p = self.player {
                p.pause()

            }
        }
    }

    func updateStopVideo() {
        stopVideo()
    }

    private func stopVideo() {
        if let pl = player {
            pl.pause()
            if let timer = timerVideoPlay {
                timer.removeAllObservers(thenStop: true)
                print(timer.state)
            }
            if let notif = self.notificationObserver {
                NotificationCenter.default.removeObserver(notif)
            }
            self.player = nil
        }
    }

//    создаем таймер который каждые 10 сек получаем текущее время воспроизведния
//    если видео не удается загрузить то такой итератор работает максимум 100 сек после чего переходит к следуещему видео
    private func createTimer(durationVideo: Int) {
        var itr = 0
        self.timerVideoPlay = Repeater.every(.milliseconds(10), count: 100000, queue: DispatchQueue.main, { [weak self] (_) in
            if let uTime = self?.updateTime, let pl = self?.player, let currentItem = pl.currentItem {
                let dur = currentItem.duration.seconds
                itr += 1
                uTime(currentItem.currentTime().seconds, dur)
                if 100000 == itr {
                    if let vEnd = self?.videoEnd {
                        self?.stopVideo()
                        vEnd(true)
                    }
                }
            }
        })
        timerVideoPlay?.start()
    }

    func getURL(url: String, duration: Int) {
        if let urlV = URL(string: url) {
            player = AVPlayer(url: urlV)
            if let pl = self.player {
                createTimer(durationVideo: duration)
                if let item = pl.currentItem {
                    self.notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item, queue: nil, using: {
                        [weak self] _ in
                        if let vEnd = self?.videoEnd {
                            self?.stopVideo()
                            vEnd(true)
                        }
                    })
                }
                self.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                pl.play()
            }
        } else {
            if let vEnd = videoEnd {
                self.stopVideo()
                vEnd(true)
            }
        }
    }

    deinit {
        print("AVPlayerStroryViewController is deinit")
    }

}
