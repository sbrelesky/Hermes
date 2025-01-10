//
//  EditInfoController.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation
import UIKit
import SnapKit

class EditInfoController: UIViewController, TextFieldValidation {
    
    let cardView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .white
        v.layer.cornerRadius = 40
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.masksToBounds = true
        
        return v
    }()
    
    let firstNameTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Name")
        
        return tf
    }()
    
    
    let phoneTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Phone")
        tf.keyboardType = .phonePad
        
        return tf
    }()
    

    lazy var saveButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Save", for: .normal)
        b.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)
        
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation setup
        title = "Edit Info"
        
        // View setup
        view.backgroundColor = UIColor(hex: "#F0F0F0")
        
        setupForKeyboard()
        setupViews()
        
        guard let user = UserManager.shared.currentUser else { return }
        firstNameTextField.text = user.name
        phoneTextField.text = user.phone
    }
    
    private func setupViews() {
        view.addSubview(cardView)
        
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
      
        
        cardView.addSubview(firstNameTextField)
        cardView.addSubview(phoneTextField)
        cardView.addSubview(saveButton)
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
      
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(firstNameTextField)
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-40)
            make.top.greaterThanOrEqualTo(phoneTextField.snp.bottom).offset(40)
        }
    }
    
    @objc func saveAccount() {
        guard validateNonNilEmptyString(firstNameTextField.text) else {
            firstNameTextField.showError()
            return
        }
        
        guard validateNonNilEmptyString(phoneTextField.text) else {
            phoneTextField.showError()
            return
        }
        
        guard let user = UserManager.shared.currentUser else { return }
        let name = firstNameTextField.text ?? user.name
        let phone = phoneTextField.text ?? user.phone
        
        saveButton.setLoading(true)
        
        UserManager.shared.update(name: name, phone: phone) { error in
            self.saveButton.setLoading(false)

            if let error = error {
                self.presentError(error: error)
            } else {
                print("Save successful")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


// MARK: - TextField Delegate Methods

extension EditInfoController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            phoneTextField.becomeFirstResponder()
        }
        
        return true
    }
}

