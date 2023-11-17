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
        viewModel = UserInfoViewModel(userInfo: info, isPicked: isPicked, isBlocked: isBlocked)
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
        ImageCacheManager.shared.loadImage(uid: viewModel.userInfo.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userInfoView.profileImageView.image = image
            }
        }
        if viewModel.isPicked {
            userInfoView.pickButton.isSelected = true
        } else {
            userInfoView.pickButton.isSelected = false
        }
        
        if viewModel.isBlocked {
            userInfoView.blockBtton.isSelected = true
            userInfoView.blockLabel.text = "해제"
        } else {
            userInfoView.blockBtton.isSelected = false
            userInfoView.blockLabel.text = "차단"
        }
        userInfoView.configure(userInfo: viewModel.userInfo)
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
        if viewModel.isMe {
            showAlert(title: "신고 불가", message: "본인을 신고할 수 없습니다.")
            return
        }
        let reportVC = ReportViewController(
            userinfo: viewModel.userInfo,
            isPicked: viewModel.isPicked,
            isBlocked: viewModel.isBlocked)
        navigationPushController(viewController: reportVC, animated: true)
        dismiss(animated: true)
    }
    
    @objc func pressChattingBtn() {
        if viewModel.isMe {
            showAlert(title: "대화 불가", message: "본인과 대화할 수 없습니다.")
            return
        }
        listenForMessages()
    }
    
    @objc func pressPickBtn(sender: UIButton) {
        if viewModel.isMe {
            showAlert(title: "찜 불가", message: "본인을 찜할 수 없습니다.")
            return
        }
        sender.throttle()
        sender.isSelected.toggle()
        let selected = sender.isSelected
        
        viewModel.processPickUser(isUpdate: selected) { [weak self] result, error in
            guard let self = self else { return }
            pickResultHandling(result: result, error: error)
        }
    }
    
    @objc func pressBlockBtn(sender: UIButton) {
        if viewModel.isMe {
            showAlert(title: "차단 불가", message: "본인을 차단할 수 없습니다.")
            return
        }
        
        if sender.isSelected == true {
            viewModel.processBlockUser(isBlock: false) { [weak self] result, error in
                guard let self else { return }
                DispatchQueue.main.async {
                    sender.isSelected.toggle()
                    let selected = sender.isSelected
                    
                    if selected {
                        self.userInfoView.blockLabel.text = "해제"
                    } else {
                        self.userInfoView.blockLabel.text = "차단"
                    }
                    self.blockResultHandling(result: result, error: error)
                    
                }
            }
            return
        }
        showReportAlert(sender: sender)
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
    
    func showAlert(title: String, message: String,
                   _ firstActionHandler: (() -> Void)? = nil, _ secondActionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            firstActionHandler?()
        }
        alert.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            present(alert, animated: true)
        }
    }
    
    func showReportAlert(sender: UIButton) {
        let alert = AlertFactory.makeAlert(
            title: "차단 확인",
            message: "차단을 하면 상대방이 채팅을 보낼 수 없습니다.\n 차단하시겠습니까?",
            firstActionTitle: "차단",
            firstActionStyle: .destructive,
            firstActionHandler: { [weak self] in
                guard let self else { return }
                sender.isSelected.toggle()
                let selected = sender.isSelected
                
                if selected {
                    userInfoView.blockLabel.text = "해제"
                } else {
                    userInfoView.blockLabel.text = "차단"
                }
                viewModel.processBlockUser(isBlock: selected) { result, error in
                    self.blockResultHandling(result: result, error: error)
                }
            },
            secondActionTitle: "취소",
            secondActionStyle: .default)
        present(alert, animated: true)
    }
    
    func listenForMessages() {
        DatabaseManager.shared.getAllMessagesForConversation(with: viewModel.userInfo.uid) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let messages):
                CommonUtil.print(output:"success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    CommonUtil.print(output:"messages are empty")
                    sendMessageBtn(isNewConversation: true)
                    return
                }
                sendMessageBtn(isNewConversation: false)
            case .failure(let error):
                sendMessageBtn(isNewConversation: true)
                CommonUtil.print(output:"failed to get messages: \(error)")
            }
        }
    }
    
    func sendMessageBtn(isNewConversation: Bool) {
        guard let uid = FirebaseManager().getUID else { return }
        
        viewModel.isBlockedUser(
            searchTarget: viewModel.userInfo.uid,
            containUID: uid) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if result {
                        self.showAlert(title: "차단 상태", message: "상대방이 차단해서 메시지를 보낼 수 없습니다.")
                        return
                    }
                    let vc = ChattingDetailViewController(otherUid: self.viewModel.userInfo.uid)
                    vc.isNewConversation = isNewConversation
                    vc.modalChecking = true
                    vc.title = self.viewModel.userInfo.nickName
                    vc.headerTitle = self.viewModel.userInfo.nickName
                    self.present(vc, animated: true)
                }
            }
    }
}
