//
//  AdminSettingsController.swift
//  Hermes
//
//  Created by Shane on 3/18/24.
//

import Foundation
import UIKit
import SnapKit

class AdminSettingsController: BaseViewController, TextFieldValidation {
    
    let regularPriceTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Regular")
        tf.keyboardType = .decimalPad
        return tf
    }()
    
    let midgradePriceTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Midgrade")
        tf.keyboardType = .decimalPad
        return tf
    }()
    
    
    let premiumPriceTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Premium")
        tf.keyboardType = .decimalPad
        return tf
    }()
    
    let dieselPriceTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Diesel")
        tf.keyboardType = .decimalPad
        return tf
    }()
    
    
    let serviceFeeTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Service Fee")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    lazy var saveButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Save Button", for: .normal)
        b.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Admin Settings"
        
        setupForKeyboard()
        setupViews()
        setTextFieldValues()
    }
    
    private func setupViews() {
        
        view.addSubview(regularPriceTextField)
        view.addSubview(midgradePriceTextField)
        view.addSubview(premiumPriceTextField)
        view.addSubview(dieselPriceTextField)
        view.addSubview(serviceFeeTextField)
        view.addSubview(saveButton)
        
        
        regularPriceTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        midgradePriceTextField.snp.makeConstraints { make in
            make.top.equalTo(regularPriceTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(regularPriceTextField)
        }
        
        premiumPriceTextField.snp.makeConstraints { make in
            make.top.equalTo(midgradePriceTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(regularPriceTextField)
        }
        
        dieselPriceTextField.snp.makeConstraints { make in
            make.top.equalTo(premiumPriceTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(regularPriceTextField)
        }
        
        serviceFeeTextField.snp.makeConstraints { make in
            make.top.equalTo(dieselPriceTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(regularPriceTextField)
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.top.greaterThanOrEqualTo(serviceFeeTextField.snp.bottom).offset(40)
        }
    }
    
    private func setTextFieldValues() {
        regularPriceTextField.text = "\(Settings.shared.prices.regular)"
        midgradePriceTextField.text = "\(Settings.shared.prices.midgrade)"
        premiumPriceTextField.text = "\(Settings.shared.prices.premium)"
        dieselPriceTextField.text = "\(Settings.shared.prices.diesel)"
        serviceFeeTextField.text = "\(Settings.shared.serviceFee)"
    }
    
    @objc func saveButtonPressed() {
        guard let regular: Double = getTextFieldValue(regularPriceTextField),
              let mid: Double = getTextFieldValue(midgradePriceTextField),
              let premium: Double = getTextFieldValue(premiumPriceTextField),
              let diesel: Double = getTextFieldValue(dieselPriceTextField),
              let serviceFee: Double = getTextFieldValue(serviceFeeTextField) else { return }
        
        saveButton.setLoading(true)
        
        Settings.shared.prices = Prices(regular: regular, midgrade: mid, premium: premium, diesel: diesel)
        Settings.shared.serviceFee = serviceFee
        
        AdminManager.shared.updateSettings { error in
            self.saveButton.setLoading(false)
            
            if let error = error {
                self.presentError(error: error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
