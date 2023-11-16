//
//  DatabaseManager.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/27.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation
import UIKit
import AVFoundation

/**
 @DatabaseManager
 - createNewConversation: 새로운 대화를 요청 (otherUserUid: String, firstMessage: Message) -> Bool
 - getAllConversations: 전체 대화 불러오기 -> [Conversation], Error
 - getAllMessagesForConversation: 상세 대화 불러오기 -> [Message], Error
 - sendMessage: Sends a message
 - readMessage: 메시지 읽으면 읽음으로 변경
 */
class DatabaseManager {
    public static let shared = DatabaseManager()
    
    private let storeManager = FireStoreManager.shared
    
    private let database = Database.database(url: "https://catcher-dcac0-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    var otherUserInfo: UserInfo? = nil
}

extension DatabaseManager {
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "데이터 가져오기 실패"
            }
        }
    }
}

extension DatabaseManager {
    /// 새로운 대화를 요청 (otherUserUid: String, firstMessage: Message) -> Bool
    public func createNewConversation(otherUserUid: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let ref =  database.child(FirebaseManager().getUID ?? "")
            
            let messageDate = firstMessage.sentDate
            let dateString = Date.stringFromDate(date: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }
            
            let newConversationData: [[String: Any]] = [
                [
                    "sender_uid": FirebaseManager().getUID ?? "",
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    "type": firstMessage.kind.messageKindString
                ]
            ]
            requestCreateConversations(otherUserUid: otherUserUid, newConversationData: newConversationData)
    }
    
    private func requestCreateConversations(otherUserUid: String, newConversationData: [[String: Any]]) {
        self.database.child(FirebaseManager().getUID ?? "").observeSingleEvent(of: .value, with: {[weak self] snapshot in
            guard let self else { return }
            database.child(FirebaseManager().getUID ?? "").child(otherUserUid).setValue(newConversationData)
            database.child(otherUserUid).child(FirebaseManager().getUID ?? "").setValue(newConversationData)
        })
    }
    
    /// 전체 대화 불러오기 -> [Conversation], Error
    public func getAllConversations(completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child(FirebaseManager().getUID ?? "").observe(.value, with: {[weak self] snapshot in
            guard let self else { return }
            guard let value = snapshot.value as? [String: [[String: Any]]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            Task {
                var conversationStore: [String] = []
                var conversationsHave : [Conversation] = []
                let lastDictionaries: [[String: Any]] = value.compactMap { (a, lastArray) in
                    conversationStore.append(a)
                    if conversationStore == [] {
                        conversationStore.remove(at: 0)
                    }
                    return lastArray.last
                }
                let conversations: [Conversation] = lastDictionaries.compactMap { dictionary in
                    guard let senderUid = dictionary["sender_uid"] as? String,
                          let message = dictionary["message"] as? String,
                          let date = dictionary["date"] as? String,
                          let isRead = dictionary["is_read"] as? Bool,
                          let kind = dictionary["type"] as? String else {
                        return nil
                    }
                    return Conversation(name: "", senderUid: senderUid, kind: ConversationKind(rawValue: kind) ?? .Text, message: message, date: date, isRead: isRead, otherUserUid: "")
                }
                conversationsHave = conversations
                var nickNames: [String] = []
                for key in conversationStore {
                    async let otherUserInfo = self.storeManager.fetchUserInfo(uuid: key)
                    let otherUserInfoResult = await otherUserInfo
                    nickNames.append(otherUserInfoResult.result?.nickName ?? "")
                    if nickNames == [] {
                        nickNames.remove(at: 0)
                    }
                }
                for i in 0..<conversationsHave.count {
                    conversationsHave[i].otherUserUid = conversationStore[i]
                    conversationsHave[i].name = nickNames[i]
                }
                let conversationsComplete = self.storeConversations(conversations: conversationsHave)
                DispatchQueue.main.async {
                    completion(.success(conversationsComplete))
                }
            }
        })
    }
    
    func storeConversations(conversations: [Conversation]) -> [Conversation] {
        return conversations
    }
    
    /// 상세 대화 불러오기 -> [Message], Error
    public func getAllMessagesForConversation(with uid: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child(FirebaseManager().getUID ?? "").child(uid).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            Task {
                async let otherUserInfo = self.storeManager.fetchUserInfo(uuid: uid)
                let otherUserInfoResult = await otherUserInfo
                let messages: [Message] = value.compactMap({ dictionary in
                    guard let name = otherUserInfoResult.0?.nickName,
                          let content = dictionary["message"] as? String,
                          let senderUid = dictionary["sender_uid"] as? String,
                          let type = dictionary["type"] as? String,
                          let dateString = dictionary["date"] as? String else {
                        return nil
                    }
                    var kind: MessageKind?
                    if type == "photo" {
                        // photo
                        guard let imageUrl = URL(string: content),
                              let placeHolder = UIImage(systemName: "plus") else {
                            return nil
                        }
                        let media = Media(url: imageUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 300, height: 300))
                        kind = .photo(media)
                    }
                    else if type == "video" {
                        // photo
                        guard let videoUrl = URL(string: content) else { return nil }
                        let myAsset = AVAsset(url: videoUrl)
                        let imageGenerator = AVAssetImageGenerator(asset: myAsset)
                        let time: CMTime = CMTime(value: 600, timescale: 600)
                        guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else { fatalError() }
                        
                        let uiImage: UIImage? = UIImage(cgImage: cgImage)
                        guard let placeHolder = uiImage else {
                            return nil
                        }
                        
                        let media = Media(url: videoUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 300, height: 300))
                        kind = .video(media)
                    }
                    else if type == "location" {
                        let locationComponents = content.components(separatedBy: ",")
                        guard let longitude = Double(locationComponents[0]),
                              let latitude = Double(locationComponents[1]) else {
                            return nil
                        }
                        CommonUtil.print(output:"Rendering location; long=\(longitude) | lat=\(latitude)")
                        let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                                size: CGSize(width: 300, height: 300))
                        kind = .location(location)
                    }
                    else {
                        kind = .text(content)
                    }
                    
                    guard let finalKind = kind else {
                        return nil
                    }
                    
                    let sender = Sender(photoURL: "",
                                        senderId: senderUid,
                                        displayName: name)
                    
                    return Message(sender: sender,
                                   messageId: senderUid,
                                   sentDate: Date.dateFromyyyyMMddHHmm(str: dateString) ?? .now,
                                   kind: finalKind)
                })
                
                completion(.success(messages))
            }
        })
    }
    
    /// Sends a message
    public func sendMessage(otherUserUid: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        guard let uid = FirebaseManager().getUID else { return }
        database.child(uid).child(otherUserUid).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self else { return }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = Date.stringFromDate(date: messageDate)
            
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }
            
            let newMessageEntry: [String: Any] = [
                "type": newMessage.kind.messageKindString,
                "message": message,
                "date": dateString,
                "sender_uid": FirebaseManager().getUID ?? "",
                "is_read": false
            ]
            
            currentMessages.append(newMessageEntry)
            
            database.child("\(FirebaseManager().getUID ?? "")/\(otherUserUid)").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            }
            
            database.child("\(otherUserUid)/\(FirebaseManager().getUID ?? "")").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            }
            completion(true)
        })
    }
    
    /// 메시지 읽으면 읽음으로 변경
    public func readMessage(otherUserUid: String, completion: @escaping (Bool) -> Void) {
        database.child(FirebaseManager().getUID ?? "").child(otherUserUid).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self else { return }
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            for i in 0..<value.count {
                if value[i]["sender_uid"] as? String == otherUserUid {
                    value[i]["is_read"] = true
                }
            }
            
            // 변경된 데이터를 다시 저장
            database.child(FirebaseManager().getUID ?? "").child(otherUserUid).setValue(value)
            database.child(otherUserUid).child(FirebaseManager().getUID ?? "").setValue(value)
            completion(true)
        })
    }
    
    public func deleteMessage(completion: @escaping (Bool) -> Void) {
        database.child(FirebaseManager().getUID ?? "").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self else { return }
            guard let value = snapshot.value as? [String: [[String: Any]]] else {
                completion(false)
                return
            }
            let otherUserUids: [String] = value.compactMap { dictionary in
                return dictionary.key
            }
            database.child(FirebaseManager().getUID ?? "").removeValue()
            for i in otherUserUids {
                database.child(i).child(FirebaseManager().getUID ?? "").removeValue()
            }
            completion(true)
        })
    }
}
