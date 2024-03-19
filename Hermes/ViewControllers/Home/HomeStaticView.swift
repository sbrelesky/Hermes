//
//  HomeStaticView.swift
//  Hermes
//
//  Created by Shane on 3/9/24.
//

import Foundation
import UIKit
import SnapKit

class HomeStaticView: UIView {
    
    let imageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.image = UIImage(named: "van_static")
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.text = "Overnight Gas Fillup"
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(22.0)

        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font
        l.text = "We provide a seamless overnight gas fueling experience."
        
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
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
        }
        
        let padding = (UIScreen.main.bounds.width * (1.0 - Constants.WidthMultipliers.button)) / 2
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(padding)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
    }
    
}
