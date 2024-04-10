//
//  ViewOrderCancelCell.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation
import UIKit
import SnapKit

protocol ViewOrderCancelCellDelegate: AnyObject {
    func cancelPressed(button: HermesLoadingButton)
}

class ViewOrderCancelCell: UITableViewCell {
    
    lazy var cancelButton: HermesLoadingButton = {
        let b = HermesLoadingButton(widthMultiplier: 0.90)
        b.setTitle("Cancel", for: .normal)
        b.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        b.backgroundColor = ThemeManager.Color.red.withAlphaComponent(0.1)
        b.setTitleColor(ThemeManager.Color.red, for: .normal)
        
        return b
    }()
    
    weak var delegate: ViewOrderCancelCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        contentView.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
        }
    }
    
    @objc func cancelPressed() {
        delegate?.cancelPressed(button: cancelButton)
    }
}
