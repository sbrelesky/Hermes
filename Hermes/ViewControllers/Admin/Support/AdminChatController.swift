//
//  AdminChatController.swift
//  Hermes
//
//  Created by Shane on 4/8/24.
//

import Foundation
import UIKit
import SnapKit

class AdminChatController: ChatController {
    
    
    let usernameLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .center
        
        return l
    }()
    
    
    let orderLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .center
        
        return l
    }()
    
    
    override func setupViews() {
        view.addSubview(orderLabel)
        view.addSubview(usernameLabel)
        view.addSubview(inputBar)
        view.addSubview(collectionView)
        
        usernameLabel.snp.makeConstraints { make in
            make.top.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        orderLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom)
            make.centerX.equalTo(usernameLabel)
        }
        
        let divider = UIView()
        divider.backgroundColor = ThemeManager.Color.gray.withAlphaComponent(0.4)
        
        view.addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(orderLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        inputBar.snp.makeConstraints { make in
            inputBarBottom = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputBar.snp.top).offset(-20)
        }
        
        orderLabel.text = "#\(support.id ?? "")"
        usernameLabel.text = support.user.name
    }
    
}
