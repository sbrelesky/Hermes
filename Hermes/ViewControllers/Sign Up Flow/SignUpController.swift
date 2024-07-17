//
//  SignUpController.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAuth
import FirebaseAnalytics

class SignUpController: UIViewController, TextFieldValidation {
    
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
    
    let emailTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Email")
        tf.keyboardType = .emailAddress
        
        return tf
    }()
    
    
    let phoneTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Phone")
        tf.keyboardType = .phonePad
        
        return tf
    }()
    
    let passwordTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Password")
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    
    let confirmPasswordTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Confirm Password")
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    lazy var createAccountButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Create Account", for: .normal)
        b.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        
        return b
    }()
    
    
    let errorMessageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.primary
        l.numberOfLines = 0
        l.text = ""
        l.textAlignment = .center
        
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation setup
        title = "Create Account"
        
        // View setup
        view.backgroundColor = UIColor(hex: "#F0F0F0")
        
        setupForKeyboard()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(cardView)
        
        firstNameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        cardView.addSubview(firstNameTextField)
        cardView.addSubview(emailTextField)
        cardView.addSubview(phoneTextField)
        cardView.addSubview(passwordTextField)
        cardView.addSubview(confirmPasswordTextField)
        cardView.addSubview(createAccountButton)
        cardView.addSubview(errorMessageLabel)
        
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
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(firstNameTextField)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(firstNameTextField)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(firstNameTextField)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(firstNameTextField)
        }
        
        createAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-Constants.Padding.Vertical.textFieldSpacing)
            make.top.greaterThanOrEqualTo(confirmPasswordTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
        }
        
        errorMessageLabel.snp.makeConstraints { make in
            make.bottom.equalTo(createAccountButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(firstNameTextField)
        }
    }
    
    @objc func createAccount() {
        guard validateNonNilEmptyString(firstNameTextField.text) else {
            firstNameTextField.showError()
            return
        }
        
        guard validateNonNilEmptyString(emailTextField.text) else {
            emailTextField.showError()
            return
        }
        
        guard validateNonNilEmptyString(phoneTextField.text) else {
            phoneTextField.showError()
            return
        }
        
        guard validateNonNilEmptyString(passwordTextField.text) else {
            passwordTextField.showError()
            return
        }
        
        guard validateNonNilEmptyString(confirmPasswordTextField.text) else {
            confirmPasswordTextField.showError()
            return
        }
        
        
        guard passwordTextField.text == confirmPasswordTextField.text else {
            passwordTextField.showError()
            confirmPasswordTextField.showError()
            errorMessageLabel.text = "Your passwords do not match"
            return
        }
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        createAccountButton.setLoading(true)
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(error)
            } else {
                // Successful Auth Creation
                self.handleAuthSuccess()
            }
        }
    }
    
    
    private func handleAuthSuccess() {
        
        guard let name = firstNameTextField.text,
              let phone = phoneTextField.text else {
            return
        }
        
        FirestoreManager.shared.createUser(firstName: name, phone: phone) { error in
            // Create firestore record
            if let error = error {
                self.showError(error)
            } else {
                HermesAnalytics.shared.logEvent(AnalyticsEventSignUp, parameters: ["name": name, "email": Auth.auth().currentUser?.email])
                self.handleDatabaseSuccess()
            }
        }
    }
    
    private func handleDatabaseSuccess() {
        // Successful create firebase record
        self.createAccountButton.setLoading(false)
        // Go to login screen
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func showError(_ error: Error) {
        self.errorMessageLabel.text = error.localizedDescription
        self.createAccountButton.setLoading(false)
    }
}


// MARK: - TextField Delegate Methods

extension SignUpController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        }
        
        return true
    }
}
