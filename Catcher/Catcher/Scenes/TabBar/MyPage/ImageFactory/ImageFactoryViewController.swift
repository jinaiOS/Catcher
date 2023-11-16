//
//  ImageFactoryViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import AVFoundation
import Photos
import SnapKit
import UIKit

/**
@class ImageFactoryViewController.swift

@brief BaseHeaderViewController를 상속받은 ViewController

@detail 네비게이션 Header가 있는 BaseHeaderViewController
*/
final class ImageFactoryViewController: BaseHeaderViewController {
    private let imageFactoryView = ImageFactoryView()
    private let viewModel = ImageFactoryViewModel()
    private let picker = UIImagePickerController()
    
    override func loadView() {
        super.loadView()
        view = imageFactoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        configure()
        setTarget()
    }
    
    deinit {
        CommonUtil.print(output: "deinit - ImageFactoryVC")
    }
}

private extension ImageFactoryViewController {
    func setLayout() {
        view.addSubview(imageFactoryView.indicatorView)
        
        imageFactoryView.indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        imageFactoryView.imageView.addGestureRecognizer(tapGesture)
        imageFactoryView.imageView.isUserInteractionEnabled = true
        imageFactoryView.saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
    }
    
    func configure() {
        setHeaderTitleName(title: "캐리커처 생성")
        picker.delegate = self
    }
    
    /** @brief 특정 iPhone에서는 사진 변환 불가하다는 이벤트*/
    @objc func tapImageView() {
        if let problem: Bool = UserDefaultsManager().getValue(forKey: UserDefaultsManager.keyName.problem.key) {
            if problem {
                showAlert(title: "캐리커처 생성 불가", message: "현재 해당 기기에서 캐리커처 이미지를 생성할 수 없습니다.")
                return
            }
            showAction()
        }
    }
    
    /** @brief 이미지 변환*/
    @objc func saveImage() {
        guard let image = viewModel.image else {
            showAlert(title: "이미지 없음", message: "캐리커처로 변환할 이미지를 선택해 주세요.")
            return
        }
        let resizedImage = image.resizeTo(to: CGSize(width: 1024, height: 1024))
        UIImageWriteToSavedPhotosAlbum(resizedImage, self, #selector(savedIamge), nil)
    }
    
    /** @brief 이미지 저장*/
    @objc func savedIamge(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            CommonUtil.print(output: error)
            return
        }
        showAlert(title: "사진이 저장되었습니다.", message: "")
    }
}

private extension ImageFactoryViewController {
    
    /** @brief 사진 접근방법 선택 이벤트*/
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
    
    /** @brief 카메라 접근 이벤트*/
    func openCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if status {
                    self.picker.sourceType = .camera
                    self.picker.cameraFlashMode = .off
                    if UIImagePickerController.isCameraDeviceAvailable(.front) {
                        self.picker.cameraDevice = .front
                        self.present(self.picker, animated: true)
                    } else {
                        CommonUtil.print(output: "전면 카메라를 찾을 수 없음")
                        return
                    }
                } else {
                    CommonUtil.print(output: "Camera: 권한 거부")
                    self.moveToSettingAlert(reason: "카메라 접근 요청 거부됨", discription: "설정 > 카메라 접근 권한을 허용해 주세요.")
                }
            }
        }
    }
    
    /** @brief 갤러리 접근 이벤트*/
    func openLibrary() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.picker.sourceType = .photoLibrary
                    self.present(self.picker, animated: true)
                    
                default:
                    self.moveToSettingAlert(reason: "사진 접근 요청 거부됨", discription: "설정 > 사진 접근 권한을 허용해 주세요.")
                }
            }
        }
    }
    
    /** @brief 권한 설정 페이지로 이동하는 이벤트*/
    func moveToSettingAlert(reason: String, discription: String) {
        let alert = UIAlertController(title: reason, message: discription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        cancle.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    /** @brief 확인 Alert*/
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    /** @brief Indicator*/
    func processIndicatorView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            imageFactoryView.indicatorView.isHidden.toggle()
            if imageFactoryView.indicator.isAnimating {
                imageFactoryView.indicator.stopAnimating()
            } else {
                imageFactoryView.indicator.startAnimating()
            }
        }
    }
}

extension ImageFactoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /** @brief 이미지 저장*/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageFactoryView.imageView.image = image
            viewModel.image = image
            processIndicatorView()
        }
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let resultImage = viewModel.imageTasking()
            imageFactoryView.imageView.image = resultImage
            processIndicatorView()
        }
    }
    /** @brief 취소*/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
