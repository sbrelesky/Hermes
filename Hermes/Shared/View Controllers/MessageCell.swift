//
//  MessageCell.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit


class MessageCell: UICollectionViewCell {
    
    let messageBubble: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = ThemeManager.Color.placeholder
        v.clipsToBounds = true
        v.layer.cornerRadius = 12
        
        return v
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        return label
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .light).font.withDynamicSize(12.0)
        l.textColor = ThemeManager.Color.placeholder
        
        return l
    }()
    
    
    var chatMessage: ChatMessage? {
        didSet {
            guard let chatMessage = chatMessage else { return }
            messageLabel.text = chatMessage.text
            
            let df = DateFormatter()
            df.dateFormat = "h:mm a"
            
            timeLabel.text = df.string(from: chatMessage.timestamp.dateValue())
                        
            if chatMessage.senderId != UserManager.shared.currentUser?.id {
                // From Admin
                styleAdmin()
            } else {
                styleUser()
            }
        }
    }
  
    var timeTrailingConstraint: Constraint?
    var timeLeadingConstraint: Constraint?
    
    var trailingConstraint: Constraint?
    var leadingConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        messageBubble.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.7)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(messageBubble)
        }
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Methods
    
    // Style Methods
    
    private func styleAdmin() {
        messageLabel.textAlignment = .left
        messageLabel.textColor = ThemeManager.Color.text
        messageBubble.backgroundColor = ThemeManager.Color.textFieldBackground
        
        setConstraintsForAdmin()
    }
    
    private func styleUser() {
        messageLabel.textAlignment = .left
        messageLabel.textColor = .white
        messageBubble.backgroundColor = ThemeManager.Color.yellow // .withAlphaComponent(0.4)
        
        setConstraintsForUser()
    }
    
    // Constraint Methods
    
    private func setConstraintsForUser() {
        if trailingConstraint == nil {
            messageBubble.snp.makeConstraints { make in
                trailingConstraint = make.trailing.equalToSuperview().offset(-12).constraint
            }
        } else {
            trailingConstraint?.activate()
        }
        
        leadingConstraint?.deactivate()
        
        if timeTrailingConstraint == nil {
            timeLabel.snp.makeConstraints { make in
                timeTrailingConstraint = make.trailing.equalTo(messageBubble.snp.leading).offset(-5).constraint
            }
        } else {
            timeTrailingConstraint?.activate()
        }
        
        timeLeadingConstraint?.deactivate()
    }
    
    private func setConstraintsForAdmin() {
        if leadingConstraint == nil {
            messageBubble.snp.makeConstraints { make in
                leadingConstraint = make.leading.equalToSuperview().offset(12).constraint
            }
        } else {
            leadingConstraint?.activate()
        }
        
        trailingConstraint?.deactivate()

        
        if timeLeadingConstraint == nil {
            timeLabel.snp.makeConstraints { make in
                timeLeadingConstraint = make.leading.equalTo(messageBubble.snp.trailing).offset(5).constraint
            }
        } else {
            timeLeadingConstraint?.activate()
        }
        
        timeTrailingConstraint?.deactivate()
    }

    private func resetConstraints() {
        trailingConstraint?.deactivate()
        leadingConstraint?.deactivate()
        
        timeLeadingConstraint?.deactivate()
        timeTrailingConstraint?.deactivate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraints()
    }
}
