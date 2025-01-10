//
//  AddPaymentMethodController.swift
//  Hermes
//
//  Created by Shane on 3/6/24.
//

import Foundation
import UIKit
import SnapKit
import StripePaymentsUI

class AddPaymentMethodController: BaseViewController {
    
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        cardTextField.backgroundColor = ThemeManager.Color.textFieldBackground
        cardTextField.font = ThemeManager.Font.Style.secondary(weight: .medium).font
        cardTextField.textColor = ThemeManager.Color.text
        cardTextField.tintColor = ThemeManager.Color.text
        
        return cardTextField
    }()
    
    lazy var saveButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Save", for: .normal)
        b.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Payment Method"
        
        setupForKeyboard()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(cardTextField)
        view.addSubview(saveButton)
        
        cardTextField.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalToSuperview().multipliedBy(0.08)
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
    }
    
    @objc func savePressed() {
        
        guard cardTextField.isValid else {
            self.presentError(message: "Please enter a valid card")
            return
        }
        
        let params = cardTextField.paymentMethodParams
        print("Save with params")
        print(params)
        
        saveButton.setLoading(true)
        
        
        STPAPIClient.shared.createPaymentMethod(with: params) { (paymentMethod, error) in
            if let error = error {
                // Handle error
                print("Error creating payment method: \(error.localizedDescription)")
                return
            }
            guard let paymentMethodId = paymentMethod?.stripeId else {
                // Handle missing payment method ID
                print("Failed to retrieve payment method ID")
                return
            }
            // Send paymentMethodId to your server
            print("Payment method ID: \(paymentMethodId)")
            
            UserManager.shared.savePaymentMethod(paymentMethodId: paymentMethodId) { error in
                self.saveButton.setLoading(false) { _ in
                    if let error = error {
                        self.presentError(error: error)
                    } else {
                        print("Successfully saved payment method")
                    }
                }
            }
        }
    }
}
