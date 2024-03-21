//
//  SpeedbumpPopup.swift
//  Hermes
//
//  Created by Shane on 3/12/24.
//

import Foundation
import UIKit
import SnapKit

class SpeedbumpPopup: PopupController {
    
    let warningImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")?.withRenderingMode(.alwaysTemplate).applyingSymbolConfiguration(.init(pointSize: 40.0)))
        iv.contentMode = .scaleToFill
        iv.tintColor = ThemeManager.Color.yellow
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(22.0)

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


    lazy var cancelButton: HermesButton = {
        let b = HermesButton(widthMultiplier: 0.4)
        b.setTitle("Dismiss", for: .normal)
        b.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return b
    }()

    
    
    lazy var confirmButton: HermesLoadingButton = {
        let b = HermesLoadingButton(widthMultiplier: 0.4)
        b.setTitle("Confirm", for: .normal)
        b.addTarget(self, action: #selector(confirmPressed), for: .touchUpInside)
        return b
    }()
    
    
    let confirmCompletion: (() -> Void)?
    
    init(title: String = "Are you sure?", message: String, completion: (() -> Void)?, confirmCompletion: (() -> Void)?) {
        self.titleLabel.text = title
        self.confirmCompletion = confirmCompletion
        self.messageLabel.text = message
        super.init(completion)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {
        
        popupView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        popupView.addSubview(warningImageView)
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        popupView.addSubview(cancelButton)
        popupView.addSubview(confirmButton)
        
        warningImageView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(warningImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(warningImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.button)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(cancelButton.snp.top).offset(-30)
            make.centerX.equalTo(titleLabel)
            make.width.lessThanOrEqualTo(titleLabel)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.trailing.equalTo(popupView.snp.centerX).offset(-10)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.equalTo(popupView.snp.centerX).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        cancelButton.backgroundColor = ThemeManager.Color.gray
    }
    
    @objc func confirmPressed() {
        self.dismissPopup()
        confirmCompletion?()
    }

    
    @objc func cancelPressed() {
        dismissPopup()
    }
}
