//
//  ViewOrderTotalCell.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation
import UIKit
import SnapKit


class ViewOrderTotalCell: UITableViewCell {
    
    let feeLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Service Fee"
        l.textAlignment = .left
        
        return l
    }()
    
    let totalLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Total"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    let totalAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(28.0)
        l.textColor = ThemeManager.Color.text
        l.textAlignment = .left
        
        return l
    }()
    
    let feeAmountLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        
        return l
    }()
    
    var fillUp: FillUp? {
        didSet {
            guard let fillUp = fillUp else { return }
            
            if let price = calculatePrice().formatCurrency() {
                totalAmountLabel.text = "\(price)"
            }
            
            if let serviceFee = SettingsManager.shared.settings.serviceFee.formatCurrency() {
                feeAmountLabel.text = "\(serviceFee)"
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        let cancelButtonWidth = bounds.width * 0.85
        let spacing = (bounds.width - cancelButtonWidth) / 2
        
        totalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset((spacing))
            make.bottom.equalToSuperview()
        }
        
        feeLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalLabel)
            make.bottom.equalTo(totalLabel.snp.top)
        }
        
        feeAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(spacing)
            make.centerY.equalTo(feeLabel)
        }
        
        totalAmountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(feeAmountLabel)
            make.centerY.equalTo(totalLabel)
        }
    }
    
    private func calculatePrice() -> Double {
        var price: Double = 0.0

        fillUp?.cars.forEach({ car in
            var gasPrice = switch car.fuel {
                case .regular: SettingsManager.shared.settings.prices.regular
                case .midgrade: SettingsManager.shared.settings.prices.midgrade
                case .premium: SettingsManager.shared.settings.prices.premium
                case .diesel: SettingsManager.shared.settings.prices.diesel
            }
            
            if car.fuelCapacity == 0.0 {
                // Use an average?
                price += 12.3 * gasPrice
            } else {
                price += car.fuelCapacity * gasPrice
            }
        })
        
        price += SettingsManager.shared.settings.serviceFee
    
        return price
    }
}
