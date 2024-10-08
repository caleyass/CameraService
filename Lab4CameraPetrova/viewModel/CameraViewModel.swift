//
//  CameraViewModel.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import AVFoundation

final class CameraViewModel {
    
    private let cameraService = CameraService()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        return cameraService.videoPreviewLayer
    }
        
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        cameraService.capturePhoto(completion: completion)
    }
    
    func startSession() {
        cameraService.startSession()
    }
    
    func startVideoRecording() {
        cameraService.startRecording( )
    }
    
    func stopVideoRecording(completion: @escaping (Bool) -> Void) {
        cameraService.stopRecording { success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func switchCamera() {
        cameraService.switchCamera()
    }
    func stopSession() {
        cameraService.stopSession()
    }
    func startRunSession() {
        cameraService.startRunSession()
    }
}


enum MediaType {
    case photo, video
}
