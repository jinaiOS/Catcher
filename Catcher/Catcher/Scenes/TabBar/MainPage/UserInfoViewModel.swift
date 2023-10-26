//
//  UserInfoViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class UserInfoViewModel {
    let userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
}

extension UserInfoViewModel {
    func setPickButtonImage(state: Bool) -> UIImage {
        let image = state ? UIImage(systemName: "heart.fill") : UIImage(systemName: "suit.heart")
        return image ?? UIImage()
    }
    
    func togglePickBtnImage(image: UIImage) -> UIImage {
        let buttonImage = image == UIImage(systemName: "heart.fill") ? UIImage(systemName: "suit.heart") : UIImage(systemName: "heart.fill")
        return buttonImage ?? UIImage()
    }
    
    func makeInfo(info: UserInfo) -> String {
        let smoking = info.smoking ? "흡연" : "비흡연"
        
        let text = """
        닉네임: \(info.nickName)
        키: \(info.height)
        체형: \(info.body)
        음주: \(info.drinking)
        흡연: \(smoking)
        학력: \(info.education)
        지역: \(info.location)
        점수: \(info.score)
        """
        return text
    }
}
