//
//  FPlayerViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 26.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import AVKit



class FPlayerViewController: AVPlayerViewController {
    typealias CompletionHandler = (_ success:Bool) -> Void
    var videoURL: URL?
    var root : PlayerViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        if let vURL = videoURL{
            self.player = AVPlayer(url: vURL)
            self.player?.volume = 1.0
        }
        
//        Отключаем кнопки управления
        self.showsPlaybackControls = false
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //player?.play()
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            //self.player!.play()
            self.root?.playBtn.isHidden = false
        }
    }
    
    
    deinit {
        print("Fplayer is deinit")
    }
}
