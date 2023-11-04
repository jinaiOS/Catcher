//
//  RegisterViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/18/23.
//

import FirebaseAuth
import FirebaseFirestore
import SnapKit
import UIKit
final class RegisterViewController: BaseViewController {
    private let registerView = RegisterView()
    private let fireManager = FirebaseManager()

    /** @brief 공통 헤더 객체 */
    var headerView: CommonHeaderView!

    @objc func nextPressed() {
        registerView.nicknametextfield.isError = false
        registerView.emailtextfield.isError = false
        registerView.passwordtextfield.isError = false
        registerView.passwordconfirmtextfield.isError = false
        guard let nickName = registerView.nicknametextfield.tf.text, !nickName.isEmpty else {
            registerView.nicknametextfield.lblError.text = "닉네임을 입력해주세요"
            registerView.nicknametextfield.isError = true
            return
        }

        guard let email = registerView.emailtextfield.tf.text, CommonUtil.isValidId(id: email) else {
            registerView.emailtextfield.lblError.text = "올바른 이메일 형식을 입력해 주세요"
            registerView.emailtextfield.isError = true
            return
        }

        guard let password = registerView.passwordtextfield.tf.text, !password.isEmpty else {
            registerView.passwordtextfield.lblError.text = "비밀번호를 입력해주세요"
            registerView.passwordconfirmtextfield.lblError.text = "비밀번호를 입력해주세요"
            registerView.passwordtextfield.isError = true
            registerView.passwordconfirmtextfield.isError = true

            return
        }

        guard password == registerView.passwordconfirmtextfield.tf.text else {
            registerView.passwordtextfield.lblError.text = "비밀번호를 다르다"
            registerView.passwordconfirmtextfield.lblError.text = "비밀번호를 다르다"
            registerView.passwordtextfield.isError = true
            registerView.passwordconfirmtextfield.isError = true
            return
        }
        let passwordCheck = CommonUtil.isValidPassWord(pw: password)
        guard passwordCheck == "" else {
            registerView.passwordtextfield.lblError.text = passwordCheck
            registerView.passwordconfirmtextfield.lblError.text = passwordCheck
            registerView.passwordtextfield.isError = true
            registerView.passwordconfirmtextfield.isError = true
            return
        }

        //        guard let nickName = registerView.nicknametextfield.text else { return }
        //        guard let email = registerView.emailtextfield.text else { return }
        //        guard let password = registerView.passwordtextfield.text else { return }
        Task {
            do {
                let (isAvailable, error) = try await FireStoreManager.shared.nickNamePass(nickName: nickName)
                if let error = error { print("Error checking nickName availability: \(error.localizedDescription)")
                    return
                }
                if isAvailable == true {
                    // 닉네임 사용 가능
                    // 이후 회원가입 프로세스 진행
                    let vcInfo = InfoViewController()
                    vcInfo.newUserEmail = email
                    vcInfo.newUserPassword = password
                    vcInfo.newUserNickName = nickName
                    navigationPushController(viewController: vcInfo, animated: true)
                } else {
                    // 닉네임 이미 사용 중
                    registerView.nicknametextfield.lblError.text = "중복된 닉네임이 있습니다."
                    registerView.nicknametextfield.isError = true
                }
            } catch {
                print("Error checking nickName availability: \(error.localizedDescription)")
            }
        }
    }


    func setHeaderView() {
        headerView = CommonHeaderView(frame: CGRect(x: 0, y: Common.kStatusbarHeight, width: Common.SCREEN_WIDTH(), height: 50))

        view.addSubview(headerView)

        headerView.lblTitle.text = "회원가입"
        headerView.btnBack.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }

    /**
     @brief backButton을 눌렀을때 들어오는 이벤트

     @param sender 버튼 객체
     */
    @objc func backButtonTouched(sender: UIButton) {
        navigationPopViewController(animated: true) { () in }
    }

    override func loadView() {
        super.loadView()
        view.addSubview(registerView)

        registerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            registerView.scrollView.contentInset = contentInsets
            registerView.scrollView.scrollIndicatorInsets = contentInsets

            // 텍스트 필드가 가려지지 않도록 스크롤 위치 조절
            if let activeTextField = findActiveTextField() {
                let rect = activeTextField.convert(activeTextField.bounds, to: registerView.scrollView)
                registerView.scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        registerView.scrollView.contentInset = contentInsets
        registerView.scrollView.scrollIndicatorInsets = contentInsets
    }

    // 현재 활성화된 텍스트 필드 찾기
    private func findActiveTextField() -> UITextField? {
        for case let textField as UITextField in registerView.contentView.subviews where textField.isFirstResponder {
            return textField
        }
        return nil
    }

    override func viewDidLoad() {
        registerView.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // gesture의 이벤트가 끝나도 뒤에 이벤트를 View로 전달
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setHeaderView()
        setUI()
    }

    func setUI() {
        registerView.nicknametextfield.initTextFieldText(placeHolder: "닉네임을 입력해 주세요", delegate: self)
        registerView.nicknametextfield.lblTitle.text = "닉네임"
        registerView.nicknametextfield.tf.autocorrectionType = .no
//        registerView.nicknametextfield.lblError.text = "닉네임이 중복되었습니다."
        registerView.nicknametextfield.tf.keyboardType = .emailAddress
        registerView.nicknametextfield.tf.returnKeyType = .next

        registerView.emailtextfield.initTextFieldText(placeHolder: "이메일을 입력해 주세요", delegate: self)
        registerView.emailtextfield.lblTitle.text = "이메일"
//        registerView.emailtextfield.lblError.text = "올바른 이메일 형식을 입력해 주세요"
        registerView.emailtextfield.tf.keyboardType = .emailAddress
        registerView.emailtextfield.tf.returnKeyType = .next

        registerView.passwordtextfield.initTextFieldText(placeHolder: "비밀번호를 입력해 주세요", delegate: self)
        registerView.passwordtextfield.lblTitle.text = "비밀번호"
//        registerView.passwordtextfield.lblError.text = "올바른 비밀번호 형식을 입력해 주세요"
        registerView.passwordtextfield.tf.returnKeyType = .next
        registerView.passwordtextfield.textFieldIsPW(isPW: true)

        registerView.passwordconfirmtextfield.initTextFieldText(placeHolder: "비밀번호를 다시 입력해 주세요", delegate: self)
        registerView.passwordconfirmtextfield.lblTitle.text = "비밀번호 확인"
//        registerView.passwordconfirmtextfield.lblError.text = "올바른 비밀번호 형식을 입력해 주세요"
        registerView.passwordconfirmtextfield.tf.returnKeyType = .done
        registerView.passwordconfirmtextfield.textFieldIsPW(isPW: true)
    }
}

extension RegisterViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerView.emailtextfield.tf {
            registerView.passwordtextfield.tf.becomeFirstResponder() // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            registerView.passwordtextfield.tf.resignFirstResponder() // return 버튼 선택 시 -> 키보드 내려감
        }
        return true
    }

    func customTextFieldValueChanged(_ textfield: UITextField) {
        if textfield == registerView.emailtextfield.tf {
            registerView.emailtextfield.isError = false // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            registerView.passwordtextfield.isError = false // return 버튼 선택 시 -> 키보드 내려감
        }
    }

    func customTextFieldDidEndEditing(_ textField: UITextField) {}

    func customTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == registerView.emailtextfield.tf {
            registerView.emailtextfield.isError = false // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            registerView.passwordtextfield.isError = false // return 버튼 선택 시 -> 키보드 내려감
        }
    }

    func errorStatus(isError: Bool, view: CustomTextField) {}

    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30 // 30개 제한
    }
}
