//
//  SurveyViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/24.
//

import UIKit

class SurveyViewController: UIViewController {
    private var button1: UIButton!
    private var button2: UIButton!
    private var button3: UIButton!
    private var button4: UIButton!
    private var button5: UIButton!
    private var selectedButton: UIButton? // 추가: 현재 선택된 버튼

    private lazy var questionLabel: UILabel = {
        let lb = UILabel()
        lb.text = "000님에 대한 첫인상"
        lb.font = .systemFont(ofSize: 14, weight: .heavy)
        view.addSubview(lb)
        return lb
    }()

    private lazy var mainView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = UIColor(red: 0.804, green: 0.706, blue: 0.859, alpha: 1).cgColor
        vw.addSubview(surveyStackView)
        vw.backgroundColor = .white
        view.addSubview(vw)
        return vw

    }()

    private lazy var surveyIcons: [UILabel] = {
        let iconTexts = ["😡", "😓", "😐", "😄", "😍"]
        return iconTexts.map { text in
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            return label
        }
    }()

    lazy var surveyStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [surveyIconsStackView, surveyLabelStackView, surveyButtonStackView])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .fillEqually
        st.spacing = 10

        return st
    }()

    lazy var surveyButtonStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button1, button2, button3, button4, button5])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .fillEqually
        st.spacing = 20
        return st
    }()

    lazy var surveyIconsStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: surveyIcons)
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .fillEqually
        st.spacing = 20
        return st
    }()

    private lazy var surveyLabel: [UILabel] = {
        let iconTexts = ["1점", "2점", "3점", "4점", "5점"]
        return iconTexts.map { text in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 13, weight: .light)
            label.textAlignment = .center
            return label
        }
    }()

    lazy var surveyLabelStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: surveyLabel)
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .fillEqually
        st.spacing = 20
        return st
    }()

    private lazy var completeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.749, green: 0.58, blue: 0.847, alpha: 1)
        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        configure()
    }

    @objc func buttonTapped(_ sender: UIButton) {
        if let selectedButton = selectedButton {
            // 이미 선택된 버튼이 있으면 선택을 해제하고 그림을 회색으로 변경
            selectedButton.isSelected = false
            selectedButton.tintColor = .systemGray
        }

        // 새로운 버튼을 선택하고 그림을 빨간색으로 변경
        sender.isSelected = true
        sender.tintColor = .systemRed

        selectedButton = sender // 선택된 버튼 업데이트
    }
}

extension SurveyViewController {
    func createButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.tintColor = .systemGray
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.setImage(UIImage(systemName: "circle.circle.fill"), for: .selected)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    func configure() {
        button1 = createButton()
        button2 = createButton()
        button3 = createButton()
        button4 = createButton()
        button5 = createButton()

        surveyStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self.mainView)
        }
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(16)
            make.height.equalTo(100)
            make.centerX.centerY.equalTo(self.view)
        }
        questionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(mainView.snp.top).inset(-20)
            make.centerX.equalTo(self.view)
        }
        completeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(53)
        }
    }
}
