//
//  CustomTextField.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/31.
//

import UIKit

protocol CustomTextFieldDelegate : AnyObject {
    
    /// textfield should return
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool
    
    /// textfield의 값이 바뀔때
    func customTextFieldValueChanged(_ textfield: UITextField)
    
    /// textfield의 값입력 후
    func customTextFieldDidEndEditing(_ textField: UITextField)
    
    /// textfield의 입력 시작
    func customTextFieldDidBeginEditing(_ textField: UITextField)
    
    /// textfield의 입력 허용 validationCheck
    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    
    /// 에러인 상황
    func errorStatus(isError: Bool, view: CustomTextField)
}

extension CustomTextFieldDelegate {
    /// textfield should return
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool {return true}
    /// textfield의 입력 허용 validationCheck
    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {return true}
}

class CustomTextField: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tf: UITextField!
    
    @IBOutlet weak var vLine: UIView!
    
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet var vContainer: UIView!

    @IBOutlet weak var btnSeePassword: UIButton!
    
    weak var tfDelegate : CustomTextFieldDelegate?
            
    /// 에러상태변환 체크
    var isError : Bool = false {
        didSet {
            if isError {
                lblError.isHidden = false
            } else {
                if tf.isFirstResponder {
                    lblError.isHidden = true
                } else {
                    lblError.isHidden = true
                }
            }
            tfDelegate?.errorStatus(isError: isError, view: self)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayout()
    }
    
    func initTextFieldText(placeHolder : String, delegate: CustomTextFieldDelegate) {
        tf.placeholder = placeHolder
        tfDelegate = delegate
    }
    private func initLayout() {
        Bundle.main.loadNibNamed("CustomTextField", owner: self, options: nil)
        vContainer.layer.frame = self.bounds
        self.addSubview(vContainer)
        
        self.tf.addTarget(self, action: #selector(textfieldValueChanged(_:)), for: .editingChanged)
        lblError.isHidden = true
        btnSeePassword.isHidden = true
    }
    
    func textfieldEditing(isEditing : Bool)  {
        if isEditing {
            
        } else {
            
        }
    }
    
    func textFieldIsPW(isPW: Bool) {
        btnSeePassword.isHidden = !isPW
        if isPW {
            tf.isSecureTextEntry = true
        }
    }
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
        tfDelegate?.customTextFieldValueChanged(textField)
    }
    
    @IBAction func seePWButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        tf.isSecureTextEntry = !sender.isSelected
    }
}
extension CustomTextField : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tfDelegate?.customTextFieldDidBeginEditing(textField)
        isError = false
        textfieldEditing(isEditing: true)

        if textField.text?.isEmpty ?? true {

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textfieldEditing(isEditing: false)
        if textField.text?.isEmpty ?? true {

        }
        tfDelegate?.customTextFieldDidEndEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return tfDelegate?.customTextFieldShouldReturn(self.tf) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return tfDelegate?.customTextField(self.tf, shouldChangeCharactersIn: range, replacementString: string) ?? true
//        guard let text = textField.text else {return false}
//        let maxLength = 20
//               // 최대 글자수 이상을 입력한 이후에는 중간에 다른 글자를 추가할 수 없게끔 작동(25자리)
//               if text.count >= maxLength && range.length == 0 && range.location >= maxLength {
//                   return false
//               }
//
//               return true
    }
}
