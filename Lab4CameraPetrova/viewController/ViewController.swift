//
//  ViewController.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var capturedMedia: [URL] = []
    
    private var previewView: UIView!
    private var capturePhotoButton: UIButton!
    private var recordButton: UIButton!
    private var switchCameraButton: UIButton!
    private var mediaListButton: UIButton!
    
    private var viewModel: CameraViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CameraViewModel()
        viewModel.startSession()
        setupUI()
    }
    
    private func setupUI() {
        // Preview View
        previewView = UIView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = .black
        
        
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
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            capturePhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordButton.bottomAnchor.constraint(equalTo: capturePhotoButton.topAnchor, constant: -20),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            switchCameraButton.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20),
            switchCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mediaListButton.bottomAnchor.constraint(equalTo: switchCameraButton.topAnchor, constant: -20),
            mediaListButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func setupCameraPreview() {
        if let previewLayer = viewModel.videoPreviewLayer {
            previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(previewLayer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupCameraPreview()
    }
    
    
    @objc private func capturePhoto() {
        viewModel.capturePhoto { [weak self] success in
            if success {
                self?.showAlert(title: "Success", message: "Photo successfully captured and saved.")
            } else {
                self?.showAlert(title: "Error", message: "Failed to capture and save photo.")
            }
        }
    }
    
    @objc private func startRecording() {
        viewModel.startVideoRecording()
    }
    
    @objc private func stopRecording() {
        viewModel.stopVideoRecording{ [weak self] success in
            if success {
                self?.showAlert(title: "Success", message: "Video successfully recorded and saved.")
            } else {
                self?.showAlert(title: "Error", message: "Failed to record and save video.")
            }
        }
    }
    
    @objc private func toggleRecording() {
        if recordButton.title(for: .normal) == "Start Recording" {
            let videoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
        } else {
            stopRecording()
            recordButton.setTitle("Start Recording", for: .normal)
        }
    }
    
    @objc private func switchCamera() {
        viewModel.switchCamera()
    }
    
    @objc private func viewMediaList() {
        if let navController = navigationController {
            let mediaListVC = MediaListViewController()
            navController.pushViewController(mediaListVC, animated: true)
        } else {
            print("Error: navigationController is nil")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

