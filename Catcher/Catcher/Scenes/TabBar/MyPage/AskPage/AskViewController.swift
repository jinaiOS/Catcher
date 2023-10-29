//
//  AskViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import SnapKit
import UIKit

class AskViewController: BaseHeaderViewController {
    private lazy var askTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "제목"
        lb.textAlignment = .left
        lb.font = .systemFont(ofSize: 14, weight: .light)
        view.addSubview(lb)
        return lb
    }()

    private lazy var askTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "제목을 입력하세요"
        tf.font = .systemFont(ofSize: 14, weight: .light)
        return tf
    }()

    private lazy var textFieldView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = ThemeColor.primary.cgColor
        vw.backgroundColor = .white
        vw.addSubview(askTextField)
        view.addSubview(vw)
        return vw
    }()

    private lazy var askDetailLabel: UILabel = {
        let lb = UILabel()
        lb.text = "문의내용"
        lb.textAlignment = .left
        lb.font = .systemFont(ofSize: 14, weight: .light)
        view.addSubview(lb)
        return lb
    }()

    private lazy var askDetailTextView: UITextView = {
        let tv = UITextView()

        tv.font = .systemFont(ofSize: 14, weight: .light)
        return tv
    }()

    private lazy var askDetailView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = ThemeColor.primary.cgColor
        vw.backgroundColor = .white
        vw.addSubview(askDetailTextView)
        view.addSubview(vw)
        return vw
    }()

    private lazy var askButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("문의하기", for: .normal)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = ThemeColor.primary
        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setHeaderTitleName(title: "1:1 문의")
        configure()
    }
}

extension AskViewController {
    func configure() {
        askTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(80)
            make.leading.equalTo(self.view).inset(36)
            make.height.equalTo(18)
        }
        askTextField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.textFieldView).inset(13)
            make.top.bottom.equalTo(self.textFieldView).inset(10)
        }
        textFieldView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(20)
            make.top.equalTo(askTitleLabel.snp.bottom).inset(-10)
            make.height.equalTo(38)
        }
        askDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).inset(-26)
            make.leading.equalTo(self.view).inset(36)
            make.height.equalTo(18)
        }
        askDetailTextView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.askDetailView).inset(16)
        }
        askDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(20)
            make.top.equalTo(askDetailLabel.snp.bottom).inset(-10)
            make.height.equalTo(262)
        }
        askButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(53)
        }
    }
}
