//
//  AdminFillUpCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit
import SnapKit


class AdminFillUpCell: UITableViewCell {
    
    let numberLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font
        l.textAlignment = .left
        
        return l
    }()
    
    let nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(20.0)
        l.textAlignment = .left
        
        return l
    }()
    
    let addressIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.and.ellipse")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let addressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(18.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let subAddressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(14.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    
    
    var fillUp: FillUp? {
        didSet {
            guard let fillUp = fillUp, let id = fillUp.id else { return }
            
            nameLabel.text = fillUp.user.name
            addressLabel.text = fillUp.address.street
            subAddressLabel.text = fillUp.address.cityStateZip
            
            addressIconImageView.tintColor = fillUp.status == .open ? ThemeManager.Color.yellow : ThemeManager.Color.green
            
            if !didSetupCars {
                setupViews()
                //setupCarLabels()
                didSetupCars = true
            }
        }
    }
    
    var didSetupCars = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        tintColor = ThemeManager.Color.yellow
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(addressIconImageView)
        addSubview(addressLabel)
        addSubview(subAddressLabel)
        
        addSubview(numberLabel)
        addSubview(nameLabel)
        
        
        
        addressIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.iconImageView)
            make.height.equalTo(addressIconImageView.snp.width)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.bottom.equalTo(addressIconImageView.snp.centerY)
            make.leading.equalTo(addressIconImageView.snp.trailing).offset(5)
        }
        
        subAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom)
            make.leading.equalTo(addressLabel)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.centerX.equalTo(addressIconImageView)
            make.bottom.equalTo(addressLabel.snp.top)
            make.top.greaterThanOrEqualToSuperview()
        }
//        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(addressLabel)
            make.centerY.equalTo(numberLabel)
        }
      
       
    }
    
    
    private func setupCarLabels() {
        var previousModel: UILabel?
                
        fillUp?.cars.forEach({ car in
                        
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
                l.font = ThemeManager.Font.Style.main.font.withDynamicSize(20.0)
                
                return l
            }()
            
            modelLabel.text = car.model
            makeLabel.text =  car.make
            
            addSubview(modelLabel)
            addSubview(makeLabel)
                        
            modelLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview().offset(10)
                
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
                    make.leading.equalToSuperview().offset(20)
                }
            }
            
            makeLabel.snp.makeConstraints { make in
                make.bottom.equalTo(modelLabel.snp.top).offset(5)
                make.leading.equalTo(modelLabel)
            }
            
            
            previousModel = modelLabel

        })
    }
}

