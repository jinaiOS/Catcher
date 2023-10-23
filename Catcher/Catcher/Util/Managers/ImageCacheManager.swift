//
//  ImageCacheManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() { }
    
    private let storeManager = FireStorageManager.shared
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(uid: String, completion: @escaping (UIImage?) -> Void) {
        var profileImage: UIImage?
        if let image = cachedImage(uid: uid) {
            completion(image)
            return
        }
        storeManager.fetchProfileData(uid: uid) { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else { return }
            profileImage = UIImage(data: data)
            cachingImage(uid: uid, image: profileImage)
            completion(profileImage)
        }
    }
}

private extension ImageCacheManager {
    func cachingImage(uid: String, image: UIImage?) {
        guard let image = image else { return }
        cache.setObject(image, forKey: uid as NSString)
    }
    
    func cachedImage(uid: String) -> UIImage? {
        cache.object(forKey: uid as NSString)
    }
}
