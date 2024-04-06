//
//  LoadingPopup.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit
import SnapKit

class LoadingPopup: PopupController {
    
    let activityIndicator: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .large)
        iv.color = ThemeManager.Color.primary
        iv.hidesWhenStopped = true
        
        return iv
    }()
    
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font

        return l
    }()

    init(message: String, completion: (() -> Void)?) {
        messageLabel.text = message
        super.init(completion)
        
        dismissButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {

        print("Setup Loading Popup Views")
        
        popupView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(popupView.snp.width)
        }
        
        popupView.addSubview(activityIndicator)
        popupView.addSubview(messageLabel)
        
        activityIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(popupView.snp.centerY)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(activityIndicator.snp.width)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
        }
        
        // activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        activityIndicator.startAnimating()
    }
    
    override func dismissPopup() {
        
        print("Dismiss Popup")
        activityIndicator.stopAnimating()
        super.dismissPopup()
    }
}
