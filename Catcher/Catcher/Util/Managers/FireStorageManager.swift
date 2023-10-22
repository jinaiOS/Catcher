//
//  FirebaseStorageManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import FirebaseStorage

enum FireStorageError: Error {
    case noMetaData
}

final class FireStorageManager {
    static let shared = FireStorageManager()
    private let storage = Storage.storage()
    
    private let profileImagePath = "profile"
    private let fileSize: Int64 = 1024
    private var uid: String?
    
    private init() {
        uid = FirebaseManager().getUID
    }
}

extension FireStorageManager {
    func setProfileData(imageData: Data, compeltion: @escaping (Error?) -> Void) {
        guard let uid = uid else { return }
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(profileImagePath)
        let spaceRef = imagesRef.child(uid)
        
        spaceRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                compeltion(error)
                return
            }
            guard let metadata = metadata else {
                compeltion(FireStorageError.noMetaData)
                return
            }
            print("metaData: \(metadata)")
            compeltion(nil)
        }
    }
    
    func fetchProfileData(completion: @escaping (Data?, Error?) -> Void) {
        guard let uid = uid else { return }
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(profileImagePath)
        let spaceRef = imagesRef.child(uid)
        
        spaceRef.getData(maxSize: 1 * fileSize * fileSize) { data, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    func deleteProfileData(completion: @escaping (Error?) -> Void) {
        guard let uid = uid else { return }
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(profileImagePath)
        let spaceRef = imagesRef.child(uid)
        
        spaceRef.delete { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
