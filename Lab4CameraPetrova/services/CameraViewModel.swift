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
    
    private var mediaType : MediaType = .photo
    var isRecordingVideo: Bool = false
    
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        cameraService.capturePhoto(completion: completion)
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
}


enum MediaType {
    case photo, video
}
