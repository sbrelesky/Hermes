//
//  GasEstimateCarCell.swift
//  Hermes
//
//  Created by Shane on 4/23/24.
//

import Foundation
import UIKit
import SnapKit


class GasEstimateCarCell: UICollectionViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.layer.cornerRadius = 10
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "car.fill")?.withRenderingMode(.alwaysTemplate)

        return iv
    }()
    
    let modelLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(40.0)

        return l
    }()
    
    let makeLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(30.0)
        
        return l
    }()
    
    var car: Car? {
        didSet {
            guard let car = car else { return }
            makeLabel.text = car.make
            modelLabel.text = car.model
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // contentView.addSubview(iconImageView)
        contentView.addSubview(modelLabel)
        contentView.addSubview(makeLabel)
        
//        iconImageView.snp.makeConstraints { make in
//            make.leading.centerY.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.7)
//            make.width.equalTo(iconImageView.snp.height)
//        }
        
        modelLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            //make.leading.equalTo(iconImageView.snp.trailing).offset(20)
        }
        
        makeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(modelLabel.snp.top).offset(5)
            make.centerX.equalToSuperview()
        }
    }
}
