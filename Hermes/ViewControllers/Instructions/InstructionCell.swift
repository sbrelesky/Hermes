//
//  InstructionCell.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation
import UIKit
import SnapKit

class InstructionCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    var type: InstructionType? {
        didSet {
            guard let type = type else { return }
            
            switch type {
            case .car:
                imageView.image = UIImage(named: "house_with_car")
                imageView.contentMode = .scaleAspectFit
                titleLabel.text = "Please Remember"
                messageLabel.text = "Leave your vehicle in an easily accessible location for our driver to get to."
                
                imageView.snp.updateConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(20)
                }
            case .gasCap:
                imageView.image = UIImage(named: "open_gas_cap")
                imageView.contentMode = .scaleAspectFill
                titleLabel.text = "Unlock Gas Cap"
                messageLabel.text = "Leave your gas cap unlocked or open. We will close it when the fill up is complete."
                
                imageView.snp.updateConstraints { make in
                    make.leading.trailing.equalToSuperview()
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(imageView.snp.width).multipliedBy(0.61)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
    }
    
}
