//
//  CameraService.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import AVFoundation
import UIKit

class CameraService: NSObject {
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?

    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var onCapturePhoto: ((URL) -> Void)?
    var onCaptureVideo: ((URL) -> Void)?
    
    func startSession() {
        checkPermissions()
        setupSession()
    }
    
    private func setupSession(){
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let currentDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: currentDevice)
        } catch {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if (captureSession?.canAddOutput(videoOutput!) ?? false) {
            captureSession?.addOutput(videoOutput!)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if (captureSession?.canAddOutput(photoOutput!) ?? false) {
            captureSession?.addOutput(photoOutput!)
        }
        
        if let captureSession = captureSession {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
        }
        
        captureSession?.startRunning()
    }
    
    func switchCamera() {
        guard let currentDevice = currentDevice else { return }
        if let captureSession {
            captureSession.beginConfiguration()
            captureSession.removeInput(captureSession.inputs.first!)
            
            let newDevice: AVCaptureDevice
            if currentDevice.position == .back {
                newDevice = CameraService.device(position: .front)!
            } else {
                newDevice = CameraService.device(position: .back)!
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: newDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    self.currentDevice = newDevice
                }
            } catch {
                print("Error switching camera: \(error.localizedDescription)")
            }
            
            captureSession.commitConfiguration()
        }
    }
    
    static func device(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        guard photoOutput?.connection(with: .video) != nil else {
            completion(false)
            return
        }

        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        completion(true)
    }
    
    func startRecording() {
        
        do {
            let session = AVAudioSession.sharedInstance()
            if session.category != .record {
                try session.setCategory(.record)
                try session.setActive(true)
            }
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }

        let outputPath = NSTemporaryDirectory() + "video.mp4"
        let outputURL = URL(fileURLWithPath: outputPath)
        videoOutput?.startRecording(to: outputURL, recordingDelegate: self)
        
    }
    
    func stopRecording(completion: @escaping (Bool) -> Void) {
        videoOutput?.stopRecording()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error.localizedDescription)")
        }
        completion(true)
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        case .denied:
            break
        @unknown default:
            break
        }
    }
    
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error processing photo: \(String(describing: error?.localizedDescription))")
            return
        }

        if let imageData = photo.fileDataRepresentation() {
            if let capturedImage = UIImage(data: imageData) {
                if let savedURL = MyFileManager.shared.saveImage(capturedImage) {
                    print("Image saved at \(savedURL)")
                } else {
                    print("Failed to save image to app's document directory.")
                }
            }
        }
    }
}

extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        onCaptureVideo?(outputFileURL)
    }
}
