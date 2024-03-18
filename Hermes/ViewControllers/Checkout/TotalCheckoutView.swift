//
//  TotalCheckoutView.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation
import UIKit
import SnapKit


class TotalCheckoutView: UIView {
    
   
    
    let feeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Fill Up Fee"
        l.textAlignment = .left
        
        return l
    }()
    
    let totalLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Gas Estimate"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    let totalAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        
        return l
    }()
    
    let feeAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        addSubview(feeLabel)
        addSubview(totalLabel)
        
        addSubview(feeAmountLabel)
        addSubview(totalAmountLabel)
        
        feeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(self.snp.centerY)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalLabel)
            make.bottom.equalTo(feeLabel.snp.top)
        }
        
       
        feeAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(feeLabel)
        }
        
        totalAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(totalLabel)
        }
    }
}
