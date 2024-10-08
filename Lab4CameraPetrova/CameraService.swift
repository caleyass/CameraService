//
//  CameraService.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import AVFoundation

class CameraService: NSObject {
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var photoOutput: AVCapturePhotoOutput?
    
    var onCapturePhoto: ((URL) -> Void)?
    var onCaptureVideo: ((URL) -> Void)?
    
    func startSession() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
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
        
        captureSession?.startRunning()
    }
    
    func switchCamera() {
        // Перемикання між фронтальною та задньою камерами
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecording(to url: URL) {
        videoOutput?.startRecording(to: url, recordingDelegate: self)
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        try? data.write(to: url)
        onCapturePhoto?(url)
    }
}

extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        onCaptureVideo?(outputFileURL)
    }
}
