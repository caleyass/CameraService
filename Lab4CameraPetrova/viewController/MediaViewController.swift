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
        
        // Check if media is video or image
        if mediaItems[currentMediaIndex].pathExtension == "mp4" {
            setupVideoPlayer()
            setupControls()
        } else {
            setupImageView()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveMedia))
    }
    
    
    
    func setupVideoPlayer() {
        player = AVPlayer(url: mediaItems[currentMediaIndex])
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        DispatchQueue.main.async {
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.nextMedia()
        }
    }

    
    func setupControls() {
        let controlHeight: CGFloat = 50
        let controlWidth: CGFloat = 50
        
        // Play/Pause button
        playPauseButton = UIButton(frame: CGRect(x: (view.frame.width - controlWidth) / 2, y: view.frame.height - (controlHeight + 50), width: controlWidth, height: controlHeight))
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        view.addSubview(playPauseButton)
        
        // Next button
        let nextButton = UIButton(frame: CGRect(x: playPauseButton.frame.maxX + 20, y: playPauseButton.frame.minY, width: controlWidth, height: controlHeight))
        nextButton.setTitle("⏭", for: .normal) // Using emoji as a placeholder
        nextButton.addTarget(self, action: #selector(nextMedia), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Previous button
        let prevButton = UIButton(frame: CGRect(x: playPauseButton.frame.minX - 20 - controlWidth, y: playPauseButton.frame.minY, width: controlWidth, height: controlHeight))
        prevButton.setTitle("⏮", for: .normal) // Using emoji as a placeholder
        prevButton.addTarget(self, action: #selector(previousMedia), for: .touchUpInside)
        view.addSubview(prevButton)
        
        // Mute/Unmute button
        muteButton = UIButton(frame: CGRect(x: 20, y: view.frame.height - (controlHeight + 50), width: controlWidth, height: controlHeight))
        muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
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
            player.pause() // pause current video if any
            
            playerLayer.removeFromSuperlayer() // remove current player layer from view
        }
        
        setupVideoPlayer() // setup the new video player
        playPause()
    }
    
    @objc func toggleMute() {
        if player.isMuted {
            DispatchQueue.main.async {
                self.muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            }
        } else {
            DispatchQueue.main.async {
                self.muteButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            }
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
            // Handle the error
            print("Error saving video: \(error.localizedDescription)")
        } else {
            // Video saved successfully
            print("Video saved to photo album.")
        }
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Image saved successfully
            print("Image saved to photo album.")
        }
    }
}
