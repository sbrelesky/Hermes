//
//  GetNotifiedPopup.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit


class GetNotifiedPopup: PopupController, TextFieldValidation {
    
    let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .left
    
        return l
    }()
    
    let emailTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Email")
        tf.keyboardType = .emailAddress
        
        return tf
    }()
    
    lazy var getNotifiedButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Get Notified", for: .normal)
        b.addTarget(self, action: #selector(getNotifiedPressed), for: .touchUpInside)
        
        return b
    }()
    
    let zipCode: String
    
    init(areaCode: String, completion: (() -> Void)?) {
        self.zipCode = areaCode
        super.init(completion)
        setDescriptionText(areaCode: areaCode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {

        popupView.addSubview(descriptionLabel)
        popupView.addSubview(emailTextField)
        popupView.addSubview(getNotifiedButton)
        
        emailTextField.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.top).offset(30)
            make.bottom.lessThanOrEqualTo(emailTextField.snp.top).offset(-30)
            make.leading.equalTo(emailTextField)
            make.width.lessThanOrEqualTo(emailTextField)
        }
        
        getNotifiedButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func getNotifiedPressed() {
        guard let email = emailTextField.text, validateNonNilEmptyString(email) else {
            emailTextField.showError()
            return
        }
        
        getNotifiedButton.setLoading(true)
        
        FirestoreManager.shared.joinWaitlist(email: email, zip: zipCode) { error in
            self.getNotifiedButton.setLoading(false) { success in
                self.dismissPopup()
            }
        }
    }
    
    
    private func setDescriptionText(areaCode: String) {
        let attributedOne = NSAttributedString(string: "Hermes isn't available in \(areaCode) yet.", attributes: [
            .font: ThemeManager.Font.Style.secondary(weight: .demiBold).font,
            .foregroundColor: ThemeManager.Color.text
        ])
        
        let attributedTwo = NSAttributedString(string: "\nBe the first to know when we launch in your area!", attributes: [
            .font: ThemeManager.Font.Style.secondary(weight: .regular).font,
            .foregroundColor: ThemeManager.Color.text
        ])
        
        let mutableString = NSMutableAttributedString(attributedString: attributedOne)
        mutableString.append(attributedTwo)
        
        descriptionLabel.attributedText = mutableString
    }
}

