//
//  FirebaseStorageManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import FirebaseStorage

final class FireStorageManager {
    static let shared = FireStorageManager()
    private let storage = Storage.storage()
    
    private let profileImagePath = "profile"
    private let fileSize: Int64 = 1024
    private let compressionQuality: CGFloat = 0.5
    
    private init() {}
    
    enum FireStorageError: Error {
        case noMetaData
        case noResult
        case missingUID
    }
    
    enum ImageError: Error {
        case cantConvertJpeg
    }
}

extension FireStorageManager {
    func setProfileData(image: UIImage, completion: @escaping (Error?) -> Void) {
        let data = makeImageData(image: image, completion: completion)
        let spaceRef = makeProfileRef(uid: FirebaseManager().getUID ?? "")
        putData(spaceRef: spaceRef, imageData: data, completion: completion)
    }
    
    func fetchProfileData(uid: String, completion: @escaping (Data?, Error?) -> Void) {
        let spaceRef = makeProfileRef(uid: uid)
        fetchData(spaceRef: spaceRef, completion: completion)
    }
    
    func deleteProfileData(completion: @escaping (Error?) -> Void) {
        let spaceRef = makeProfileRef(uid: FirebaseManager().getUID ?? "")
        deleteData(spaceRef: spaceRef, completion: completion)
    }
}

private extension FireStorageManager {
    func makeProfileRef(uid: String) -> StorageReference? {
        let storageRef = storage.reference()
        let pathRef = storageRef.child(profileImagePath)
        let spaceRef = pathRef.child(uid)
        
        return spaceRef
    }
}

private extension FireStorageManager {
    func makeImageData(image: UIImage, completion: @escaping (Error?) -> Void) -> Data {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            completion(ImageError.cantConvertJpeg)
            return Data()
        }
        return data
    }
}

private extension FireStorageManager {
    func putData(spaceRef: StorageReference?, imageData: Data, completion: @escaping (Error?) -> Void) {
        spaceRef?.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let _ = metadata else {
                completion(FireStorageError.noMetaData)
                return
            }
            completion(nil)
        }
    }
    
    func fetchData(spaceRef: StorageReference?, completion: @escaping (Data?, Error?) -> Void) {
        spaceRef?.getData(maxSize: 1 * fileSize * fileSize) { data, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    func deleteData(spaceRef: StorageReference?, completion: @escaping (Error?) -> Void) {
        spaceRef?.delete { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
