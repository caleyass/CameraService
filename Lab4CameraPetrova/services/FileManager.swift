//
//  FileManager.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import UIKit
import AVFoundation

class MyFileManager {
    
    static let shared = MyFileManager()
    
    private init() {}
    
    private var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveImage(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: currentDateTime)
        
        let filename = dateString + ".jpeg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveVideo(at sourceURL: URL) -> URL? {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: currentDateTime)
        let filename = dateString + ".mp4"
        let destinationURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to save video: \(error.localizedDescription)")
            return nil
        }
    }
    
    func retrieveAllFiles() -> [URL] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("Failed to retrieve files: \(error.localizedDescription)")
            return []
        }
    }
    
    func getLastSavedMediaThumbnail() -> UIImage? {
        let allFiles = retrieveAllFiles()
        
        guard let lastFileURL = allFiles.first else {
            return nil
        }
        
        if lastFileURL.pathExtension == "jpeg" {
            return UIImage(contentsOfFile: lastFileURL.path)
        } else if lastFileURL.pathExtension == "mp4" {
            return generateThumbnailForVideo(at: lastFileURL)
        }
        
        return nil
    }
    
    private func generateThumbnailForVideo(at url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
