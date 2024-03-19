//
//  DesertEmptyView.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import UIKit
import SnapKit

class DesertEmptyView: UIView {
        
    let desertImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "desert_empty"))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Oops!"
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.text
        l.text = "Hermes doesn't currently provide service to this area. Please select another address."
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        addSubview(desertImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        desertImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(desertImageView.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
    }
}
