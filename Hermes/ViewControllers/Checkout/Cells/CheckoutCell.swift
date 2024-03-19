//
//  CheckoutCell.swift
//  Hermes
//
//  Created by Shane on 3/6/24.
//

import Foundation
import UIKit
import SnapKit

enum CheckoutCellType: Int {
    case car = 0
    case address = 1
    case date = 2
}

class CheckoutCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.layer.cornerRadius = 10
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "mappin.and.ellipse")?.withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    
    let mainLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(31.0) //.secondary(weight: .demiBold).font.withDynamicSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let subLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(21.0) //.secondary(weight: .demiBold).font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(mainLabel)
        contentView.addSubview(subLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.iconImageView)
            make.height.equalTo(iconImageView.snp.width)
        }
        
        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.bottom.equalTo(self.snp.centerY)
        }
        
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainLabel)
            make.top.equalTo(mainLabel.snp.bottom)
        }
    }
}





