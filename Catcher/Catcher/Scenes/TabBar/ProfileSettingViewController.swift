//
//  ViewController.swift
//  Catcher
//
//  Created by t2023-m0077 on 10/27/23.
//

import AVFoundation
import Photos
import SnapKit
import UIKit

protocol ReloadProfileImage: AnyObject {
    func reloadProfile(profile: UIImage)
}

class ProfileSettingViewController: BaseHeaderViewController {
    private let viewModel = ProfileSettingViewModel()
    private let indicator = UIActivityIndicatorView()
    private let picker = UIImagePickerController()
    private let allowAlbum: Bool
    weak var delegate: ReloadProfileImage?
    var user: UserInfo?
    var newUserEmail: String?
    var newUserPassword: String?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderTitleName(title: "프로필 사진 설정")
        setLayout()
        configure()
    }

    // 회원가입 완료 버튼
    @IBAction func completeBtn(_ sender: UIButton) {
        switch allowAlbum {
        case true:
            updateProfile()
        case false:
            setUser()
        }
    }
    
    init(allowAlbum: Bool) {
        self.allowAlbum = allowAlbum
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CommonUtil.print(output: "deinit - ProfileSettingVC")
    }
}

private extension ProfileSettingViewController {
    func updateProfile() {
        if viewModel.profileImage == nil {
            showAlert(title: "프로필 사진 미등록", message: "프로필 사진을 등록해주세요.")
            return
        }
        self.processIndicatorView()
        
        viewModel.updateProfile { [weak self] image in
            guard let self = self else { return }
            self.processIndicatorView()
            if let image {
                delegate?.reloadProfile(profile: image)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func setUser() {
        guard let user = user,
              let newUserEmail = newUserEmail,
              let newUserPassword = newUserPassword else { return }
        if viewModel.profileImage == nil || viewModel.gender == nil {
            showAlert(title: "프로필 사진 미등록", message: "프로필 사진을 등록해주세요.")
            return
        }
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
        if allowAlbum {
            showAction()
        } else {
            openCamera()
        }
    }
}

private extension ProfileSettingViewController {
    func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        
        picker.delegate = self
        picker.isEditing = true
        
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        indicator.style = .large
        indicator.color = .systemOrange
        indicatorView.isHidden = true
        
        registerButton.backgroundColor = ThemeColor.primary
        registerButton.tintColor = .white
        registerButton.cornerRadius = AppConstraint.defaultCornerRadius
        
        let buttonTitle = allowAlbum ? "프로필 변경" : "회원가입"
        genderLabel.isHidden = allowAlbum
        registerButton.setTitle(buttonTitle, for: .normal)
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
}

private extension ProfileSettingViewController {
    func showAction() {
        let alert = UIAlertController(title: "사진 가져오기", message: nil, preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.openLibrary()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
            guard let self = self else { return }
            openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
                    self.moveToSettingAlert(reason: "카메라 접근 요청 거부됨", discription: "설정 > 카메라 접근 권한을 허용해 주세요.")
                }
            }
        }
    }
    
    private func openLibrary() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    print("Album: 권한 허용")
                    self.picker.sourceType = .photoLibrary
                    self.present(self.picker, animated: true)
                }
                
            default:
                DispatchQueue.main.async {
                    self.moveToSettingAlert(reason: "사진 접근 요청 거부됨", discription: "설정 > 사진 접근 권한을 허용해 주세요.")
                }
            }
        }
    }
    
    private func moveToSettingAlert(reason: String, discription: String) {
        let alert = UIAlertController(title: reason, message: discription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            // 설정으로 이동
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        // 색상 적용.
        cancle.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func processIndicatorView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            indicatorView.isHidden.toggle()
            if indicator.isAnimating {
                indicator.stopAnimating()
            } else {
                indicator.startAnimating()
            }
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
                showAlert(title: "얼굴이 잘 안보여요 ㅠㅠ", message: "사진을 다시 찍어주세요")
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
