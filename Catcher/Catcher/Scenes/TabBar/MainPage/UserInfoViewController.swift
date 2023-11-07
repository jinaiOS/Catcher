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
    func updateBlockUser()
}

final class UserInfoViewController: BaseViewController {
    private let userInfoView = UserInfoView()
    private let viewModel: UserInfoViewModel
    private var userInfo: UserInfo?
    private var isPicked: Bool
    private var isBlocked: Bool
    
    weak var delegate: UpdatePickUserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTarget()
    }
    
    override func loadView() {
        super.loadView()
        view = userInfoView
    }
    
    init(info: UserInfo, isPicked: Bool, isBlocked: Bool) {
        viewModel = UserInfoViewModel(userInfo: info)
        self.userInfo = info
        self.isPicked = isPicked
        self.isBlocked = isBlocked
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CommonUtil.print(output:"deinit - UserInfoVC")
    }
}

private extension UserInfoViewController {
    func configure() {
        guard let userInfo = userInfo else { return }
        ImageCacheManager.shared.loadImage(uid: userInfo.uid) { [weak self] image in
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
        
        if isBlocked {
            userInfoView.blockBtton.isSelected = true
            userInfoView.blockLabel.text = "채팅 차단"
        } else {
            userInfoView.blockBtton.isSelected = false
            userInfoView.blockLabel.text = "차단 해제"
        }
        
        let infoText = viewModel.makeInfoText(info: userInfo)
        let textHeight = infoText.height
        userInfoView.configure(nickName: userInfo.nickName, infoText: infoText)
        userInfoView.remakeLayout(textHeight: textHeight)
    }
    
    func setTarget() {
        userInfoView.closeButton.addTarget(self, action: #selector(pressCloseBtn), for: .touchUpInside)
        userInfoView.reportButton.addTarget(self, action: #selector(pressReportBtn), for: .touchUpInside)
        userInfoView.chatButton.addTarget(self, action: #selector(pressChattingBtn), for: .touchUpInside)
        userInfoView.pickButton.addTarget(self, action: #selector(pressPickBtn), for: .touchUpInside)
        userInfoView.blockBtton.addTarget(self, action: #selector(pressBlockBtn), for: .touchUpInside)
    }
}

private extension UserInfoViewController {
    @objc func pressCloseBtn() {
        dismiss(animated: true)
    }
    
    @objc func pressReportBtn() {
        let reportVC = ReportViewController(userinfo: userInfo, isPicked: isPicked, isBlocked: isBlocked)
        navigationPushController(viewController: reportVC, animated: true)
        dismiss(animated: true)
    }
    
    @objc func pressChattingBtn() {
        listenForMessages()
    }
    
    @objc func pressPickBtn(sender: UIButton) {
        sender.isSelected.toggle()
        let selected = sender.isSelected
        
        viewModel.processPickUser(isUpdate: selected) { [weak self] result, error in
            guard let self = self else { return }
            pickResultHandling(result: result, error: error)
        }
    }
    
    @objc func pressBlockBtn(sender: UIButton) {
        sender.isSelected.toggle()
        let selected = sender.isSelected
        
        if selected {
            userInfoView.blockLabel.text = "채팅 차단"
        } else {
            userInfoView.blockLabel.text = "차단 해제"
        }
        
        viewModel.processBlockUser(isBlock: selected) { [weak self] result, error in
            guard let self = self else { return }
            blockResultHandling(result: result, error: error)
        }
    }
}

private extension UserInfoViewController {
    func pickResultHandling(result: [UserInfo]?, error: Error?) {
        if let error = error {
            CommonUtil.print(output:error.localizedDescription)
            showAlert(title: "네트워크 오류", message: "잠시 후 다시 시도해 주세요")
            return
        }
        guard let result = result else {
            showAlert(title: "네트워크 오류", message: "잠시 후 다시 시도해 주세요")
            return
        }
        delegate?.updatePickUser(info: result)
        return
    }
    
    func blockResultHandling(result: Bool, error: Error?) {
        if let error = error {
            CommonUtil.print(output:error.localizedDescription)
            showAlert(title: "네트워크 오류", message: "잠시 후 다시 시도해 주세요")
            return
        }
        delegate?.updateBlockUser()
        return
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            present(alert, animated: true)
        }
    }
    
    func listenForMessages() {
        DatabaseManager.shared.getAllMessagesForConversation(with: userInfo?.uid ?? "", completion: { [weak self] result in
            switch result {
            case .success(let messages):
                CommonUtil.print(output:"success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    CommonUtil.print(output:"messages are empty")
                    self?.sendMessageBtn(isNewConversation: true)
                    return
                }
                self?.sendMessageBtn(isNewConversation: false)
            case .failure(let error):
                self?.sendMessageBtn(isNewConversation: true)
                CommonUtil.print(output:"failed to get messages: \(error)")
            }
        })
    }
    
    func sendMessageBtn(isNewConversation: Bool) {
        guard let uid = FirebaseManager().getUID,
              let userInfo = self.userInfo else { return }
        
        viewModel.isBlockedUser(searchTarget: userInfo.uid, containUID: uid) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if result {
                    self.showAlert(title: "차단 상태", message: "상대방이 차단해서 메시지를 보낼 수 없습니다.")
                    return
                }
                let vc = ChattingDetailViewController(otherUid: userInfo.uid)
                vc.isNewConversation = isNewConversation
                vc.modalChecking = true
                vc.headerTitle = userInfo.nickName
                self.present(vc, animated: true)
            }
        }
    }
}
