//
//  ImagePlayerViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 02.08.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import SDWebImage
import Repeat

class ImagePlayerViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    let delegate = UIApplication.shared.delegate as! AppDelegate
    var timerImagePlay: Repeater?

    var duration = 5000.0
    var updateTime: ((Double, Double) -> Void)? //передаем контроллеру воспроизведения время воспроизведения
    var videoEnd: ((Bool) -> Void)? //передаем контроллеру воспроизведения состояние остановки видео
    var videoPrevious : (() -> Void)? //передаем контроллеру воспроизведения состояние проигрывание предедущего видео

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getURL(url: String) {
        downloadPicture(urlString: url)
    }

//    создаем таймер воспроизведения на 5 сек после загрузки изображения запускаем его
    private func downloadPicture(urlString: String?) {
        if let urlImg = urlString {
            if let uTime = self.updateTime {
                uTime(0, duration)
            }
                imageView.sd_setImage(with: URL(string: "\(urlImg)")) { [weak self] (_, _, _, _) in
                var iter = 0
                self?.timerImagePlay = Repeater.every(.milliseconds(10), count: 500, queue: DispatchQueue.main, { [weak self] (_) in
                    iter += 1
                    if let uTime = self?.updateTime {
                        uTime(Double( iter * 10), (self?.duration)!)
                    }

                    if iter * 10 == Int((self?.duration)!) {
                        //callBack end
                        if let vEnd = self?.videoEnd {
                            vEnd(true)
                        }
                    }
                })

                self?.timerImagePlay!.start()
            }

        } else {
            imageView.image = UIImage(named: "Placeholder")
        }
    }

    func getPlayerContol(control: PlayerControl) {
        switch control {
        case .next:
            self.imageView.sd_cancelCurrentImageLoad()
            if let timer = timerImagePlay {
                timer.removeAllObservers(thenStop: true)
            }
            if let vEnd = self.videoEnd {
                vEnd(true)
            }
        case .previous:
            self.imageView.sd_cancelCurrentImageLoad()
            if let timer = timerImagePlay {
                timer.removeAllObservers(thenStop: true)
            }
            if let previousV = videoPrevious {
                previousV()
            }
        case .play:
            if let timer = timerImagePlay {
                timer.start()
            }
        case .pause:
            if let timer = timerImagePlay {
                timer.pause()
            }
        }
    }

    deinit {
        print("ImagePlayerViewController is deinit")
    }

}
