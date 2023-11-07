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

class DatabaseManager {
    /// 클래스의 공유 인스턴스입니다.
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
    public func createNewConversation(otherUserUid: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let ref =  database.child(FirebaseManager().getUID ?? "")
        
        ref.observeSingleEvent(of: .value, with: {[weak self] snapshot in
            if let userNode = snapshot.value as? [String: Any] {
                completion(false)
                CommonUtil.print(output:"user not found")
                let messageDate = firstMessage.sentDate
                let dateString = Date.stringFromDate(date: messageDate)
                
                var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
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
                        "sender_uid": FirebaseManager().getUID,
                        "date": dateString,
                        "message": message,
                        "is_read": false,
                        "type": firstMessage.kind.messageKindString
                    ]
                ]
                
                let otherUserNewConversationData: [String: [String: Any]] = [
                    FirebaseManager().getUID ?? "":
                        [
                            "sender_uid": FirebaseManager().getUID,
                            "date": dateString,
                            "message": message,
                            "is_read": false,
                            "type": firstMessage.kind.messageKindString
                        ]
                ]
                
                // Update recipient conversation entry
                
                self?.database.child(FirebaseManager().getUID ?? "").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        //append
                        //                        conversations.append(newConversationData)
                        //                        self?.database.child(self?.userInfo?.uid ?? "").setValue(conversations)
                    } else {
                        // create
                        self?.database.child(FirebaseManager().getUID ?? "").child(otherUserUid).setValue(newConversationData)
                        self?.database.child(otherUserUid).child(FirebaseManager().getUID ?? "").setValue(newConversationData)
                    }
                })
            } else {
                
                let messageDate = firstMessage.sentDate
                let dateString = Date.stringFromDate(date: messageDate)
                
                var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
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
                
                let newConversationData: [String: [[String: Any]]] = [
                    otherUserUid:
                        [
                            [
                                "sender_uid": FirebaseManager().getUID ?? "",
                                "date": dateString,
                                "message": message,
                                "is_read": false,
                                "type": firstMessage.kind.messageKindString
                            ]
                        ]
                ]
                
                let otherUserNewConversationData: [String: [[String: Any]]] = [
                    FirebaseManager().getUID ?? "":
                        [
                            [
                                "sender_uid": FirebaseManager().getUID ?? "",
                                "date": dateString,
                                "message": message,
                                "is_read": false,
                                "type": firstMessage.kind.messageKindString
                            ]
                        ]
                ]
                
                // Update recipient conversation entry
                
                self?.database.child(FirebaseManager().getUID ?? "").child(otherUserUid).observeSingleEvent(of: .value, with: {[weak self] snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        //append
                        conversations.append(newConversationData)
                        self?.database.child(FirebaseManager().getUID ?? "").setValue(conversations)
                    } else {
                        // create
                        self?.database.child(FirebaseManager().getUID ?? "").setValue(newConversationData)
                        self?.database.child(otherUserUid).setValue(otherUserNewConversationData)
                    }
                })
            }
            
            //            // Update current user entry
            //
            //            if var conversations = userNode[userInfo.uid] as? [[String: Any]] {
            //                //conversation array exists for current user
            //                // you should append
            //                conversations.append(newConversationData)
            //                userNode["conversations"] = conversations
            //                ref.setValue(userNode, withCompletionBlock: { [weak self]error, _ in
            //                    guard error == nil else {
            //                        completion(false)
            //                        return
            //                    }
            //                    self?.finishCreatingConversation(name: name,
            //                                                     conversationID: conversationId,
            //                                                     firstMessage: firstMessage,
            //                                                     completion: completion)
            //                })
            //            }
            //            else{
            //                //conversation array does NOT exist
            //                //create it
            //                userNode["conversations"] = [
            //                    newConversationData
            //                ]
            //                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
            //                    guard error == nil else {
            //                        completion(false)
            //                        return
            //                    }
            //
            //                    self?.finishCreatingConversation(name: name,
            //                                                     conversationID: conversationId,
            //                                                     firstMessage: firstMessage,
            //                                                     completion: completion)
            //
            //
            //                })
            //            }
            
        })
    }
    
    public func getAllConversations(completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child(FirebaseManager().getUID ?? "").observe(.value, with: { snapshot in
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
    
    /// Gets all mmessages for a given conversatino
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
                          let isRead = dictionary["is_read"] as? Bool,
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
    
    /// Sends a message with target conversation and message
    public func sendMessage(otherUserUid: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        guard let uid = FirebaseManager().getUID else { return }
        database.child(uid).child(otherUserUid).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
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
            
            strongSelf.database.child("\(FirebaseManager().getUID ?? "")/\(otherUserUid)").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            }
            
            strongSelf.database.child("\(otherUserUid)/\(FirebaseManager().getUID ?? "")").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            }
            completion(true)
        })
    }
    
    public func readMessage(otherUserUid: String, completion: @escaping (Bool) -> Void) {
        database.child(FirebaseManager().getUID ?? "").child(otherUserUid).observeSingleEvent(of: .value, with: { [weak self] snapshot in
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
            self?.database.child(FirebaseManager().getUID ?? "").child(otherUserUid).setValue(value)
            self?.database.child(otherUserUid).child(FirebaseManager().getUID ?? "").setValue(value)
            completion(true)
        })
    }
    
    public func deleteMessage(completion: @escaping (Bool) -> Void) {
        database.child(FirebaseManager().getUID ?? "").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var value = snapshot.value as? [String: [[String: Any]]] else {
                completion(false)
                return
            }
            let otherUserUids: [String] = value.compactMap { dictionary in
                return dictionary.key
            }
            self?.database.child(FirebaseManager().getUID ?? "").removeValue()
            for i in otherUserUids {
                self?.database.child(i).child(FirebaseManager().getUID ?? "").removeValue()
            }
            completion(true)
        })
    }
}
//strongSelf.database.child("\(self?.userInfo?.uid ?? "")/\(uid)").observeSingleEvent(of: .value, with: { snapshot in
//    var databaseEntryConversations = [[String: Any]]()
//    let updatedValue: [String: Any] = [
//        "date": dateString,
//        "is_read": false,
//        "message": message
//    ]
//
//    if var currentUserConversations = snapshot.value as? [[String: Any]] {
//        var targetConversation: [String: Any]?
//        var position = 0
//
//        for conversationDictionary in currentUserConversations {
//            if let currentId = conversationDictionary["id"] as? String, currentId == uid {
//                targetConversation = conversationDictionary
//                break
//            }
//            position += 1
//        }
//
//        if var targetConversation = targetConversation {
//            targetConversation["latest_message"] = updatedValue
//            currentUserConversations[position] = targetConversation
//            databaseEntryConversations = currentUserConversations
//        } else {
//            let newConversationData: [String: Any] = [
//                "id": uid,
//                "other_user_uid": otherUserUid,
//                "name": name,
//                "latest_message": updatedValue
//            ]
//            currentUserConversations.append(newConversationData)
//            databaseEntryConversations = currentUserConversations
//        }
//    } else {
//        let newConversationData: [String: Any] = [
//            "id": uid,
//            "other_user_uid": otherUserUid,
//            "name": name,
//            "latest_message": updatedValue
//        ]
//        databaseEntryConversations = [
//            newConversationData
//        ]
//    }
//
//    strongSelf.database.child("\(DataManager.sharedInstance.userInfo?.uid ?? "")/\(otherUserUid)").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
//        guard error == nil else {
//            completion(false)
//            return
//        }
//
//
//        // Update latest message for recipient user
//
//        strongSelf.database.child("\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
//            let updatedValue: [String: Any] = [
//                "date": dateString,
//                "is_read": false,
//                "message": message
//            ]
//            var databaseEntryConversations = [[String: Any]]()
//
//            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
//                return
//            }
//
//            if var otherUserConversations = snapshot.value as? [[String: Any]] {
//                var targetConversation: [String: Any]?
//                var position = 0
//
//                for conversationDictionary in otherUserConversations {
//                    if let currentId = conversationDictionary["id"] as? String, currentId == uid {
//                        targetConversation = conversationDictionary
//                        break
//                    }
//                    position += 1
//                }
//
//                if var targetConversation = targetConversation {
//                    targetConversation["latest_message"] = updatedValue
//                    otherUserConversations[position] = targetConversation
//                    databaseEntryConversations = otherUserConversations
//                }
//                else {
//                    // failed to find in current colleciton
//                    let newConversationData: [String: Any] = [
//                        "id": uid,
//                        "other_user_uid": otherUserUid,
//                        "name": currentName,
//                        "latest_message": updatedValue
//                    ]
//                    otherUserConversations.append(newConversationData)
//                    databaseEntryConversations = otherUserConversations
//                }
//            }
//            else {
//                // current collection does not exist
//                let newConversationData: [String: Any] = [
//                    "id": uid,
//                    "other_user_uid": otherUserUid,
//                    "name": currentName,
//                    "latest_message": updatedValue
//                ]
//                databaseEntryConversations = [
//                    newConversationData
//                ]
//            }
//
//            strongSelf.database.child("\(otherUserUid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
//                guard error == nil else {
//                    completion(false)
//                    return
//                }
//
//                completion(true)
//            })
//        })
//    })
