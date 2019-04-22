//
//  MusicPlayer.swift
//  BusinessSystemSolutionsTemplate
//
//  Created by Anil Kumar on 29/11/18.
//  Copyright © 2018 Webbleu. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import UIKit

class musicPlayer {
    public static var instance = musicPlayer()
    var player = AVPlayer()
    var playURL = ""
    func initPlayer(view : UIViewController) {
        guard let url = URL.init(string: playURL) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        let playerController = AVPlayerViewController()
        player = AVPlayer.init(playerItem: playerItem)
        playerController.player = player
        view.present(playerController, animated: true) {
            self.player.play()
        }
        playAudioBackground()
    }
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func pause(){
        player.pause()
    }
    
    func play() {
        player.play()
    }
}
