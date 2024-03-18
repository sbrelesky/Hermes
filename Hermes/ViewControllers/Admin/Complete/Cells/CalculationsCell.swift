//
//  CalculationsCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit
import SnapKit

class CalculationsCell: CompleteFillUpCell, Calculations {
    
    let gasLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(20.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Gas Cost"
        l.textAlignment = .left
        
        return l
    }()
    
    let feeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Processing Fee"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    let totalLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Total"
        l.textAlignment = .left
        
        return l
    }()
    
    let feeAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        
        return l
    }()
    
    let gasAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withSize(20.0)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        
        return l
    }()
    
    let totalAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        
        return l
    }()
    
    var gasCost: Double? {
        didSet {
            guard let gasCost = gasCost else { return }
            
            gasAmountLabel.text = gasCost.formatCurrency()
            
            let processingFee = calculateProcessingFee(cost: gasCost)
            feeAmountLabel.text = processingFee.formatCurrency()
                        
            totalAmountLabel.text = (gasCost + processingFee).formatCurrency()
            
        }
    }
    
    override func setupViews() {
        addSubview(feeLabel)
        addSubview(gasLabel)
        addSubview(totalLabel)
        
        addSubview(feeAmountLabel)
        addSubview(gasAmountLabel)
        addSubview(totalAmountLabel)
        
        
        // Total
        totalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
        }
        
        totalAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(totalLabel)
        }
        
        // Gas
        gasLabel.snp.makeConstraints { make in
            make.bottom.equalTo(totalLabel.snp.top).offset(-10)
            make.leading.equalTo(totalLabel)
        }
        
        gasAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(gasLabel)
            make.trailing.equalTo(totalAmountLabel)
        }
        
        // Fee
        feeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(gasLabel.snp.top)
            make.leading.equalTo(gasLabel)
        }
        
        feeAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(feeLabel)
            make.trailing.equalTo(gasAmountLabel)
        }
    }
}
extension CalculationsCell: CompleteFilUpControllerCalculationsDelegate {
    func setValuesForCost(_ cost: Double) {
        self.gasCost = cost
    }    
}
