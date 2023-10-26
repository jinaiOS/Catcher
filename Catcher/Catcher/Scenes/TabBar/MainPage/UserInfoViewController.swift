//
//  UserInfoViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class UserInfoViewController: UIViewController {
    private let userInfoView = UserInfoView()
    
    override func loadView() {
        super.loadView()
        
        view = userInfoView
    }
    
    func configure(info: UserInfo) {
        ImageCacheManager.shared.loadImage(uid: info.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userInfoView.profileImageView.image = image
            }
        }
        
        userInfoView.textView.text = makeInfo(info: info)
        userInfoView.remakeLayout()
    }
    
    func setPickButtonImage(state: Bool) {
        let image = state ? UIImage(systemName: "heart.fill") : UIImage(systemName: "suit.heart")
        userInfoView.pickButton.setImage(image, for: .normal)
    }
    
    init(info: UserInfo) {
        super.init(nibName: nil, bundle: nil)
        configure(info: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTarget()
    }
    
    deinit {
        print("deinit - UserInfoVC")
    }
}

private extension UserInfoViewController {
    func setTarget() {
        userInfoView.closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
    }
    
    @objc func closeView() {
        dismiss(animated: true)
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
