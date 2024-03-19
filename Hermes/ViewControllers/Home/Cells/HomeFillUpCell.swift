//
//  HomeFillUpCell.swift
//  Hermes
//
//  Created by Shane on 3/10/24.
//

import Foundation
import UIKit
import SnapKit


class HomeFillUpCell: UITableViewCell {
    
    let dateContainer: UIView = {
        let v = UIView()
        v.backgroundColor = ThemeManager.Color.yellow.withAlphaComponent(0.28)
        v.layer.cornerRadius = 10
        
        return v
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.yellow
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(20.0)
        l.text = "\(Constants.Text.operatingHours)"
        l.adjustsFontSizeToFitWidth = true
        
        return l
    }()
    
    let weekdayLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.yellow
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(16.0)
        
        return l
    }()
    
    let monthLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.yellow
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(16.0)
        
        return l
    }()
    
    let dayLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.yellow
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(40.0)
        
        return l
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            
            let components = date.get(.day, .year)
            guard let day = components.day else { return }
            
            if let dayOfWeek = date.dayOfWeek() {
                monthLabel.text = String(date.monthName().prefix(3))
                weekdayLabel.text = String(dayOfWeek.prefix(3))
                dayLabel.text = "\(day)"
            }
        }
    }
    
    var fillUp: FillUp? {
        didSet {
            guard let fillUp = fillUp else { return }
            
            // Set Date
            let components = fillUp.date.get(.day, .year)
            guard let day = components.day else { return }
            
            if let dayOfWeek = fillUp.date.dayOfWeek() {
                monthLabel.text = String(fillUp.date.monthName().prefix(3))
                weekdayLabel.text = String(dayOfWeek.prefix(3))
                dayLabel.text = "\(day)"
            }
        }
    }
    
    var didLayoutSubviews = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        tintColor = ThemeManager.Color.yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(dateContainer)
        addSubview(timeLabel)
        
        dateContainer.addSubview(weekdayLabel)
        dateContainer.addSubview(dayLabel)
        dateContainer.addSubview(monthLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(dateContainer)
            make.bottom.equalToSuperview().offset(-10)
        }
                
        dateContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(dateContainer.snp.height).multipliedBy(0.8)
            make.bottom.equalTo(timeLabel.snp.top)
        }
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        weekdayLabel.snp.makeConstraints { make in
            make.bottom.equalTo(dayLabel.snp.top)
            make.top.greaterThanOrEqualTo(dateContainer.snp.top).offset(2)
            make.centerX.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom)
            make.bottom.lessThanOrEqualTo(dateContainer.snp.bottom).offset(-2)
            make.centerX.equalToSuperview()
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
                make.centerY.equalTo(dateContainer.snp.centerY).offset(10)
                
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
                    make.leading.equalTo(dateContainer.snp.trailing).offset(20)
                }
            }
            
            makeLabel.snp.makeConstraints { make in
                make.bottom.equalTo(modelLabel.snp.top).offset(5)
                make.leading.equalTo(modelLabel)
            }
            
            
            previousModel = modelLabel

        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if fillUp != nil && !didLayoutSubviews {
            setupViews()
            setupCarLabels()
            didLayoutSubviews = true
        }
    }
    
}
