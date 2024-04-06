//
//  SupportPopup.swift
//  Hermes
//
//  Created by Shane on 3/24/24.
//

import Foundation
import UIKit
import SnapKit

class SupportPopup: PopupController {
    
    let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .left
        l.text = "Let us know what's the problem and we will get back to you as soon as we can."
        
        return l
    }()
    
    let textView: UITextView = {
        let l = UITextView()
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.text
        l.tintColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.layer.cornerRadius = 5
        l.layer.borderColor = ThemeManager.Color.placeholder.cgColor
        l.layer.borderWidth = 1.25
        
        return l
    }()
    
    lazy var sendButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Send", for: .normal)
        b.addTarget(self, action: #selector(getNotifiedPressed), for: .touchUpInside)
        
        return b
    }()
    
    override func setupAdditionalViews() {

        popupView.addSubview(descriptionLabel)
        popupView.addSubview(textView)
        popupView.addSubview(sendButton)
        
        textView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField * 2)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.top).offset(30)
            make.bottom.lessThanOrEqualTo(textView.snp.top).offset(-30)
            make.leading.equalTo(textView)
            make.width.lessThanOrEqualTo(textView)
        }
        
        sendButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
    }
    
    
    
    @objc func getNotifiedPressed() {
        guard let text = textView.text else { return }
        
        sendButton.setLoading(true)
        
        FirebaseFunctionManager.shared.sendSupportEmail(text: text) { error in
            self.sendButton.setLoading(false)
            
            if let error {
                print("Could not send email: ", error)
            }
            
            self.dismissPopup()
        }
    }
}
