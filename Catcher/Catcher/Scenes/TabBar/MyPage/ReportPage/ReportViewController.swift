//
//  ReportViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import SnapKit
import UIKit

final class ReportViewController: BaseHeaderViewController {
    private let fireStoreManager = FireStoreManager.shared
    private var userInfo: UserInfo?
    private var isPicked: Bool
    private var isBlocked: Bool
    private var button1: UIButton!
    private var button2: UIButton!
    private var button3: UIButton!
    private var button4: UIButton!
    private var userBlockButton: UIButton!

    init(userinfo: UserInfo?, isPicked: Bool, isBlocked: Bool) {
        self.userInfo = userinfo
        self.isPicked = isPicked
        self.isBlocked = isBlocked
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var scrollView: UIScrollView = {
        let vw = UIScrollView()
        vw.addSubview(contentView)
        view.addSubview(vw)
        return vw
    }()

    private lazy var contentView: UIView = {
        let cv = UIView()
        [reportView, reportDetailLabel, reportDetailView, reportButton, userBlockStack, tempView].forEach { cv.addSubview($0) }

        return cv
    }()

    private lazy var tempView: UIView = {
        let cv = UIView()
        return cv
    }()

    private lazy var label1: UILabel = {
        let lb = UILabel()
        lb.text = "비속어 / 폭언 음란 등"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var label2: UILabel = {
        let lb = UILabel()
        lb.text = "사진 도용"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var label3: UILabel = {
        let lb = UILabel()
        lb.text = "도배 및 광고 등"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var label4: UILabel = {
        let lb = UILabel()
        lb.text = "기타"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var userBlockLabel: UILabel = {
        let lb = UILabel()
        lb.text = "해당 사용자 다시 보지 않기"
        lb.font = .systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var userBlockStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [userBlockButton, userBlockLabel])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10
//        view.addSubview(st)
        return st
    }()

    private lazy var stack1: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button1, label1])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    private lazy var stack2: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button2, label2])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    private lazy var stack3: UIStackView = {
        let st = UIStackView(arrangedSubviews: [button3, label3])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = 10

        return st
    }()

    private lazy var stack4: UIStackView = {
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
//        view.addSubview(vw)
        return vw
    }()

    private lazy var reportDetailLabel: UILabel = {
        let lb = UILabel()
        lb.text = "신고 내용"
        lb.textAlignment = .left
        lb.font = .systemFont(ofSize: 14, weight: .light)
//        view.addSubview(lb)
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
//        view.addSubview(vw)
        return vw
    }()

    private lazy var reportButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("신고하기", for: .normal)
        btn.layer.cornerRadius = AppConstraint.defaultCornerRadius
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = ThemeColor.primary
        btn.addTarget(self, action: #selector(reportUser), for: .touchUpInside)
//        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderTitleName(title: "사용자 신고")

        view.backgroundColor = .white
        configure()
        setKeyboardObserver()
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }

    deinit {
        CommonUtil.print(output: "deinit - ReportVC")
    }

    override func backButtonTouched(sender: UIButton) {
        dismissVC()
    }
}

extension ReportViewController {
    override func keyboardWillShow(notification: NSNotification) {
        tempView.snp.remakeConstraints {
            $0.top.equalTo(reportButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
    }

    override func keyboardWillHide(notification: NSNotification) {
        tempView.snp.remakeConstraints {
            $0.top.equalTo(reportButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension ReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let textViewFrame = reportDetailTextView.convert(reportDetailTextView.bounds, to: scrollView)
        let visibleContentHeight = scrollView.frame.height - 300
        if textViewFrame.maxY > visibleContentHeight {
            let scrollOffset = textViewFrame.maxY - visibleContentHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        }
    }
}

private extension ReportViewController {
    @objc func buttonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? .systemRed : .systemGray
    }

    @objc func reportUser() {
        var title = ""
        if button1.isSelected {
            title += "/비속어"
        }
        if button2.isSelected {
            title += "/사진 도용"
        }
        if button3.isSelected {
            title += "/광고"
        }
        if button4.isSelected {
            title += "/기타"
        }
        if title.isEmpty || reportDetailTextView.text.isEmpty {
            showAlert(title: "신고사항 미입력", message: "신고 사유를 자세히 작성해 주세요.")
            return
        }
        sendReport(title: title, descriptions: reportDetailTextView.text)
        completeAlert()
    }

    func sendReport(title: String, descriptions: String) {
        Task {
            let error = await fireStoreManager.setReport(targetUID: userInfo?.uid, title: title, descriptions: descriptions)
            if let error {
                CommonUtil.print(output: error.localizedDescription)
            }
        }
    }

    func dismissVC() {
        navigationPopToRootViewController(animated: true) { [weak self] in
            guard let self = self,
                  let userInfo = userInfo else { return }
            let userInfoVC = UserInfoViewController(info: userInfo, isPicked: isPicked, isBlocked: isBlocked)
            userInfoVC.modalPresentationStyle = .custom
            userInfoVC.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(userInfoVC, animated: true)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "확인",
            style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func completeAlert() {
        let alert = UIAlertController(
            title: "신고 완료",
            message: "신고가 접수되었습니다.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "확인",
            style: .default)
        { [weak self] _ in
            guard let self = self else { return }
            dismissVC()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
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

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(AppConstraint.headerViewHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom) // Set the bottom constraint to the top of the next button.
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        stack1.snp.makeConstraints { make in
            make.leading.equalTo(reportView.snp.leading).inset(23)
            make.top.equalTo(reportView.snp.top).inset(10)
//            make.trailing.equalTo(stack2.snp.leading).inset(10)
            make.height.equalTo(24)
        }
        label1.snp.makeConstraints { make in
            make.width.equalTo(200)
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
            make.width.equalTo(200)
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
            make.leading.trailing.equalTo(contentView).inset(20)
            make.top.equalTo(contentView.snp.top)
            make.bottom.equalTo(label4.snp.bottom).inset(-10)
//            make.height.equalTo(50)
        }

        reportDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(reportView.snp.bottom).inset(-26)
            make.leading.equalTo(contentView).inset(36)
            make.height.equalTo(18)
        }
        reportDetailTextView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.reportDetailView).inset(16)
        }
        reportDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(20)
            make.top.equalTo(reportDetailLabel.snp.bottom).inset(-10)
            make.height.equalTo(262)
        }
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(userBlockStack.snp.bottom).inset(-20)
            make.leading.trailing.equalTo(contentView).inset(14)
            make.height.equalTo(50)
//            make.bottom.equalTo(contentView.snp.bottom).inset(20)
        }
        userBlockStack.snp.makeConstraints { make in
            make.top.equalTo(reportDetailView.snp.bottom).inset(-20)
            make.leading.equalTo(reportDetailLabel.snp.leading)
            make.height.equalTo(30)
        }
        tempView.snp.makeConstraints {
            $0.top.equalTo(reportButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottom)
        }
    }
}
