//
//  GenericPopup.swift
//  Hermes
//
//  Created by Shane on 5/23/24.
//

import Foundation
import UIKit
import SnapKit

class GenericPopup: PopupController {
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(22.0)
        l.numberOfLines = 0
        
        return l
    }()
    
    let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font.withDynamicSize(16.0)

        return l
    }()
    
    lazy var button: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        return b
    }()
    
    var buttonCompletion: (() -> Void)?
    
    init(title: String, description: String?, buttonTitle: String, buttonCompletion: (() -> Void)?) {
        self.buttonCompletion = buttonCompletion
        super.init(nil)
        
        button.setTitle( buttonTitle, for: .normal)
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {

        popupView.addSubview(descriptionLabel)
        popupView.addSubview(titleLabel)
        popupView.addSubview(button)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(button)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(button.snp.top).offset(-10)
            make.centerX.equalTo(titleLabel)
            make.width.equalTo(titleLabel)
        }
        
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func buttonAction() {
        dismissPopup()
        buttonCompletion?()
    }
    
}
