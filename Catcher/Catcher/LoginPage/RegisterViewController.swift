//
//  RegisterViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/18/23.
//

import FirebaseAuth
import FirebaseFirestore
import SafariServices
import SnapKit
import UIKit

final class RegisterViewController: BaseViewController {
    private let registerView = RegisterView()
    private let fireManager = FirebaseManager()
    private let titleList = ["[필수] 17세 이상", "[필수] 개인정보 동의서", "[필수] 이용 약관"]
    var selectList: [Bool] = []
    
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
        guard nickName.count < 7 else {
            registerView.nicknametextfield.lblError.text = "6글자까지 입력이 가능합니다"
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
            registerView.passwordtextfield.lblError.text = "비밀번호를 다릅니다"
            registerView.passwordconfirmtextfield.lblError.text = "비밀번호를 다릅니다"
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
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(AppConstraint.headerViewHeight)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    /**
     * @brief 상세 약관 보기 버튼 클릭
     */
    @objc func detailButtonTouched(sender: UIButton) {
        if let url = URL(string: CONSENT) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    /**
     * @brief 상세 약관 보기 버튼 클릭
     */
    @objc func detailTermsUseButtonTouched(sender: UIButton) {
        let vc = TermsOfUseViewController()
        self.navigationPushController(viewController: vc, animated: true)
    }
    
    /**
     * @brief 리스트 선택 버튼 클릭
     */
    @objc func listSelectButtonTouched(sender: UIButton) {
        // 버튼 선택 변경
        sender.isSelected = !sender.isSelected
        // 인덱스
        let index = sender.tag
        // 선택 리스트 상태 변경
        selectList[index] = sender.isSelected
        
        // 전체 동의 하기 버튼 셋팅
        allSelectButtonSetting()
        // 동의 버튼 변경
        agreeButtonClicked()
    }
    
    /** @brief 전체 동의 하기 버튼 셋팅 */
    @objc func allSelectButtonSetting() {
        // 모든 항목 선택 체크
        var intSelectCount = 0
        for index in 0..<selectList.count {
            if selectList[index] == true {
                intSelectCount += 1
            }
        }
        if intSelectCount == selectList.count {
            // 전체 선택
            registerView.allAgreeButton.isSelected = true
        } else {
            // 선택 취소
            registerView.allAgreeButton.isSelected = false
        }
    }
    
    /** @brief 약관 동의 완료 버튼 선택 가능/불가능 변경 */
    func agreeButtonClicked() {
        if selectList[0] == true && selectList[1] == true {
            registerView.nextButton.isEnabled = true
            registerView.nextButton.backgroundColor = ThemeColor.primary
        } else {
            registerView.nextButton.isEnabled = false
            registerView.nextButton.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        }
    }
    
    @objc func allSelectButtonTouched(sender: UIButton) {
        // 버튼 선택 변경
        sender.isSelected = !sender.isSelected
        // 선택 리스트 전체 변경
        for index in 0..<selectList.count {
            selectList[index] = sender.isSelected
        }
        // 테이블 리로드
        registerView.termsTableView.reloadData()
        // 동의 버튼 변경
        agreeButtonClicked()
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
        registerView.allAgreeButton.addTarget(self, action: #selector(allSelectButtonTouched), for: .touchUpInside)
        setKeyboardObserver()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // gesture의 이벤트가 끝나도 뒤에 이벤트를 View로 전달
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        // 선택 리스트 초기화
        for _ in titleList {
            selectList.append(false)
        }
        // tableViewCell 연결
        registerView.termsTableView.register(UINib(nibName: "TermsTableViewCell", bundle: nil), forCellReuseIdentifier: "TermsTableViewCell")
        registerView.termsTableView.delegate = self
        registerView.termsTableView.dataSource = self
        
        setHeaderView()
        setUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
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

extension RegisterViewController {
    override func keyboardWillShow(notification: NSNotification) {
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
    
    override func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        registerView.scrollView.contentInset = contentInsets
        registerView.scrollView.scrollIndicatorInsets = contentInsets
    }
}

extension RegisterViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerView.nicknametextfield.tf {
            registerView.emailtextfield.tf.becomeFirstResponder() // next 버튼 선택 시 -> tfPW 포커싱
        } else if textField == registerView.emailtextfield.tf {
            registerView.passwordtextfield.tf.becomeFirstResponder() // return 버튼 선택 시 -> 키보드 내려감
        } else if textField == registerView.passwordtextfield.tf {
            registerView.passwordconfirmtextfield.tf.becomeFirstResponder()
        } else {
            registerView.passwordconfirmtextfield.tf.resignFirstResponder()
        }
        return true
    }
    
    func customTextFieldValueChanged(_ textfield: UITextField) {
        if textfield == registerView.nicknametextfield.tf {
            registerView.nicknametextfield.isError = false
        } else if textfield == registerView.emailtextfield.tf {
            registerView.emailtextfield.isError = false
        } else if textfield == registerView.passwordtextfield.tf {
            registerView.passwordtextfield.isError = false
        } else {
            registerView.passwordconfirmtextfield.isError = false
        }
    }
    
    func customTextFieldDidEndEditing(_ textField: UITextField) {}
    
    func customTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == registerView.nicknametextfield.tf {
            registerView.nicknametextfield.isError = false
        } else if textField == registerView.emailtextfield.tf {
            registerView.emailtextfield.isError = false
        } else if textField == registerView.passwordtextfield.tf {
            registerView.passwordtextfield.isError = false
        } else {
            registerView.passwordconfirmtextfield.isError = false
        }
    }
    
    func errorStatus(isError: Bool, view: CustomTextField) {}
    
    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30 // 30개 제한
    }
}

extension RegisterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermsTableViewCell", for: indexPath) as! TermsTableViewCell
        
        let index = indexPath.row
        // 선택 버튼 태그 Setting
        cell.btnSelect.tag = index
        // 선택 버튼 클릭 이벤트 셋팅
        cell.btnSelect.addTarget(self, action: #selector(listSelectButtonTouched(sender:)), for: .touchUpInside)
        cell.btnSelect.isSelected = selectList[index]
        // 타이틀 셋팅
        cell.lbTitle.text = titleList[index]
        // 상세 버튼 태그 Setting
        cell.btnDetail.tag = index
        cell.btnDetail.isHidden = (index == 0)
        // 상세 버튼 클릭 이벤트 셋팅
        switch index {
        case 1:
            cell.btnDetail.addTarget(self, action: #selector(detailButtonTouched(sender:)), for: .touchUpInside)
        case 2:
            cell.btnDetail.addTarget(self, action: #selector(detailTermsUseButtonTouched(sender:)), for: .touchUpInside)
        default:
            break
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
