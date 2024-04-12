//
//  AdminSupportCell.swift
//  Hermes
//
//  Created by Shane on 3/26/24.
//

import Foundation
import UIKit
import SnapKit

class AdminSupportCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(20.0)
        l.textColor = ThemeManager.Color.text
        
        return l
    }()
   
    let lastMessageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font.withDynamicSize(14.0)
        l.textColor = ThemeManager.Color.gray
    
            
        return l
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .light).font.withDynamicSize(14.0)
        l.textColor = ThemeManager.Color.placeholder
        l.textAlignment = .right
        
        return l
    }()
    
    let unreadCirlce: UIView = {
        let v = UIView()
        v.backgroundColor = ThemeManager.Color.yellow
        return v
    }()
    
    var support: Support? {
        didSet {
            guard let support = support else { return }
            
            nameLabel.text = support.user.name
            
            if let last = support.lastMessage {
                lastMessageLabel.text = last.text
                
                let df = DateFormatter()
                df.dateFormat = "h:mm a"
                
                timeLabel.text = df.string(from: last.timestamp.dateValue())
                
                if last.senderId != UserManager.shared.currentUser?.id {
                    unreadCirlce.isHidden = last.read == true
                } else {
                    unreadCirlce.isHidden = true
                }
                
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        addSubview(lastMessageLabel)
        addSubview(timeLabel)
        addSubview(unreadCirlce)
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.centerY)
            make.leading.equalToSuperview().offset(10)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(nameLabel)
        }
        
        unreadCirlce.snp.makeConstraints { make in
            make.centerY.equalTo(lastMessageLabel)
            make.trailing.equalTo(timeLabel)
            make.width.height.equalTo(10)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        unreadCirlce.layer.cornerRadius = unreadCirlce.bounds.width / 2.0
    }
}

