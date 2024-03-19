//
//  HermesTextField.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit


class HermesTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    // MARK: - Properties

    let floatingPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeManager.Color.placeholder
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private var floatingPlaceholderTopConstraint: Constraint?
    
    open var hidesPlacesholderWhenTypeing: Bool = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setupStyle()
        
        // Set up floating placeholder label
        addSubview(floatingPlaceholderLabel)
        
        floatingPlaceholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(padding.left)
            make.trailing.equalToSuperview().inset(padding.right)
            floatingPlaceholderTopConstraint = make.centerY.equalToSuperview().constraint // Will be updated later
        }
        
        // Listen for text field editing events
        addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    
    private func setupStyle() {
        backgroundColor = ThemeManager.Color.textFieldBackground
        font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(ThemeManager.Font.placeholderFontSize)
        textColor = ThemeManager.Color.text
        layer.cornerRadius = 10
        tintColor = ThemeManager.Color.text
        autocapitalizationType = .none
        adjustsFontSizeToFitWidth = true
    }

    // MARK: - Placeholder Handling

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update floating placeholder position
        updateFloatingPlaceholderPosition()
    }

    @objc func textFieldEditingChanged() {
        // Update floating placeholder position when text changes
        updateFloatingPlaceholderPosition()
    }

    private func updateFloatingPlaceholderPosition() {
        if let text = text, !text.isEmpty {
            // If text field has text, move the floating placeholder above the text field
            floatingPlaceholderTopConstraint?.update(offset: -((bounds.height / 2) + floatingPlaceholderLabel.bounds.height / 2))
            floatingPlaceholderLabel.font = ThemeManager.Font.Style.main.font
            floatingPlaceholderLabel.textColor = ThemeManager.Color.gray
            
            floatingPlaceholderLabel.isHidden = hidesPlacesholderWhenTypeing
            
        } else {
            // If text field is empty, move the floating placeholder back to its original position
            floatingPlaceholderTopConstraint?.update(offset: 0)
            floatingPlaceholderLabel.font = ThemeManager.Font.Style.main.font.withDynamicSize(ThemeManager.Font.placeholderFontSize)
            floatingPlaceholderLabel.textColor = ThemeManager.Color.placeholder
            
            floatingPlaceholderLabel.isHidden = false
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    // MARK: - Public Methods

    func setPlaceholder(_ placeholder: String) {
        floatingPlaceholderLabel.text = placeholder
    }

    func showError() {
        layer.borderColor = ThemeManager.Color.yellow.cgColor
        layer.borderWidth = 1.5
    }
}
