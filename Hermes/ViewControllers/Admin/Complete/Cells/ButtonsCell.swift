//
//  ButtonsCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit
import SnapKit

protocol ButtonCellDelegate: AnyObject {
    func calculate()
    func chargeCustomer(button: HermesLoadingButton)
}

class ButtonsCell: CompleteFillUpCell {
    
    lazy var calculateButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Calculate", for: .normal)
        b.addTarget(self, action: #selector(calculatePressed), for: .touchUpInside)
        b.backgroundColor = ThemeManager.Color.yellow.withAlphaComponent(0.1)
        b.setTitleColor(ThemeManager.Color.yellow, for: .normal)
        b.layer.borderWidth = 1
        b.layer.borderColor = ThemeManager.Color.yellow.cgColor
        
        return b
    }()
    
    lazy var chargeCustomerButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Charge Customer", for: .normal)
        b.addTarget(self, action: #selector(chargeCustomerPressed), for: .touchUpInside)
        b.backgroundColor = ThemeManager.Color.green
        
        return b
    }()
    
    weak var delegate: ButtonCellDelegate?
    
    override func setupViews() {
        
        contentView.addSubview(calculateButton)
        contentView.addSubview(chargeCustomerButton)
                
        chargeCustomerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        calculateButton.snp.makeConstraints { make in
            make.bottom.equalTo(chargeCustomerButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Button Targets
    
    @objc func calculatePressed() {
        
        delegate?.calculate()
    
    }
    
    @objc func chargeCustomerPressed() {
        delegate?.chargeCustomer(button: chargeCustomerButton)
        // processPayment(amount: totalInCents)
    }
}
