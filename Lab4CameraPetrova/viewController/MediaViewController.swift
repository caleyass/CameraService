//
//  MediaViewController.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import UIKit
import AVKit
import Photos

class MediaViewController: UIViewController {
    
    var mediaItems: [URL]!
    var currentMediaIndex: Int!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playPauseButton: UIButton!
    private var muteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("init media view controller")
        if mediaItems[currentMediaIndex].pathExtension == "mp4" {
            setupVideoPlayer()
            setupControllers()
        } else {
            setupImageView()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save to gallery", style: .plain, target: self, action: #selector(saveMedia))
    }
    
    
    
    func setupVideoPlayer() {
        player = AVPlayer(url: mediaItems[currentMediaIndex])
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.nextMedia()
        print("next media")
        
    }

    
    func setupControllers() {
        let controlHeight: CGFloat = 60
        let controlWidth: CGFloat = 60
        
        playPauseButton = UIButton(frame: CGRect(x: (view.frame.width - controlWidth) / 2, y: view.frame.height - (controlHeight + 50), width: controlWidth, height: controlHeight))
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        view.addSubview(playPauseButton)
        
        let nextButton = UIButton(frame: CGRect(x: playPauseButton.frame.maxX + 10, y: playPauseButton.frame.minY, width: controlWidth, height: controlHeight))
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextMedia), for: .touchUpInside)
        view.addSubview(nextButton)
        
        let prevButton = UIButton(frame: CGRect(x: playPauseButton.frame.minX - 10 - controlWidth, y: playPauseButton.frame.minY, width: controlWidth, height: controlHeight))
        prevButton.setTitle("Prev", for: .normal)
        prevButton.addTarget(self, action: #selector(previousMedia), for: .touchUpInside)
        view.addSubview(prevButton)
        
        muteButton = UIButton(frame: CGRect(x: 20, y: view.frame.height - (controlHeight + 50), width: controlWidth, height: controlHeight))
        muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        muteButton.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        view.addSubview(muteButton)
    }
    
    func setupImageView() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(contentsOfFile: mediaItems[currentMediaIndex].path)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
    
    @objc func playPause() {
        if player.rate == 0 {
            player.play()
            DispatchQueue.main.async {
                self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        } else {
            player.pause()
            DispatchQueue.main.async {
                self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }
    
    @objc func nextMedia() {
        var nextIndex = currentMediaIndex + 1
        while nextIndex < mediaItems.count {
            if mediaItems[nextIndex].pathExtension == "mp4" {
                currentMediaIndex = nextIndex
                playMediaAtIndex()
                return
            }
            nextIndex += 1
        }
        print("No next video")
    }

    @objc func previousMedia() {
        var prevIndex = currentMediaIndex - 1
        while prevIndex >= 0 {
            if mediaItems[prevIndex].pathExtension == "mp4" {
                currentMediaIndex = prevIndex
                playMediaAtIndex()
                return
            }
            prevIndex -= 1
        }
        print("No prev video")
    }

    func playMediaAtIndex() {
        if player != nil {
            player.pause()
            playerLayer.removeFromSuperlayer()
        }
        
        setupVideoPlayer()
        setupControllers()
        playPause()
    }
    
    @objc func toggleSound() {
        if player.isMuted {
            self.muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        } else {
            self.muteButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }
        player.isMuted.toggle()
    }
    
    @objc func saveMedia() {
        if mediaItems[currentMediaIndex].pathExtension == "mp4" {
            UISaveVideoAtPathToSavedPhotosAlbum(mediaItems[currentMediaIndex].path, self, #selector(videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            if let image = UIImage(contentsOfFile: mediaItems[currentMediaIndex].path) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func videoSaved(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving video: \(error.localizedDescription)")
        } else {
            print("Video saved to photo album.")
        }
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved to photo album.")
        }
    }
}
