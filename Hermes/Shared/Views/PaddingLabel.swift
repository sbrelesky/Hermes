//
//  PaddingLabel.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit


class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

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
}

