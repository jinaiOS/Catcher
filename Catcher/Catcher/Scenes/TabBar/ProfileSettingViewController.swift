//
//  ViewController.swift
//  Catcher
//
//  Created by t2023-m0077 on 10/27/23.
//

import UIKit

class ProfileSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user: UserInfo?
    var newUserEmail: String?
    var newUserPassword: String?
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    // 회원가입 완료 버튼
    @IBAction func completeBtn(_ sender: UIButton) {
        guard let user = user else { return }
        guard let newUserEmail = newUserEmail, let newUserPassword = newUserPassword else { return }
        print(user)
        let firebaseManager = FirebaseManager()

        firebaseManager.createUsers(email: newUserEmail, password: newUserPassword) { error in
            if let error = error {
                print("Error creating user: \(error)")
            } else {
                guard let uid = firebaseManager.getUID else {
                    print("Error: No UID available")
                    return
                }
                let userInfo = UserInfo(
                    uid: uid,
                    sex: "",
                    nickName: user.nickName,
                    location: user.location,
                    height: Int(user.height),
                    body: user.body,
                    education: user.education,
                    drinking: user.drinking,
                    smoking: user.smoking,
                    register: Date(),
                    score: 0,
                    pick: []
                )
                FireStoreManager.shared.saveUserInfoToFirestore(userInfo: userInfo) { error in
                    if let error = error {
                        print("Error saving user info: \(error.localizedDescription)")
                    } else {
                        print("User info saved to Firestore successfully.")
                    }
                }
            }
        }

        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
