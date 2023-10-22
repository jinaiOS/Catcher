//
//  LocalFileManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import UIKit
import Combine

final class LocalFileManager {
    static let shared = LocalFileManager()
    private init() { }
}

extension LocalFileManager {
    func setImage(imageName: String, imgData: Data, completion: @escaping (_ url: String?, Error?) -> Void) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else { return }
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                completion(nil, error)
                return
            }
        }
        
        do {
            try imgData.write(to: imageURL)
            completion(imageName, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func fetchImage(imageName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        var img: UIImage?
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
            img = image
        }
        return img
    }
    
    func deleteImage(imageName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("프로필 이미지 삭제 완료")
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
