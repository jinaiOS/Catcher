//
//  UserInfoViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class UserInfoViewModel {
    private let fireStoreManager = FireStoreManager.shared
    private let userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
}

extension UserInfoViewModel {
    func processPickUser(isUpdate: Bool,
                         completion: @escaping (_ result: [UserInfo]?, _ error: Error?) -> Void) {
        Task {
            var result: [UserInfo]?
            var error: Error?
            
            if isUpdate {
                error = await fireStoreManager.updatePickUser(uuid: userInfo.uid)
            } else {
                error = await fireStoreManager.deletePickUser(uuid: userInfo.uid)
            }
            if let error = error {
                completion(nil, error)
                return
            }
            
            (result, error) = await fireStoreManager.fetchPickUsers()
            if let error = error {
                completion(nil, error)
                return
            }
            completion(result, nil)
        }
    }
    
    func makeInfoText(info: UserInfo) -> NSMutableAttributedString {
        let newLine = NSAttributedString(string: "\n")
        
        let locationLabel = NSAttributedString.makeUserInfoText(
            text: "지역: \(info.location)",
            alignment: .left,
            range: (0, 2))
        
        let birthLabel = NSAttributedString.makeUserInfoText(
            text: "나이: 만 \(calculateAge(birthDate: info.birth))세",
            alignment: .left,
            range: (0, 2))
        
        let heightLabel = NSAttributedString.makeUserInfoText(
            text: "키: \(info.height)cm",
            alignment: .left,
            range: (0, 1))
        
        let educationLabel = NSAttributedString.makeUserInfoText(
            text: "학력: \(info.education)",
            alignment: .left,
            range: (0, 2))
        
        let scoreLabel = NSAttributedString.makeUserInfoText(
            text: "점수: \(info.score)점",
            alignment: .left,
            range: (0, 2))
        
        let drinkingLabel = NSAttributedString.makeUserInfoText(
            text: "음주: \(info.drinking)",
            alignment: .left,
            range: (0, 2))
        
        let smokingLabel = NSAttributedString.makeUserInfoText(
            text: "흡연: \(info.smoking)",
            alignment: .left,
            range: (0, 2))
        
        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(locationLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(birthLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(heightLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(educationLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(scoreLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(drinkingLabel)
        combinedAttributedString.append(newLine)
        combinedAttributedString.append(smokingLabel)
        
        return combinedAttributedString
    }
}

private extension UserInfoViewModel {
    func calculateAge(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        let age = ageComponents.year ?? 0
        
        return age
    }
}
