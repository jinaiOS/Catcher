//
//  FirebaseStorageManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import FirebaseStorage

enum FireStorageError: Error {
    case noMetaData
    case noResult
}

enum ImageError: Error {
    case cantConvertJpeg
}

final class FireStorageManager {
    static let shared = FireStorageManager()
    private let storage = Storage.storage()
    
    private let chatImagePath = "chat"
    private let profileImagePath = "profile"
    private let fileSize: Int64 = 1024
    private let compressionQuality: CGFloat = 0.7
    private var uid: String?
    
    private init() {
        uid = FirebaseManager().getUID
    }
}

extension FireStorageManager {
    func setChatImageData(chatID: String, imageID: String, image: UIImage, completion: @escaping (Error?) -> Void) {
        let data = makeImageData(image: image, completion: completion)
        let spaceRef = makeChatRef(chatID: chatID, imageID: imageID)
        putData(spaceRef: spaceRef, imageData: data, completion: completion)
    }
    
    func fetchChatImageData(chatID: String, imageID: String, completion: @escaping (Data?, Error?) -> Void) {
        let spaceRef = makeChatRef(chatID: chatID, imageID: imageID)
        fetchData(spaceRef: spaceRef, completion: completion)
    }
    
    func allChatImage(chatID: String, completion: @escaping (_ imageList: [String]?, Error?) -> Void) {
        let path = "\(chatImagePath)/\(chatID)"
        let storageReference = storage.reference().child(path)
        storageReference.listAll { (result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let result = result else {
                completion(nil, FireStorageError.noResult)
                return
            }
            let imageList = result.items.map { $0.name }
            completion(imageList, nil)
        }
    }
    
    func deleteChatImageData(chatID: String, imageID: String, completion: @escaping (Error?) -> Void) {
        let spaceRef = makeChatRef(chatID: chatID, imageID: imageID)
        deleteData(spaceRef: spaceRef, completion: completion)
    }
}

extension FireStorageManager {
    func setProfileData(image: UIImage, completion: @escaping (Error?) -> Void) {
        let data = makeImageData(image: image, completion: completion)
        let spaceRef = makeProfileRef
        putData(spaceRef: spaceRef, imageData: data, completion: completion)
    }
    
    func fetchProfileData(completion: @escaping (Data?, Error?) -> Void) {
        let spaceRef = makeProfileRef
        fetchData(spaceRef: spaceRef, completion: completion)
    }
    
    func deleteProfileData(completion: @escaping (Error?) -> Void) {
        let spaceRef = makeProfileRef
        deleteData(spaceRef: spaceRef, completion: completion)
    }
}

private extension FireStorageManager {
    func makeChatRef(chatID: String, imageID: String) -> StorageReference? {
        let storageRef = storage.reference()
        let pathRef = storageRef.child(chatImagePath)
        let spaceRef = pathRef.child(chatID)
        let imageRef = spaceRef.child(imageID)
        
        return imageRef
    }
    
    var makeProfileRef: StorageReference? {
        guard let uid = uid else { return nil }
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
            guard let metadata = metadata else {
                completion(FireStorageError.noMetaData)
                return
            }
            print("metaData: \(metadata)")
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
