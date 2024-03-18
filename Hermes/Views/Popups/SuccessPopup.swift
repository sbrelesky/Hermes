//
//  SuccessPopup.swift
//  Hermes
//
//  Created by Shane on 3/14/24.
//

import Foundation
import UIKit
import SnapKit

class SuccessPopup: PopupController {
    
    let successImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate).applyingSymbolConfiguration(.init(pointSize: 40.0)))
        iv.contentMode = .scaleToFill
        iv.tintColor = ThemeManager.Color.green
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withSize(22.0)

        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font

        return l
    }()


    lazy var okayButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Okay", for: .normal)
        b.addTarget(self, action: #selector(okayPressed), for: .touchUpInside)
        return b
    }()


    init(title: String, message: String, completion: (() -> Void)?) {
        titleLabel.text = title
        messageLabel.text = message
        super.init(completion)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {
        
        popupView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalTo(popupView.snp.width)
        }
        
        popupView.addSubview(successImageView)
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        popupView.addSubview(okayButton)
                
        successImageView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(successImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(okayButton)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(okayButton.snp.top).offset(-30)
            make.centerX.equalTo(titleLabel)
            make.width.equalTo(titleLabel)
        }
        
        let bottomSpacing = view.bounds.height * 0.023
        
        okayButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomSpacing)
            make.centerX.equalToSuperview()
        }
    }

    @objc func okayPressed() {
        dismissPopup()
    }
}
