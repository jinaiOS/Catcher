//
//  ProfileSettingViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class ProfileSettingViewModel {
    private let detectObject = DetectObject()
    private let distinguishGender = DistinguishGender()
    private let genProfile = GenerateProfile()
    private let nearUserPath = "location"
    var profileImage: UIImage?
    var gender: String?
}

extension ProfileSettingViewModel {
    func registerUser(user: UserInfo, eamil: String, password: String, completion: @escaping (Bool) -> Void) {
        FirebaseManager().createUsers(
            email: eamil,
            password: password
        ) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                CommonUtil.print(output: "Error creating user: \(error)")
                completion(false)
                return
            } else {
                UserDefaultsManager().setValue(value: user.location, key: nearUserPath)
                let firebaseManager = FirebaseManager()
                guard let uid = firebaseManager.getUID else {
                    CommonUtil.print(output: "Error: No UID available")
                    completion(false)
                    return
                }
                let userInfo = makeUserInfo(user: user, uid: uid)
                setUserInfo(userInfo: userInfo, completion: completion)
            }
        }
    }

    func updateProfile(completion: @escaping (UIImage?) -> Void) {
        guard let profileImage = profileImage else {
            completion(nil)
            return
        }
        FireStorageManager.shared.setProfileData(image: profileImage) { _ in
            completion(profileImage)
        }
    }
}

extension ProfileSettingViewModel {
    func imageTasking(image: UIImage) -> (image: UIImage?, gender: String?) {
        let objects = detectObject.detect(image: image)
        let genders = distinguishGender.analyzeImage(image: image)
        
        guard let objects = objects,
              let male = genders?["male"],
              let female = genders?["female"] else {
            return (nil, nil)
        }
        if objects.contains("person") {
            let gender = compareGender(male: male, female: female)
            if let problem: Bool = UserDefaultsManager().getValue(forKey: UserDefaultsManager.keyName.problem.key) {
                if problem {
                    let cropedImage = image.cropSquare()
                    return (cropedImage, gender)
                }
                let generatedImage = self.genProfile.generateImage(image: image)
                return (generatedImage, gender)
            }
        }
        return (nil, nil)
    }
}

private extension ProfileSettingViewModel {
    func compareGender(male: Double, female: Double) -> String {
        if male >= female {
            return "남성"
        }
        return "여성"
    }

    func setUserInfo(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        Task {
            let error = await FireStoreManager.shared.setUserInfo(data: userInfo)
            if let error = error {
                CommonUtil.print(output: "Error saving user info: \(error.localizedDescription)")
                return
            }
            setProfileImage(completion: completion)
            CommonUtil.print(output: "User info saved to Firestore successfully.")
        }
    }

    func setProfileImage(completion: @escaping (Bool) -> Void) {
        guard let profileImage = profileImage else {
            completion(false)
            return
        }
        FireStorageManager.shared.setProfileData(image: profileImage) { error in
            if let error {
                CommonUtil.print(output: error.localizedDescription)
                completion(false)
                return
            }
            CommonUtil.print(output: "Profile Image saved to Storage successfully.")
            completion(true)
        }
    }

    func makeUserInfo(user: UserInfo, uid: String) -> UserInfo {
        UserInfo(
            uid: uid,
            sex: gender ?? "남성",
            birth: user.birth,
            nickName: user.nickName,
            location: user.location,
            height: Int(user.height),
            mbti: user.mbti,
            introduction: user.introduction,
            register: Date(),
            pick: [],
            block: []
        )
    }
}
