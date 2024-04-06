//
//  EditOrderCell.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation
import UIKit
import SnapKit

enum ViewOrderProgressCellType: Int {
    case scheduled = 0
    case today = 1
    case complete = 2
}

class ViewOrderProgressCell: UITableViewCell {
    
    let circleView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = ThemeManager.Color.placeholder //UIColor(hex: "#DEE4EB")
        return v
    }()
    
    let lineView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = ThemeManager.Color.placeholder // ThemeManager.Color.gray.withAlphaComponent(0.2)
        
        return v
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(24.0)
        l.adjustsFontSizeToFitWidth = true
        
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(16.0)
        l.numberOfLines = 0
        
        return l
    }()
    
    var fillUp: FillUp?
    
    var type: ViewOrderProgressCellType? {
        didSet {
            guard let type = type else { return }
            
            switch type {
            case .scheduled:
                if let fillUp = fillUp, let formattedDate = fillUp.formattedDate {
                    titleLabel.text = "Fill Up Scheduled"
                    messageLabel.text = "Your fillup has been schedule for \(formattedDate)"
                    
                    lineView.isHidden = false
                }
            case .today:
                titleLabel.text = "Tonight's the Night"
                messageLabel.text = "Your fill up will be completed overnight."
                
                lineView.isHidden = false
                
            case .complete:
                titleLabel.text = "Fill Up Complete"
                messageLabel.text = "Your fillup has been completed. AT this point you will be charged the exact amount for the gas."
                
                lineView.isHidden = true
            }
            
            highlightCircles()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(lineView)
        contentView.addSubview(circleView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(circleView.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        circleView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalToSuperview().inset(20)
            make.width.equalToSuperview().multipliedBy(0.05)
            make.height.equalTo(circleView.snp.width)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom)
            make.centerX.equalTo(circleView)
            make.width.equalTo(1)
            make.bottom.equalToSuperview().offset(20)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }
    }
    
    private func highlightCircles() {
        if fillUp?.status == .complete {
            circleView.backgroundColor = ThemeManager.Color.primary
            lineView.backgroundColor = ThemeManager.Color.primary
        } else {
            
            if type == .scheduled {
                circleView.backgroundColor = ThemeManager.Color.primary
            }
            
            if let date = fillUp?.date {
                if Calendar.current.isDateInToday(date) {
                    // Highlight first two circles
                    if type == .scheduled || type == .today {
                        circleView.backgroundColor = ThemeManager.Color.primary
                        lineView.backgroundColor = ThemeManager.Color.primary
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2
    }
}
