//
//  ViewController.swift
//  Catcher
//
//  Created by t2023-m0077 on 10/27/23.
//

import UIKit
import SnapKit
import AVFoundation

class ProfileSettingViewController: BaseHeaderViewController {
    var user: UserInfo?
    var newUserEmail: String?
    var newUserPassword: String?
    private let picker = UIImagePickerController()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    private let viewModel = ProfileSettingViewModel()
    private let indicator = UIActivityIndicatorView()
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        configure()
    }

    // 회원가입 완료 버튼
    @IBAction func completeBtn(_ sender: UIButton) {
        guard let user = user,
              let newUserEmail = newUserEmail,
              let newUserPassword = newUserPassword else { return }
        CommonUtil.print(output: user)
        
        processIndicatorView()
        viewModel.createUser(user: user,
                             eamil: newUserEmail,
                             password: newUserPassword) { result in
            self.processIndicatorView()
            if result {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @objc func imageTapped() {
        openCamera()
    }
    
    deinit {
        CommonUtil.print(output: "deinit - ProfileSettingVC")
    }
}

private extension ProfileSettingViewController {
    func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        picker.delegate = self
        picker.isEditing = true
        
        imageView.contentMode = .scaleAspectFill
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        indicator.style = .large
        indicator.color = .systemOrange
        indicatorView.isHidden = true
        
        registerButton.backgroundColor = ThemeColor.primary
        registerButton.tintColor = .white
        registerButton.cornerRadius = AppConstraint.defaultCornerRadius
    }
    
    func setLayout() {
        indicatorView.addSubview(indicator)
        
        view.addSubview(indicatorView)
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func openCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
            guard let self = self else { return }
            if status {
                print("Camera: 권한 허용")
                DispatchQueue.main.async {
                    self.picker.sourceType = .camera
                    self.picker.cameraFlashMode = .off
                    if UIImagePickerController.isCameraDeviceAvailable(.front) {
                        self.picker.cameraDevice = .front
                        self.present(self.picker, animated: true)
                    } else {
                        print("전면 카메라를 찾을 수 없음")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("Camera: 권한 거부")
                    self.moveToSettingAlert()
                }
            }
        }
    }
    
    func moveToSettingAlert() {
        let alert = UIAlertController(title: "카메라 접근 요청 거부됨",
                                      message: "설정 > 카메라 접근 권한을 허용해 주세요.",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            // 설정으로 이동
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        //        cancle.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func retakeAlert() {
        let alert = UIAlertController(title: "얼굴이 잘 안보여요 ㅠㅠ",
                                      message: "사진을 다시 찍어주세요", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func processIndicatorView() {
        indicatorView.isHidden.toggle()
        if indicator.isAnimating {
            indicator.stopAnimating()
        } else {
            indicator.startAnimating()
        }
    }
}

extension ProfileSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processIndicatorView()
        }
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self,
                  let image = imageView.image else { return }
            let result = viewModel.imageTasking(image: image)
            guard let image = result.image,
                  let gender = result.gender else {
                processIndicatorView()
                retakeAlert()
                return
            }
            processIndicatorView()
            viewModel.profileImage = image
            viewModel.gender = gender
            imageView.image = image
            genderLabel.text = gender
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
