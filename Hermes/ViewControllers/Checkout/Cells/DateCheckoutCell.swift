//
//  CheckoutCell.swift
//  Hermes
//
//  Created by Shane on 3/12/24.
//

import Foundation
import UIKit
import SnapKit

class DateCheckoutCell: CheckoutCell {
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.text = "\(Constants.Text.operatingHours)"
        l.textAlignment = .left
        
        return l
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
    }
}
