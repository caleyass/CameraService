//
//  ViewController.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var cameraService = CameraService()
    private var capturedMedia: [URL] = []
    
    private var previewView: UIView!
    private var capturePhotoButton: UIButton!
    private var recordButton: UIButton!
    private var switchCameraButton: UIButton!
    private var mediaListButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraService.startSession()
        setupUI()
    }
    
    private func setupUI() {
        // Preview View
        previewView = UIView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        // Capture Photo Button
        capturePhotoButton = UIButton(type: .system)
        capturePhotoButton.setTitle("Capture Photo", for: .normal)
        capturePhotoButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        capturePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturePhotoButton)

        // Record Button
        recordButton = UIButton(type: .system)
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordButton)

        // Switch Camera Button
        switchCameraButton = UIButton(type: .system)
        switchCameraButton.setTitle("Switch Camera", for: .normal)
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchCameraButton)

        // Media List Button
        mediaListButton = UIButton(type: .system)
        mediaListButton.setTitle("View Media", for: .normal)
        mediaListButton.addTarget(self, action: #selector(viewMediaList), for: .touchUpInside)
        mediaListButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mediaListButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),

            capturePhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordButton.bottomAnchor.constraint(equalTo: capturePhotoButton.topAnchor, constant: -20),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            switchCameraButton.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20),
            switchCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mediaListButton.bottomAnchor.constraint(equalTo: switchCameraButton.topAnchor, constant: -20),
            mediaListButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    
    @objc private func capturePhoto() {
        cameraService.capturePhoto()
    }
    
    @objc private func startRecording() {
        let videoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        cameraService.startRecording(to: videoURL)
    }
    
    @objc private func stopRecording() {
        cameraService.stopRecording()
    }
    
    @objc private func toggleRecording() {
        if recordButton.title(for: .normal) == "Start Recording" {
            let videoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
            cameraService.startRecording(to: videoURL)
            recordButton.setTitle("Stop Recording", for: .normal)
        } else {
            cameraService.stopRecording()
            recordButton.setTitle("Start Recording", for: .normal)
        }
    }
    
    @objc private func switchCamera() {
        cameraService.switchCamera()
    }
    
    @objc private func viewMediaList() {
        let mediaListVC = MediaListViewController()
        //mediaListVC.mediaURLs = capturedMedia // Pass the captured media URLs
        navigationController?.pushViewController(mediaListVC, animated: true)
    }

}

