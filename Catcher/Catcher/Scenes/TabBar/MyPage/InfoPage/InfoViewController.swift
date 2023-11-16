//
//  InfoViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import UIKit

protocol UpdateUserInfo: AnyObject {
    func updateUserInfo()
}

/**
 @class InfoViewController.swift

 @brief BaseHeaderViewController를 상속받은 ViewController

 @detail 유저의 프로필을 등록, 수정하는  LoginViewController
 */
final class InfoViewController: BaseHeaderViewController {
    private let db = Firestore.firestore()
    private let infoView: InfoView
    private let userInfo: UserInfo?
    var newUserEmail: String?
    var newUserPassword: String?
    var newUserNickName: String?
    let pickerRegion = UIPickerView()
    let pickerMbti = UIPickerView()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        return formatter
    }()

    weak var delegate: UpdateUserInfo?

    var mbti = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISFJ", "ESTJ", "ESFJ",
        "ISTP", "ISFP", "ESTP", "ESFP",
    ]
    var region = [
        "서울특별시",
        "경기도",
        "인천광역시",
        "강원도",
        "충청북도",
        "충청남도",
        "대전광역시",
        "전라북도",
        "전라남도",
        "광주광역시",
        "경상북도",
        "경상남도",
        "대구광역시",
        "부산광역시",
        "제주특별자치도",
    ]

    override func loadView() {
        super.loadView()
        view = infoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configPickerView()
        setKeyboardObserver()
        infoView.saveButton.addTarget(self, action: #selector(completeBtn), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // gesture의 이벤트가 끝나도 뒤에 이벤트를 View로 전달
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setHeaderTitleName(title: "기본 프로필 설정")
        setUI()
        configure()
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }

    init(userInfo: UserInfo? = nil, isValidNickName: Bool = false) {
        self.userInfo = userInfo
        self.infoView = InfoView(isValidNickName: isValidNickName)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        CommonUtil.print(output: "deinit - InfoVC")
    }
}

extension InfoViewController {
    /** @brief 키보드가 올라왔을때 뷰 높이 조절 */
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            infoView.scrollView.contentInset = contentInsets
            infoView.scrollView.scrollIndicatorInsets = contentInsets

            // 텍스트 필드가 가려지지 않도록 스크롤 위치 조절
            if let activeTextField = findActiveTextField() {
                let rect = activeTextField.convert(activeTextField.bounds, to: infoView.scrollView)
                infoView.scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }

    /** @brief 키보드가 내려갔을때 뷰 높이 조절 */
    override func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        infoView.scrollView.contentInset = contentInsets
        infoView.scrollView.scrollIndicatorInsets = contentInsets
    }
}

private extension InfoViewController {
    /** @brief Mypage에서 InforView로 넘어올때 추가되는 objects */
    func configure() {
        guard let userInfo = userInfo else { return }
        infoView.nickNameTextField.tf.text = userInfo.nickName
        infoView.regionTextField.tf.text = userInfo.location
        infoView.birthTextField.tf.text = "만 \(Date.calculateAge(birthDate: userInfo.birth))세"
        infoView.birthTextField.lblTitle.text = "나이"
        infoView.birthTextField.tf.isEnabled = false
        infoView.mbtiTextField.tf.text = userInfo.mbti
        infoView.introduceTextField.tf.text = userInfo.introduction
        infoView.heightTextField.tf.text = "\(userInfo.height)"
    }

    func findActiveTextField() -> UITextField? {
        for case let textField as UITextField in infoView.contentView.subviews where textField.isFirstResponder {
            return textField
        }
        return nil
    }

    /** @brief 완료 버튼 눌렀을때 동작 */
    @objc func completeBtn(sender: UIButton) {
        sender.debounce()
        infoView.regionTextField.isError = false
        infoView.birthTextField.isError = false
        infoView.mbtiTextField.isError = false
        infoView.heightTextField.isError = false
        infoView.nickNameTextField.isError = false
        infoView.introduceTextField.isError = false

        var birth: Date?

        guard let location = infoView.regionTextField.tf.text, !location.isEmpty else {
            infoView.regionTextField.isError = true
            return
        }

        if userInfo == nil {
            guard let birthText = infoView.birthTextField.tf.text, let birthDate = dateFormatter.date(from: birthText) else {
                infoView.birthTextField.isError = true
                return
            }
            birth = birthDate
        }

        guard let mbti = infoView.mbtiTextField.tf.text, !mbti.isEmpty else {
            infoView.mbtiTextField.isError = true
            return
        }
        guard let height = infoView.heightTextField.tf.text, !height.isEmpty else {
            infoView.heightTextField.isError = true
            return
        }
        guard let introduce = infoView.introduceTextField.tf.text, !introduce.isEmpty else {
            infoView.introduceTextField.lblError.text = "자기소개를 입력해주세요"
            infoView.introduceTextField.isError = true

            return
        }
        guard introduce.count < 16 else {
            infoView.introduceTextField.lblError.text = "15글자 이하로 적어주세요"
            infoView.introduceTextField.isError = true
            return
        }

        if userInfo == nil {
            // 회원가입
            guard let nickName = newUserNickName else { return }
            guard let newUserEmail = newUserEmail, let newUserPassword = newUserPassword else { return }
            let profileSettingViewController = ProfileSettingViewController(allowAlbum: false)
            profileSettingViewController.user = UserInfo(
                uid: "", sex: "", birth: birth ?? Date(),
                nickName: nickName,
                location: location,
                height: Int(height) ?? 0,
                mbti: mbti,
                introduction: introduce,
                register: Date(),
                pick: []
            )
            profileSettingViewController.newUserEmail = newUserEmail
            profileSettingViewController.newUserPassword = newUserPassword
            navigationController?.pushViewController(profileSettingViewController, animated: true)
            return
        } else {
            // 프로필 수정
            guard let uid = FirebaseManager().getUID else { return }
            guard let nickName = infoView.nickNameTextField.tf.text, !nickName.isEmpty else {
                infoView.nickNameTextField.lblError.text = "닉네임을 입력해주세요"
                infoView.nickNameTextField.isError = true
                return
            }
            guard nickName.count < 7 else {
                infoView.nickNameTextField.lblError.text = "6글자까지 입력이 가능합니다"
                infoView.nickNameTextField.isError = true
                return
            }
            let userUpadate = UserInfo(
                uid: "",
                sex: "",
                birth: birth ?? Date(),
                nickName: nickName,
                location: location,
                height: Int(height) ?? 0,
                mbti: mbti,
                introduction: introduce
            )

            let userDocRef = db.collection("userInfo").document(uid)
            userDocRef.updateData([
                "nickName": userUpadate.nickName,
                "location": userUpadate.location,
                "height": userUpadate.height,
                "mbti": userUpadate.mbti,
                "introduction": userUpadate.introduction,
            ]) { error in
                if let error = error {
                    // Handle the error, e.g., show an alert to the user.
                    print("Error updating user information: \(error.localizedDescription)")
                } else {
                    // Information updated successfully.
                    print("User information updated successfully.")
                    self.navigationPopToRootViewController(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.updateUserInfo()
                    }
                }
            }
            UserDefaultsManager().setValue(value: location, key: "location")
        }
    }

    /// regionTextField의 DoneButton 클릭시 이벤트
    @objc func pickerDoneButtonTapped() {
        infoView.regionTextField.tf.resignFirstResponder()
    }

    /// mbtiTextField의 DoneButton 클릭시 이벤트
    @objc func mbtiPickerDoneButtonTapped() {
        infoView.mbtiTextField.tf.resignFirstResponder()
    }

    /// birthTextField의 DoneButton 클릭시 이벤트
    @objc func birthPickerDoneButtonTapped() {
        infoView.birthTextField.tf.resignFirstResponder()
    }

    /// 값이 변하면 UIDatePicker에서 날자를 받아와 형식을 변형해서 textField에 넣어줍니다./
    @objc func dateChange(_ sender: UIDatePicker) {
        infoView.birthTextField.tf.text = dateFormat(date: sender.date)
    }

    func setUI() {
        infoView.regionTextField.initTextFieldText(placeHolder: "지역을 선택해주세요", delegate: self)
        infoView.regionTextField.lblTitle.text = "지역"
        infoView.regionTextField.lblError.text = "지역을 선택해주세요"

        infoView.birthTextField.initTextFieldText(placeHolder: "생년월일을 선택해 주세요", delegate: self)
        infoView.birthTextField.lblTitle.text = "생일"
        infoView.birthTextField.lblError.text = "생년월일을 선택해 주세요"

        infoView.mbtiTextField.initTextFieldText(placeHolder: "MBTI를 선택해 주세요", delegate: self)
        infoView.mbtiTextField.lblTitle.text = "MBTI"
        infoView.mbtiTextField.lblError.text = "MBTI를 선택해 주세요"

        infoView.heightTextField.initTextFieldText(placeHolder: "키를 입력해 주세요", delegate: self)
        infoView.heightTextField.lblTitle.text = "키"
        infoView.heightTextField.lblError.text = "키를 입력해 주세요"

        infoView.nickNameTextField.initTextFieldText(placeHolder: "닉네임을 입력해 주세요", delegate: self)
        infoView.nickNameTextField.lblTitle.text = "닉네임"

        infoView.introduceTextField.initTextFieldText(placeHolder: "15글자 이하로 작성해주세요", delegate: self)
        infoView.introduceTextField.lblTitle.text = "한 줄 자기소개"
    }
}

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // delegate, datasource 연결 및 picker를 textfied의 inputview로 설정한다
    func configPickerView() {
        pickerRegion.delegate = self
        pickerRegion.dataSource = self

        pickerMbti.delegate = self
        pickerMbti.dataSource = self
        infoView.mbtiTextField.tf.inputView = pickerMbti
        infoView.regionTextField.tf.inputView = pickerRegion
        
        // Add a toolbar with a custom button title
        let toolbar = createToolbar(target: self, action: #selector(pickerDoneButtonTapped))
        let mbtiToolbar = createToolbar(target: self, action: #selector(mbtiPickerDoneButtonTapped))
        let birthToolbar = createToolbar(target: self, action: #selector(birthPickerDoneButtonTapped))

        let datePicker = UIDatePicker()
        // datePickerModed에는 time, date, dateAndTime, countDownTimer가 존재합니다.
        datePicker.datePickerMode = .date
        // datePicker 스타일을 설정합니다. wheels, inline, compact, automatic이 존재합니다.
        datePicker.preferredDatePickerStyle = .wheels
        // 원하는 언어로 지역 설정도 가능합니다.
        datePicker.locale = Locale(identifier: "ko-KR")
        // 값이 변할 때마다 동작을 설정해 줌
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        // textField의 inputView가 nil이라면 기본 할당은 키보드입니다.
        infoView.regionTextField.tf.inputAccessoryView = toolbar
        infoView.mbtiTextField.tf.inputAccessoryView = mbtiToolbar
        infoView.birthTextField.tf.inputAccessoryView = birthToolbar
        infoView.birthTextField.tf.inputView = datePicker
        // textField에 오늘 날짜로 표시되게 설정
        infoView.birthTextField.tf.text = dateFormat(date: Date())
    }
    
    // UIToolbar 및 UIBarButtonItem을 생성하는 함수
    func createToolbar(target: Any, action: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .clear
        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: target, action: action)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        return toolbar
    }

    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        return formatter.string(from: date)
    }

    // pickerview는 하나만
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // pickerview의 선택지는 데이터의 개수만큼
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var num = 0
        if pickerView == pickerRegion {
            num = region.count
        }
        if pickerView == pickerMbti {
            num = mbti.count
        }
        return num
    }

    // pickerview 내 선택지의 값들을 원하는 데이터로 채워준다.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerRegion {
            return region[row]
        }
        if pickerView == pickerMbti {
            return mbti[row]
        }
        return nil
    }

    // textfield의 텍스트에 pickerview에서 선택한 값을 넣어준다.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerRegion {
            infoView.regionTextField.tf.text = region[row]
        }
        if pickerView == pickerMbti {
            infoView.mbtiTextField.tf.text = mbti[row]
        }
    }
}

extension InfoViewController: CustomTextFieldDelegate {
    /**
     @brief CustomTextFieldDelegate의 Delegate
     */
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == infoView.regionTextField.tf {
            infoView.birthTextField.tf.becomeFirstResponder() // next 버튼 선택 시 -> tfPW 포커싱
        } else if textField == infoView.birthTextField.tf {
            infoView.mbtiTextField.tf.becomeFirstResponder() // return 버튼 선택 시 -> 키보드 내려감
        } else if textField == infoView.mbtiTextField.tf {
            infoView.heightTextField.tf.becomeFirstResponder()
        } else {
            infoView.heightTextField.tf.resignFirstResponder()
        }
        return true
    }

    func customTextFieldValueChanged(_ textfield: UITextField) {
        if textfield == infoView.regionTextField.tf {
            infoView.regionTextField.isError = false
        } else if textfield == infoView.birthTextField.tf {
            infoView.birthTextField.isError = false
        } else if textfield == infoView.mbtiTextField.tf {
            infoView.mbtiTextField.isError = false
        } else {
            infoView.heightTextField.isError = false
        }
    }

    func customTextFieldDidEndEditing(_ textField: UITextField) {}

    func customTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == infoView.regionTextField.tf {
            infoView.regionTextField.isError = false
        } else if textField == infoView.birthTextField.tf {
            infoView.birthTextField.isError = false
        } else if textField == infoView.mbtiTextField.tf {
            infoView.mbtiTextField.isError = false
        } else {
            infoView.heightTextField.isError = false
        }
    }

    func errorStatus(isError: Bool, view: CustomTextField) {}

    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30 // 30개 제한
    }
}
