//
//  LoginController.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAuth

class LoginController: UIViewController, TextFieldValidation {
    
    
    let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo"))
        iv.tintColor = ThemeManager.Color.text
        
        return iv
    }()
    
    let emailTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Email")
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        
        return tf
    }()
    
    let passwordTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Password")
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        
        return tf
    }()
        
    lazy var loginButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Login", for: .normal)
        b.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        
        return b
    }()
    
    lazy var signUpButton: UIButton = {
        let b = UIButton()
        b.setTitle("Don't have an account? Sign Up", for: .normal)
        b.titleLabel?.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        b.setTitleColor(ThemeManager.Color.text, for: .normal)
        b.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        
        return b
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = ThemeManager.Color.yellow
        navigationController?.navigationBar.titleTextAttributes = [
            .font: ThemeManager.Font.Style.main.font.withDynamicSize(29.0),
            .foregroundColor: ThemeManager.Color.text
        ]
        
        view.backgroundColor = .white
        
        setupForKeyboard()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Current User: ", Auth.auth().currentUser?.uid)
        //try? Auth.auth().signOut()
        
        if Auth.auth().currentUser != nil {
            handleLoginSuccess()
        }
    }
    
    private func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        view.addSubview(loginButton)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        guard let screenHeight = UIScreen.current?.bounds.height else { return }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(logoImageView.snp.width)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(screenHeight * 0.12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(emailTextField)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
            make.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Targets
    
    @objc func signUpPressed() {
        let vc = CheckZipController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loginPressed() {
        
        guard let email = emailTextField.text, validateNonNilEmptyString(email) else {
            emailTextField.showError()
            return
        }
        
        guard let password = passwordTextField.text, validateNonNilEmptyString(password) else {
            passwordTextField.showError()
            return
        }
        
        loginButton.setLoading(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.handleError(error)
            } else {
                self.handleLoginSuccess()
            }
        }
    }
    
    func fetchSettings(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchSettings { result in
            switch result {
            case .success(let settings):
                Settings.shared.update(with: settings)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleLoginSuccess() {
        
        let dispatchGroup = DispatchGroup()
        
        
        // Fetch Settings
        dispatchGroup.enter()
        fetchSettings { _ in
            dispatchGroup.leave()
        }
        
        
        // Fetch user
        dispatchGroup.enter()
        UserManager.shared.fetch { error in
            if let error = error {
                self.handleError(error)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.loginButton.setLoading(false) { success in
                // Go to home screen
                let vc = UINavigationController(rootViewController: HomeController())
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
                
                
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
            }
        }
    }
    
    private func handleError(_ error: Error) {
        loginButton.setLoading(false)
        self.presentError(error: error)
    }    
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginPressed()
        }
        return true
    }
}
