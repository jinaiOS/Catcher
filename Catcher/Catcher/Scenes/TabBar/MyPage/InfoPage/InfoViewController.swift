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
final class InfoViewController: UIViewController {
    var newUserEmail: String?
    var newUserPassword: String?
    var newUserNickName: String?
    private let infoView = InfoView()
    let picker = UIPickerView()
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
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        configure(title: title)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view = infoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configPickerView()
        infoView.saveButton.addTarget(self, action: #selector(completeBtn), for: .touchUpInside)
    }

    @objc func completeBtn() {
        guard let body = infoView.selectedBodyButton?.title(for: .normal) else { return }
        guard let drinking = infoView.selectedDrinkButton?.title(for: .normal) else { return }
        guard let smoking = infoView.selectedSmokeButton?.title(for: .normal) else { return }
        guard let education = infoView.educationTextField.text else { return }
        guard let height = infoView.heightTextField.text else { return }
        guard let location = infoView.regionTextField.text else { return }
        guard let nickName = newUserNickName else { return }
        guard let newUserEmail = newUserEmail, let newUserPassword = newUserPassword else { return }
        var smokeCheck = false
        if smoking == "흡연" {
            smokeCheck = true
        } else {
            smokeCheck = false
        }
        let profileSettingViewController = ProfileSettingViewController(nibName: "ProfileSettingViewController", bundle: nil)
        profileSettingViewController.user = UserInfo(
            uid: "", sex: "", // 필요한 경"우 성별을 여기에 추가
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
        infoView.regionTextField.resignFirstResponder()
    }
}

private extension InfoViewController {
    func configure(title: String) {
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString.makeNavigationTitle(title: title)
        navigationItem.titleView = titleLabel
    }
}

struct InfoViewControllerPreView: PreviewProvider {
    static var previews: some View {
        InfoViewController(title: "기본 프로필").toPreview().edgesIgnoringSafeArea(.all)
    }
}

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // delegate, datasource 연결 및 picker를 textfied의 inputview로 설정한다
    func configPickerView() {
        picker.delegate = self
        picker.dataSource = self
        infoView.regionTextField.inputView = picker
        // Add a toolbar with a custom button title
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .clear
        let customButtonTitle = "완료" // 원하는 버튼 이름으로 변경하세요
        let doneButton = UIBarButtonItem(title: customButtonTitle, style: .plain, target: self, action: #selector(pickerDoneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        infoView.regionTextField.inputAccessoryView = toolbar
    }

    // pickerview는 하나만
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // pickerview의 선택지는 데이터의 개수만큼
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return region.count
    }

    // pickerview 내 선택지의 값들을 원하는 데이터로 채워준다.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return region[row]
    }

    // textfield의 텍스트에 pickerview에서 선택한 값을 넣어준다.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        infoView.regionTextField.text = region[row]
    }
}
