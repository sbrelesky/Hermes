//
//  EditPaymentMethodController.swift
//  Hermes
//
//  Created by Shane on 3/8/24.
//

import Foundation
import UIKit
import SnapKit
import StripePaymentsUI

class EditPaymentMethodController: BaseViewController {
    
    
    // MARK: These are read only...
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
    
    let paymentMethod: STPPaymentMethod
    
    init(paymentMethod: STPPaymentMethod) {
        self.paymentMethod = paymentMethod
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Payment Method"
        
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
    
    private func setPaymentMethodValues(paymentMethod: STPPaymentMethod) {
        
    }
    
    @objc func savePressed() {
        
        guard cardTextField.isValid else {
            self.presentError(message: "Please enter a valid card")
            return
        }
        
        saveButton.setLoading(true)
        
        FirebaseFunctionManager.shared.createEphemeralKey { result in
            self.saveButton.setLoading(false)
            
            switch result {
            case .success(let key):
                self.updatePaymentMethod(key: key)
            case .failure(let error):
                self.presentError(error: error)
            }
        }
    }

    private func updatePaymentMethod(key: String) {
        let params = cardTextField.paymentMethodParams
        guard let cardParams = params.card else { return }

        let updateParams = STPPaymentMethodUpdateParams(card: cardParams, billingDetails: nil)
        STPAPIClient.shared.updatePaymentMethod(with: paymentMethod.stripeId, paymentMethodUpdateParams: updateParams, ephemeralKeySecret: key) { paymentMethod, error in
            if let error = error {
                // Handle error
                print("Error creating payment method: \(error.localizedDescription)")
                return
            } else {
                print("Succesfully Updated Payment method")
            }
        }
    }
    
}
