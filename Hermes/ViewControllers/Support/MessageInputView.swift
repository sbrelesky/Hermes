//
//  MessageInputView.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit

protocol MessageInputDelegate: AnyObject {
    func sendMessage(text: String)
}

class MessageInputView: UIView, UITextFieldDelegate {
    
    lazy var sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.imageView?.contentMode = .scaleAspectFit
        b.setImage(UIImage(systemName: "paperplane.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = ThemeManager.Color.yellow
        b.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    
        
        return b
    }()
    
    let messageTextField: PaddedTextField =  {
        let tf = PaddedTextField()
        tf.backgroundColor = ThemeManager.Color.textFieldBackground
        tf.layer.borderColor = ThemeManager.Color.placeholder.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 10
        tf.tintColor = ThemeManager.Color.text
        
        tf.placeholder = "Type your message"
        tf.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        tf.returnKeyType = .send
        
        return tf
    }()
    
    weak var delegate: MessageInputDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(sendButton)
        addSubview(messageTextField)
        
        messageTextField.delegate = self
                
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.1)
            make.height.equalTo(sendButton.snp.width)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
        }
    }
    
    @objc func sendMessage() {
        guard let text = messageTextField.text else { return }
        delegate?.sendMessage(text: text)
        
        // Clear text field after sending message
        messageTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

