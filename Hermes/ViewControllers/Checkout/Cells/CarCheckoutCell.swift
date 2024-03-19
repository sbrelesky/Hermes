//
//  CarCheckoutCell.swift
//  Hermes
//
//  Created by Shane on 3/12/24.
//

import Foundation
import UIKit
import SnapKit

class CarCheckoutCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.layer.cornerRadius = 10
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "mappin.and.ellipse")?.withRenderingMode(.alwaysTemplate)
        
        return iv
    }()
    
    var cars: [Car] = [] {
        didSet {
            if !addedCars {
                setupCarLabels()
                addedCars = false
            }
        }
    }
    
    var addedCars = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.iconImageView)
            make.height.equalTo(iconImageView.snp.width)
        }
        
        iconImageView.image = UIImage(systemName: "car.fill")?.withRenderingMode(.alwaysTemplate)
    }
    
    private func setupCarLabels() {
        var previousModel: UILabel?
                
        cars.forEach({ car in
            
            let modelLabel: UILabel = {
                let l = UILabel(frame: .zero)
                l.textColor = ThemeManager.Color.text
                l.textAlignment = .left
                l.font = ThemeManager.Font.Style.main.font.withDynamicSize(31.0)

                return l
            }()
            
            let makeLabel: UILabel = {
                let l = UILabel(frame: .zero)
                l.textColor = ThemeManager.Color.gray
                l.textAlignment = .left
                l.font = ThemeManager.Font.Style.main.font.withDynamicSize(21.0)
                
                return l
            }()
            
            modelLabel.text = car.model
            makeLabel.text = car.make
            
            addSubview(modelLabel)
            addSubview(makeLabel)
                
            modelLabel.snp.makeConstraints { make in
                
                make.centerY.equalToSuperview()
                
                if let previousModelLabel = previousModel {
                    
                    let separatorLine = UIView()
                    separatorLine.backgroundColor = ThemeManager.Color.yellow.withAlphaComponent(0.28)
                    addSubview(separatorLine)
                    
                    separatorLine.snp.makeConstraints { make in
                        make.top.equalTo(makeLabel.snp.top)
                        make.bottom.equalTo(modelLabel.snp.bottom)
                        make.leading.equalTo(previousModelLabel.snp.trailing).offset(10)
                        make.width.equalTo(2)
                    }
                    
                    make.leading.equalTo(separatorLine.snp.trailing).offset(10)
                    
                } else {
                    make.leading.equalTo(iconImageView.snp.trailing).offset(20)
                }
            }
            
            makeLabel.snp.makeConstraints { make in
                make.bottom.equalTo(modelLabel.snp.top).offset(5)
                make.leading.equalTo(modelLabel)
            }
            
            
            previousModel = modelLabel
            
        })
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
}
