//
//  UserInfoViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

protocol UpdatePickUserInfo: AnyObject {
    func updatePickUser(info: [UserInfo])
}

final class UserInfoViewController: UIViewController {
    private let userInfoView = UserInfoView()
    private let viewModel: UserInfoViewModel
    
    weak var delegate: UpdatePickUserInfo?
    var userInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTarget()
    }
    
    override func loadView() {
        super.loadView()
        view = userInfoView
    }
    
    init(info: UserInfo, isPicked: Bool) {
        viewModel = UserInfoViewModel(userInfo: info)
        userInfo = info
        super.init(nibName: nil, bundle: nil)
        configure(info: info, isPicked: isPicked)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CommonUtil.print(output:"deinit - UserInfoVC")
    }
}

private extension UserInfoViewController {
    func configure(info: UserInfo, isPicked: Bool) {
        ImageCacheManager.shared.loadImage(uid: info.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userInfoView.profileImageView.image = image
            }
        }
        if isPicked {
            userInfoView.pickButton.isSelected = true
        } else {
            userInfoView.pickButton.isSelected = false
        }
        let infoText = viewModel.makeInfoText(info: info)
        let textHeight = infoText.height
        userInfoView.configure(nickName: info.nickName, infoText: infoText)
        userInfoView.remakeLayout(textHeight: textHeight)
    }
    
    func setTarget() {
        userInfoView.closeButton.addTarget(self, action: #selector(didTappedCloseBtn), for: .touchUpInside)
        userInfoView.pickButton.addTarget(self, action: #selector(didTappedPickBtn), for: .touchUpInside)
        userInfoView.chatButton.addTarget(self, action: #selector(pressChattingButton), for: .touchUpInside)
    }
    
    @objc func didTappedCloseBtn() {
        dismiss(animated: true)
    }
    
    @objc func didTappedPickBtn(sender: UIButton) {
        sender.isSelected.toggle()
        let selected = sender.isSelected
        
        viewModel.processPickUser(isUpdate: selected) { [weak self] result, error in
            guard let self = self else { return }
            resultHandling(result: result, error: error)
        }
    }
}

private extension UserInfoViewController {
    func resultHandling(result: [UserInfo]?, error: Error?) {
        if let error = error {
            CommonUtil.print(output:error.localizedDescription)
            showAlert()
            return
        }
        guard let result = result else {
            showAlert()
            return
        }
        delegate?.updatePickUser(info: result)
        return
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "네트워크 오류", message: "잠시 후 다시 시도해 주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc func pressChattingButton() {
        let vc = ChattingDetailViewController(otherUid: userInfo?.uid ?? "")
        vc.isNewConversation = true
        vc.modalChecking = true
        vc.headerTitle = userInfo?.nickName
        self.present(vc, animated: true)
    }
}
