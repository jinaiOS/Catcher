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
    private let defaultImage = UIImage(named: "default")
    
    func loadImage(uid: String, completion: @escaping (UIImage?) -> Void) {
        if let image = cachedImage(uid: uid) {
            completion(image)
            return
        }
        storeManager.fetchProfileData(uid: uid) { [weak self] data, error in
            guard let self = self else { return }
            var profileImage: UIImage?
            if let data = data {
                profileImage = UIImage(data: data)
            } else {
                CommonUtil.print(output:error?.localizedDescription ?? "Unknown error")
                profileImage = defaultImage
            }
            cachingImage(uid: uid, image: profileImage)
            completion(profileImage)
        }
    }
    
    func cachingImage(uid: String, image: UIImage?) {
        guard let image = image else { return }
        cache.setObject(image, forKey: uid as NSString)
    }
}

private extension ImageCacheManager {
    func cachedImage(uid: String) -> UIImage? {
        cache.object(forKey: uid as NSString)
    }
}
