//
//  ReportViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import UIKit
import SnapKit
class ReportViewController: BaseHeaderViewController {
    var button1: UIButton!
    var button2: UIButton!
    var button3: UIButton!
    var button4: UIButton!
    var userBlockButton: UIButton!
    lazy var label1: UILabel = {
        let lb = UILabel()
        lb.text = "신고사유"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    lazy var label2: UILabel = {
        let lb = UILabel()
        lb.text = "신고사유"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    lazy var label3: UILabel = {
        let lb = UILabel()
        lb.text = "신고사유"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    lazy var label4: UILabel = {
        let lb = UILabel()
        lb.text = "신고사유"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    lazy var userBlockLabel: UILabel = {
        let lb = UILabel()
        lb.text = "해당 사용자 다시 보지 않기"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    lazy var userBlockStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [userBlockButton, userBlockLabel])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10
        view.addSubview(st)
        return st
    }()

    lazy var stack1: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button1, label1])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    lazy var stack2: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button2, label2])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    lazy var stack3: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button3, label3])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    lazy var stack4: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button4, label4])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    private lazy var reportView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = ThemeColor.primary.cgColor
        vw.backgroundColor = .white
        [stack1, stack2, stack3, stack4].forEach { vw.addSubview($0) }
        view.addSubview(vw)
        return vw
    }()

    private lazy var reportDetailLabel: UILabel = {
        let lb = UILabel()
        lb.text = "신고 내용"
        lb.textAlignment = .left
        lb.font = .systemFont(ofSize: 14, weight: .light)
        view.addSubview(lb)
        return lb
    }()

    private lazy var reportDetailTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14, weight: .light)
        return tv
    }()

    private lazy var reportDetailView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = ThemeColor.primary.cgColor
        vw.backgroundColor = .white
        vw.addSubview(reportDetailTextView)
        view.addSubview(vw)
        return vw
    }()

    private lazy var reportButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("신고하기", for: .normal)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = ThemeColor.primary
        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderTitleName(title: "사용자 신고")
        view.backgroundColor = .white
        configure()
    }

    @objc func buttonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? .systemRed : .systemGray
    }
}

extension ReportViewController {
    func createButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.tintColor = .systemGray
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    func configure() {
        button1 = createButton()
        button2 = createButton()
        button3 = createButton()
        button4 = createButton()
        userBlockButton = createButton()
        stack1.snp.makeConstraints { make in
            make.leading.equalTo(reportView.snp.leading).inset(23)
            make.top.equalTo(reportView.snp.top).inset(10)
            make.height.equalTo(24)
        }
        label1.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(21)
        }

        stack2.snp.makeConstraints { make in
            make.trailing.equalTo(reportView.snp.trailing).inset(23)
            make.top.equalTo(reportView.snp.top).inset(10)
            make.height.equalTo(24)
        }
        label2.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(21)
        }

        stack3.snp.makeConstraints { make in
            make.leading.equalTo(reportView.snp.leading).inset(23)
            make.top.equalTo(stack1.snp.top).inset(23)
            make.height.equalTo(24)
        }
        label3.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(21)
        }

        stack4.snp.makeConstraints { make in
            make.trailing.equalTo(reportView.snp.trailing).inset(23)
            make.top.equalTo(stack2.snp.top).inset(23)
            make.height.equalTo(24)
        }
        label4.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(21)
        }

        reportView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(80)
            make.bottom.equalTo(label4.snp.bottom).inset(-10)
        }

        reportDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(reportView.snp.bottom).inset(-26)
            make.leading.equalTo(self.view).inset(36)
            make.height.equalTo(18)
        }
        reportDetailTextView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.reportDetailView).inset(16)
        }
        reportDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(20)
            make.top.equalTo(reportDetailLabel.snp.bottom).inset(-10)
            make.height.equalTo(262)
        }
        reportButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(53)
        }
        userBlockStack.snp.makeConstraints { make in
            make.top.equalTo(reportDetailView.snp.bottom).inset(-20)
            make.leading.equalTo(reportDetailLabel.snp.leading)
        }
    }
}

