//
//  AskViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import SnapKit
import UIKit

class AskViewController: BaseHeaderViewController {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
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
        tv.delegate = self
        return tv
    }()

    private lazy var askDetailView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.borderWidth = 2
        vw.layer.borderColor = ThemeColor.primary.cgColor
        vw.backgroundColor = .white
        view.addSubview(vw)
        return vw
    }()

    private lazy var askButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("문의하기", for: .normal)
        btn.layer.cornerRadius = AppConstraint.defaultCornerRadius
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = ThemeFont.demibold(size: 25)
        btn.backgroundColor = ThemeColor.primary
        btn.addTarget(self, action: #selector(pressAskButton), for: .touchUpInside)
        view.addSubview(btn)
        return btn
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var tempView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
       let label = UILabel()
        label.text = "연락처 문의: jiwook.han.dev@gmail.com"
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = ThemeFont.regular(size: 17)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.backGroundColor
        setHeaderTitleName(title: "1:1 문의")
        configure()
        setKeyboardObserver()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    deinit {
        CommonUtil.print(output: "deinit - AskVC")
    }
}

extension AskViewController {
    override func keyboardWillShow(notification: NSNotification) {
        tempView.snp.remakeConstraints {
            $0.top.equalTo(askButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        tempView.snp.remakeConstraints {
            $0.top.equalTo(askButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension AskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let textViewFrame = askDetailTextView.convert(askDetailTextView.bounds, to: scrollView)
        let visibleContentHeight = scrollView.frame.height - 300
        if textViewFrame.maxY > visibleContentHeight {
            let scrollOffset = textViewFrame.maxY - visibleContentHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        }
    }
}

private extension AskViewController {
    func configure() {
        textFieldView.addSubview(askTextField)
        askDetailView.addSubview(askDetailTextView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        askTextField.snp.makeConstraints {
            $0.edges.equalTo(textFieldView).inset(16)
        }
        
        askDetailTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        [askTitleLabel, textFieldView, askDetailLabel,
         askDetailView, infoLabel, askButton, tempView].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(AppConstraint.headerViewHeight)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        askTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        textFieldView.snp.makeConstraints {
            $0.top.equalTo(askTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        askDetailLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        askDetailView.snp.makeConstraints {
            $0.top.equalTo(askDetailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.height.equalTo(300)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(askDetailView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        askButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.height.equalTo(50)
        }
        
        tempView.snp.makeConstraints {
            $0.top.equalTo(askButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

private extension AskViewController {
    @objc func pressAskButton() {
        guard let title = askTextField.text,
              let descriptions = askDetailTextView.text else { return }
        if title.isEmpty || descriptions.isEmpty {
            showAlert(title: "문의사항 미입력", message: "문의할 내용을 입력해 주세요.")
            return
        }
        sendAsk(title: title, descriptions: descriptions)
        completeAlert()
    }
    
    func sendAsk(title: String, descriptions: String) {
        Task {
            let error = await FireStoreManager.shared.setAsk(title: title, descriptions: descriptions)
            if let error {
                CommonUtil.print(output: error)
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
            title: "접수 완료",
            message: "문의가 접수되었습니다.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "확인",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                navigationPopToRootViewController(animated: true, completion: nil)
            }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
