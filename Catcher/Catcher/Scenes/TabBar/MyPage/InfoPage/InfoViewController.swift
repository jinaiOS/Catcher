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
final class InfoViewController: BaseHeaderViewController {
    var newUserEmail: String?
    var newUserPassword: String?
    var newUserNickName: String?
    private let infoView = InfoView()
    let pickerRegion = UIPickerView()
    let pickerEducation = UIPickerView()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        return formatter
    }()

    var education = ["박사", "학사", "대졸", "고졸", "중졸"]
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
        "제주특별자치도"
    ]

    override func loadView() {
        super.loadView()
        view.addSubview(infoView)

        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
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

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        infoView.scrollView.contentInset = contentInsets
        infoView.scrollView.scrollIndicatorInsets = contentInsets
    }

    private func findActiveTextField() -> UITextField? {
        for case let textField as UITextField in infoView.contentView.subviews where textField.isFirstResponder {
            return textField
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configPickerView()
        infoView.saveButton.addTarget(self, action: #selector(completeBtn), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // gesture의 이벤트가 끝나도 뒤에 이벤트를 View로 전달
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setHeaderTitleName(title: "기본 프로필 설정")
        setUI()
    }

    @objc func completeBtn() {
        infoView.regionTextField.isError = false
        infoView.birthTextField.isError = false
        infoView.educationTextField.isError = false
        infoView.heightTextField.isError = false
        guard let body = infoView.selectedBodyButton?.title(for: .normal) else { return }
        guard let drinking = infoView.selectedDrinkButton?.title(for: .normal) else { return }
        guard let smoking = infoView.selectedSmokeButton?.title(for: .normal) else { return }
        guard let location = infoView.regionTextField.tf.text, !location.isEmpty else {
            infoView.regionTextField.isError = true
            return
        }
        guard let birthText = infoView.birthTextField.tf.text, let birthDate = dateFormatter.date(from: birthText) else {
            infoView.birthTextField.isError = true
            return
        }
        guard let education = infoView.educationTextField.tf.text, !education.isEmpty else {
            infoView.educationTextField.isError = true
            return
        }
        guard let height = infoView.heightTextField.tf.text, !height.isEmpty else {
            infoView.heightTextField.isError = true
            return
        }

        guard let nickName = newUserNickName else { return }
        guard let newUserEmail = newUserEmail, let newUserPassword = newUserPassword else { return }

        var smokeCheck = false
        if smoking == "흡연" {
            smokeCheck = true
        } else {
            smokeCheck = false
        }
        let profileSettingViewController = ProfileSettingViewController(allowAlbum: false)
        profileSettingViewController.user = UserInfo(
            uid: "", sex: "", birth: birthDate, // 필요한 경"우 성별을 여기에 추가
            nickName: nickName,
            location: location,
            height: Int(height) ?? 0,
            body: body,
            education: education,
            drinking: drinking,
            smoking: smokeCheck,
            register: Date(),
            score: 0,
            pick: []
        )
        profileSettingViewController.newUserEmail = newUserEmail
        profileSettingViewController.newUserPassword = newUserPassword
        navigationController?.pushViewController(profileSettingViewController, animated: true)
    }

    @objc func pickerDoneButtonTapped() {
        infoView.regionTextField.tf.resignFirstResponder()
    }

    @objc func educationPickerDoneButtonTapped() {
        infoView.educationTextField.tf.resignFirstResponder()
    }

    @objc func birthPickerDoneButtonTapped() {
        infoView.birthTextField.tf.resignFirstResponder()
    }

    @objc func dateChange(_ sender: UIDatePicker) {
        // 값이 변하면 UIDatePicker에서 날자를 받아와 형식을 변형해서 textField에 넣어줍니다.
        infoView.birthTextField.tf.text = dateFormat(date: sender.date)
    }

    func setUI() {
        infoView.regionTextField.initTextFieldText(placeHolder: "지역을 선택해주세요", delegate: self)
        infoView.regionTextField.lblTitle.text = "지역"
        infoView.regionTextField.lblError.text = "지역을 선택해주세요"
//        infoView.regionTextField.tf.keyboardType = .emailAddress
//        infoView.regionTextField.tf.returnKeyType = .next

        infoView.birthTextField.initTextFieldText(placeHolder: "생년월일을 선택해주세요", delegate: self)
        infoView.birthTextField.lblTitle.text = "생일"
        infoView.birthTextField.lblError.text = "생년월일을 선택해주세요"
//        infoView.birthTextField.tf.keyboardType = .emailAddress
//        infoView.birthTextField.tf.returnKeyType = .next

        infoView.educationTextField.initTextFieldText(placeHolder: "학력을 선택해주세요", delegate: self)
        infoView.educationTextField.lblTitle.text = "학력"
        infoView.educationTextField.lblError.text = "학력을 선택해주세요"
//        infoView.educationTextField.tf.keyboardType = .emailAddress
//        infoView.educationTextField.tf.returnKeyType = .next

        infoView.heightTextField.initTextFieldText(placeHolder: "키를 선택해주세요", delegate: self)
        infoView.heightTextField.lblTitle.text = "키"
        infoView.heightTextField.lblError.text = "키를 선택해주세요"
//        infoView.heightTextField.tf.keyboardType = .emailAddress
//        infoView.heightTextField.tf.returnKeyType = .next
    }
}

// struct InfoViewControllerPreView: PreviewProvider {
//    static var previews: some View {
//        InfoViewController.toPreview().edgesIgnoringSafeArea(.all)
//    }
// }

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // delegate, datasource 연결 및 picker를 textfied의 inputview로 설정한다
    func configPickerView() {
        pickerRegion.delegate = self
        pickerRegion.dataSource = self

        pickerEducation.delegate = self
        pickerEducation.dataSource = self
        infoView.educationTextField.tf.inputView = pickerEducation
        infoView.regionTextField.tf.inputView = pickerRegion
        // Add a toolbar with a custom button title
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .clear
        let customButtonTitle = "완료" // 원하는 버튼 이름으로 변경하세요
        let doneButton = UIBarButtonItem(title: customButtonTitle, style: .plain, target: self, action: #selector(pickerDoneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)

        let educationToolbar = UIToolbar()
        educationToolbar.sizeToFit()
        educationToolbar.backgroundColor = .clear
        let educationDoneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(educationPickerDoneButtonTapped))
        let educationSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        educationToolbar.setItems([educationSpace, educationDoneButton], animated: false)

        let birthToolbar = UIToolbar()
        birthToolbar.sizeToFit()
        birthToolbar.backgroundColor = .clear
        let birthDoneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(birthPickerDoneButtonTapped))
        let birthSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        birthToolbar.setItems([birthSpace, birthDoneButton], animated: false)

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
        infoView.educationTextField.tf.inputAccessoryView = educationToolbar
        infoView.birthTextField.tf.inputAccessoryView = birthToolbar
        infoView.birthTextField.tf.inputView = datePicker
        // textField에 오늘 날짜로 표시되게 설정
        infoView.birthTextField.tf.text = dateFormat(date: Date())
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
        if pickerView == pickerEducation {
            num = education.count
        }
        return num
    }

    // pickerview 내 선택지의 값들을 원하는 데이터로 채워준다.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var num = 0
        if pickerView == pickerRegion {
            return region[row]
        }
        if pickerView == pickerEducation {
            return education[row]
        }
        return nil
    }

    // textfield의 텍스트에 pickerview에서 선택한 값을 넣어준다.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerRegion {
            infoView.regionTextField.tf.text = region[row]
        }
        if pickerView == pickerEducation {
            infoView.educationTextField.tf.text = education[row]
        }
    }
}

extension InfoViewController: CustomTextFieldDelegate {
    func customTextFieldValueChanged(_ textfield: UITextField) {}

    func customTextFieldDidEndEditing(_ textField: UITextField) {}

    func customTextFieldDidBeginEditing(_ textField: UITextField) {}

    func errorStatus(isError: Bool, view: CustomTextField) {}
}
