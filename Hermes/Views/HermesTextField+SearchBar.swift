//
//  HermesSearchBar.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit
import SnapKit

protocol HermesSearchBarTextFieldDelegate: AnyObject {
    func searching(searchText: String)
    func stopSearching()
}


class HermeSearchBarTextField: HermesTextField {
    
    weak var searchDelegate: HermesSearchBarTextFieldDelegate?

    let adjustedPadding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 8)

    let searchIconImageview: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleToFill
        iv.tintColor = ThemeManager.Color.placeholder
        
        return iv
    }()
    
    override func commonInit() {
        super.commonInit()
        
        layer.cornerRadius = 10
        hidesPlacesholderWhenTypeing = true
        clearButtonMode = .whileEditing
        
        floatingPlaceholderLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(40)
        }
        
        addSubview(searchIconImageview)
        
        searchIconImageview.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding.left)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: adjustedPadding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: adjustedPadding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: adjustedPadding)
    }
    
    override func textFieldEditingChanged() {
        super.textFieldEditingChanged()
        if let text = text, !text.isEmpty {
            searchDelegate?.searching(searchText: text)
        } else {
            searchDelegate?.stopSearching()
        }
    }
}

