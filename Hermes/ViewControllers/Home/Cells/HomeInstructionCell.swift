//
//  HomeFillUpCell.swift
//  Hermes
//
//  Created by Shane on 3/10/24.
//

import Foundation
import UIKit
import SnapKit


enum HomeInstruction: Int {
    case move = 0
    case open = 1
    case enjoy = 2
}


class HomeInstructionCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        //iv.backgroundColor = ThemeManager.Color.gray.withAlphaComponent(0.5)
        iv.layer.cornerRadius = 10
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withSize(24.0)
        l.adjustsFontSizeToFitWidth = true
        
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withSize(16.0)
        l.numberOfLines = 0
        
        return l
    }()
    
    var instruction: HomeInstruction? {
        didSet {
            guard let instruction = instruction else { return }
            
            switch instruction {
            case .move:
                titleLabel.text = "Move Your Car"
                messageLabel.text = "Remember to leave your car in an easily accessible space."
                iconImageView.image = UIImage(systemName: "car.fill")?.withRenderingMode(.alwaysTemplate)
                
            case .open:
                titleLabel.text = "Open Gas Cap Cover"
                messageLabel.text = "Please make sure to unlock the gas cap cover if necessary."
                iconImageView.image = UIImage(systemName: "key.fill")?.withRenderingMode(.alwaysTemplate)

            case .enjoy:
                titleLabel.text = "Enjoy"
                messageLabel.text = "Enjoy a hassle free filled gas tank!"
                iconImageView.image = UIImage(systemName: "fuelpump.fill")?.withRenderingMode(.alwaysTemplate)

            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.iconImageView)
            make.height.equalTo(iconImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconImageView.snp.centerY)
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }
    }
    
}
