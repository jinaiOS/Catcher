//
//  RevokeViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

/**
@class RevokeViewController.swift

@brief BaseHeaderViewController를 상속받은 ViewController

@detail 네비게이션 Header가 있는 BaseHeaderViewController
*/
final class RevokeViewController: BaseHeaderViewController {
    private let revokeView = RevokeView()
    private let viewModel = RevokeViewModel()
    
    override func loadView() {
        super.loadView()
        
        view = revokeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        configure()
        setButtonTarget()
    }
    
    deinit {
        CommonUtil.print(output: "deinit - RevokeVC")
    }
}

private extension RevokeViewController {
    
    /**
     @brief LoginView의 Constaints 설정
     */
    func setLayout() {
        revokeView.addSubview(revokeView.indicator)
        view.addSubview(revokeView.indicatorView)
        
        revokeView.indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        revokeView.indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func configure() {
        setHeaderTitleName(title: "회원 탈퇴")
    }
    
    func setButtonTarget() {
        revokeView.revokeBtn.addTarget(
            self,
            action: #selector(pressRevokeBtn),
            for: .touchUpInside)
    }
    
    func processIndicatorView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            revokeView.indicatorView.isHidden.toggle()
            if revokeView.indicator.isAnimating {
                revokeView.indicator.stopAnimating()
            } else {
                revokeView.indicator.startAnimating()
            }
        }
    }
    
    @objc func pressRevokeBtn(sender: UIButton) {
        reAuthenticateAlert()
    }
}

private extension RevokeViewController {
    
    /** @brief 유저 삭제 경고 Alert  */
    func reAuthenticateAlert() {
        var alert = UIAlertController()
        
        alert = UIAlertController(
            title: "사용자 인증이 필요합니다",
            message: "탈퇴 처리를 하기 위해 로그인을 하여 사용자 인증을 해야 합니다.",
            preferredStyle: .alert)
        
        let reAuthAction = UIAlertAction(title: "사용자 인증", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let userPW = alert.textFields?[0].text ?? ""
            if userPW.count < 6 {
                showAlert(title: "비밀번호 입력 오류", message: "비밀번호를 6자리 이상을 입력해 주세요")
                return
            }
            processIndicatorView()
            viewModel.reAuthenticate(password: userPW) { result in
                self.processIndicatorView()
                if result {
                    self.askRevokeAlert()
                    return
                }
                self.showAlert(title: "사용자 인증 실패", message: "사용자 인증에 실패하였습니다. 다시 인증해 주세요")
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            navigationPopToRootViewController(animated: true, completion: nil)
        }
        alert.addAction(reAuthAction)
        alert.addAction(cancelAction)
        alert.addTextField {
            $0.placeholder = "비밀번호를 6자리 이상을 입력해 주세요"
            $0.keyboardType = .asciiCapable
            $0.isSecureTextEntry = true
        }
        self.present(alert, animated: true)
    }
    
    /** @brief 확인 Alert  */
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    /** @brief 마지막 경고 Alert  */
    func askRevokeAlert() {
        let alert = UIAlertController(
            title: "정말 탈퇴하시겠습니까?",
            message: "탈퇴하시면 사용자의 모든 정보가 삭제되고 복구할 수 없습니다.",
            preferredStyle: .alert)
        
        let revokeAction = UIAlertAction(
            title: "탈퇴하기",
            style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                processIndicatorView()
                viewModel.removeAllInfo {
                    DispatchQueue.main.async {
                        self.processIndicatorView()
                        self.revokeDoneAlert()
                    }
                }
            }
        
        let cancelAction = UIAlertAction(
            title: "계정 유지",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                navigationPopToRootViewController(animated: true, completion: nil)
            }
        
        alert.addAction(revokeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

private extension RevokeViewController {
    /// 주의!!! 탈퇴 완료 Alert
    func revokeDoneAlert() {
        let alert = UIAlertController(
            title: "탈퇴 완료",
            message: "Catcher를 종료합니다.",
            preferredStyle: .alert)
        
        let revokeAction = UIAlertAction(
            title: "확인",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.closeApp()
            }
        alert.addAction(revokeAction)
        self.present(alert, animated: true)
    }
    
    /// 주의!!! 자연스럽게 앱 종료하기
    func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
