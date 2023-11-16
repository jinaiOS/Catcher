//
//  StorageManager.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation
import FirebaseStorage

/**
 @StorageManager
 - UploadPictureCompletion
 - uploadMessagePhoto: Storage의 message_images에 사진을 업로드하고 다운로드할 URL 문자열로 완료를 반환
 - uploadMessageVideo: Storage의 message_videos에 비디오를 업로드하고 다운로드할 URL 문자열로 완료를 반환
 - downloadURL: Storage에 저장
 */
/// final: 더 이상 상속이 필요없음을 명시, 런타임 성능이 향상
final class StorageManager {

    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()

    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    /// Storage의 message_images에 사진을 업로드하고 다운로드할 URL 문자열로 완료를 반환
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let self else { return }
            guard error == nil else {
                // failed
                CommonUtil.print(output:"failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    CommonUtil.print(output:"Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                CommonUtil.print(output:"download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Storage의 message_videos에 비디오를 업로드하고 다운로드할 URL 문자열로 완료를 반환
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        if let videoData = NSData(contentsOf: fileUrl) as Data? {
            storage.child("message_videos/\(fileName)").putData(videoData, metadata: nil, completion: { [weak self] metadata, error in
                guard let self else { return }
                guard error == nil else {
                    // failed
                    CommonUtil.print(output:"failed to upload video file to firebase for picture")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                    guard let url = url else {
                        CommonUtil.print(output:"Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    CommonUtil.print(output:"download url returned: \(urlString)")
                    completion(.success(urlString))
                })
            })
        }
    }

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

    /// Storage에 저장
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}
