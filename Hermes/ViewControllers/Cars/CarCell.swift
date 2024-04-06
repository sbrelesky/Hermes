//
//  HomeCarCell.swift
//  Hermes
//
//  Created by Shane on 3/1/24.
//

import Foundation
import UIKit
import SnapKit

class CarTableViewCell: UITableViewCell {
    
    
    let cardView: UIView = {
        let v = UIView(frame: .zero)
        // v.backgroundColor = .white
        // v.layer.cornerRadius = 20
        
        return v
    }()
    
    
    let modelLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(43.0)

        return l
    }()
    
    let makeLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font
        
        return l
    }()
    
    let licenseLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .right
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(43.0)

        return l
    }()

    let yearLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font

        return l
    }()
    
    let gasTypeLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .right
        l.font = ThemeManager.Font.Style.main.font
        
        return l
    }()
    
    let unlockNeededLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .right
        l.font = ThemeManager.Font.Style.main.font
        

        return l
    }()
    
    var car: Car? {
        didSet {
            guard let car = car else { return }
            modelLabel.text = car.model
            makeLabel.text = car.make
            yearLabel.text = car.year
            licenseLabel.text = car.license
            gasTypeLabel.text = car.fuel.rawValue
            unlockNeededLabel.text = car.gasCapUnlockNeeded == "Yes" ? "Key Needed" : "Key Not Needed"
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
        addSubview(cardView)
        cardView.addSubview(modelLabel)
        cardView.addSubview(makeLabel)
        cardView.addSubview(yearLabel)
        cardView.addSubview(licenseLabel)
        cardView.addSubview(gasTypeLabel)
        cardView.addSubview(unlockNeededLabel)
        
        cardView.snp.makeConstraints { make in
            make.width.height.equalToSuperview() // .multipliedBy(0.9)
            make.centerX.centerY.equalToSuperview()
        }
        
        modelLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.45)
        }
        
        makeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(modelLabel.snp.top).offset(5)
            make.leading.equalTo(modelLabel)
        }
        
        yearLabel.snp.makeConstraints { make in
            make.top.equalTo(modelLabel.snp.bottom).offset(-5)
            make.leading.equalTo(modelLabel)
        }
        
        
        licenseLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.45)
        }
        
        gasTypeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(licenseLabel.snp.top).offset(5)
            make.trailing.equalTo(licenseLabel)
        }
        
        unlockNeededLabel.snp.makeConstraints { make in
            make.top.equalTo(licenseLabel.snp.bottom).offset(-5)
            make.trailing.equalTo(licenseLabel)
        }
        
        cardView.layoutIfNeeded()
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            styleSelected()
        } else {
            styleUnslected()
        }
    }
    
    private func styleSelected() {
        cardView.backgroundColor = ThemeManager.Color.primary
        
        if shadowLayer != nil {
            shadowLayer?.fillColor = ThemeManager.Color.primary.cgColor
        }
        
        modelLabel.textColor = .white
        makeLabel.textColor = .white.withAlphaComponent(0.75)
        yearLabel.textColor = .white.withAlphaComponent(0.75)
        
        licenseLabel.textColor = .white.withAlphaComponent(0.75)
        gasTypeLabel.textColor = .white.withAlphaComponent(0.43)
        unlockNeededLabel.textColor = .white.withAlphaComponent(0.43)
    }
    
    private func styleUnslected() {
        cardView.backgroundColor = .white
       
        if shadowLayer != nil {
            // shadowLayer?.fillColor = UIColor.white.cgColor
        }
        
        modelLabel.textColor = ThemeManager.Color.text
        makeLabel.textColor = ThemeManager.Color.gray
        yearLabel.textColor = ThemeManager.Color.gray
        
        licenseLabel.textColor = ThemeManager.Color.gray
        gasTypeLabel.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        unlockNeededLabel.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
    }
    
    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        if shadowLayer == nil && cardView.bounds.width > 0.0 {
//            shadowLayer = CAShapeLayer()
//          
//            shadowLayer.path = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: cardView.layer.cornerRadius).cgPath
//            shadowLayer.fillColor = cardView.backgroundColor?.cgColor
//
//            shadowLayer.shadowColor = UIColor.black.cgColor
//            shadowLayer.shadowPath = shadowLayer.path
//            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//            shadowLayer.shadowOpacity = 0.16
//            shadowLayer.shadowRadius = 3
//
//            cardView.layer.insertSublayer(shadowLayer, at: 0)
//        }
    }
}
