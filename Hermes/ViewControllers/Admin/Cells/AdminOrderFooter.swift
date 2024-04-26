//
//  AdminOrderFooter.swift
//  Hermes
//
//  Created by Shane on 4/24/24.
//

import Foundation
import UIKit
import SnapKit

class AdminOrderFooter: UIView {
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(20.0)
        label.textColor = ThemeManager.Color.gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.text = "Daily Totals"
        
        return label
    }()
    
    let regularGasView: AdminOrderFooterGasView = {
        let v = AdminOrderFooterGasView(frame: .zero)
        v.gasLabel.text = "Regular - "
        v.maxLabel.text = "Max"
        v.estimateLabel.text = "Estimate"
        
        return v
    }()
    
    let midGasView: AdminOrderFooterGasView = {
        let v = AdminOrderFooterGasView(frame: .zero)
        v.gasLabel.text = "Midgrade - "
        v.maxLabel.text = "Max"
        v.estimateLabel.text = "Estimate"
        
        return v
    }()
    
    let premiumGasView: AdminOrderFooterGasView = {
        let v = AdminOrderFooterGasView(frame: .zero)
        v.gasLabel.text = "Premium - "
        v.maxLabel.text = "Max"
        v.estimateLabel.text = "Estimate"
        
        return v
    }()
    
    let dieselGasView: AdminOrderFooterGasView = {
        let v = AdminOrderFooterGasView(frame: .zero)
        v.gasLabel.text = "Diesel - "
        v.maxLabel.text = "Max"
        v.estimateLabel.text = "Estimate"
        
        return v
    }()
    
    let priceGasView: AdminOrderFooterGasView = {
        let v = AdminOrderFooterGasView(frame: .zero)
        v.gasLabel.text = "Price - "
        v.maxLabel.text = "Max"
        v.estimateLabel.text = "Estimate"
        
        return v
    }()
    
    var order: Order? {
        didSet {
            calculateSummary()
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
        addSubview(label)
        addSubview(regularGasView)
        addSubview(midGasView)
        addSubview(premiumGasView)
        addSubview(dieselGasView)
        addSubview(priceGasView)
        
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
        }
        
        regularGasView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.equalTo(label)
            make.trailing.equalToSuperview()
        }
        
        midGasView.snp.makeConstraints { make in
            make.top.equalTo(regularGasView.snp.bottom)
            make.leading.equalTo(label)
            make.trailing.equalToSuperview()
        }
        
        premiumGasView.snp.makeConstraints { make in
            make.top.equalTo(midGasView.snp.bottom)
            make.leading.equalTo(label)
            make.trailing.equalToSuperview()
        }
        
        dieselGasView.snp.makeConstraints { make in
            make.top.equalTo(premiumGasView.snp.bottom)
            make.leading.equalTo(label)
            make.trailing.equalToSuperview()
        }
        
        priceGasView.snp.makeConstraints { make in
            make.top.equalTo(dieselGasView.snp.bottom)
            make.leading.equalTo(label)
            make.trailing.equalToSuperview()
        }
    }
    
    
    private func calculateSummary() {
        let regularCars = ordersByFuelType(.regular)
        let midCars = ordersByFuelType(.midgrade)
        let premiumCars = ordersByFuelType(.premium)
        let dieselCars = ordersByFuelType(.diesel)
        
        let regularMaxGasAmount = calculateMaxGasForCarsByFuelType(regularCars, fuelType: .regular).rounded(toPlaces: 2)
        let midMaxGasAmount = calculateMaxGasForCarsByFuelType(midCars, fuelType: .midgrade).rounded(toPlaces: 2)
        let premiumMaxGasAmount = calculateMaxGasForCarsByFuelType(premiumCars, fuelType: .premium).rounded(toPlaces: 2)
        let dieselMaxGasAmount =  calculateMaxGasForCarsByFuelType(dieselCars, fuelType: .diesel).rounded(toPlaces: 2)

        let reglarGasNeededEstimate = calculateEstimatedGasForCarsByFuelType(regularCars, fuelType: .regular).rounded(toPlaces: 2)
        let midGasNeededEstimate = calculateEstimatedGasForCarsByFuelType(midCars, fuelType: .midgrade).rounded(toPlaces: 2)
        let premiumGasNeededEstimate = calculateEstimatedGasForCarsByFuelType(premiumCars, fuelType: .premium).rounded(toPlaces: 2)
        let dieselGasNeededEstimate = calculateEstimatedGasForCarsByFuelType(dieselCars, fuelType: .diesel).rounded(toPlaces: 2)

            
        if regularMaxGasAmount != 0 {
            regularGasView.maxLabel.text = "Max: \(regularMaxGasAmount)g"
            regularGasView.estimateLabel.text = "Estimated: \(reglarGasNeededEstimate)g"
        } else {
            regularGasView.maxLabel.isHidden = true
            regularGasView.estimateLabel.isHidden = true
        }
        
        if midMaxGasAmount != 0 {
            midGasView.maxLabel.text = "Max: \(midMaxGasAmount)g"
            midGasView.estimateLabel.text = "Estimated: \(midGasNeededEstimate)g"
        } else {
            midGasView.maxLabel.isHidden = true
            midGasView.estimateLabel.isHidden = true
        }
        
        if premiumMaxGasAmount != 0 {
            premiumGasView.maxLabel.text = "Max: \(premiumMaxGasAmount)g"
            premiumGasView.estimateLabel.text = "Estimated: \(premiumGasNeededEstimate)g"
        } else {
            premiumGasView.maxLabel.isHidden = true
            premiumGasView.estimateLabel.isHidden = true
        }
        
        if dieselMaxGasAmount != 0 {
            dieselGasView.maxLabel.text = "Max: \(dieselMaxGasAmount)g"
            dieselGasView.estimateLabel.text = "Estimated: \(dieselGasNeededEstimate)g"
        } else {
            dieselGasView.maxLabel.isHidden = true
            dieselGasView.estimateLabel.isHidden = true
        }
        
        // Calculate Prices
        
        var totalMaxPrice: CGFloat = 0.0
        var totalEstPrice: CGFloat = 0.0
        
        // Regular
        let regularGasPrice = SettingsManager.shared.settings.prices.regular
        totalMaxPrice += regularMaxGasAmount * regularGasPrice
        totalEstPrice += reglarGasNeededEstimate * regularGasPrice
        
        // Midgrade
        let midGasPrice = SettingsManager.shared.settings.prices.midgrade
        totalMaxPrice += midMaxGasAmount * midGasPrice
        totalEstPrice += midGasNeededEstimate * midGasPrice
        
        // Premium
        let premiumGasPrice = SettingsManager.shared.settings.prices.premium
        totalMaxPrice += premiumMaxGasAmount * premiumGasPrice
        totalEstPrice += premiumGasNeededEstimate * premiumGasPrice
        
        // Diesel
        let dieselGasPrice = SettingsManager.shared.settings.prices.diesel
        totalMaxPrice += dieselMaxGasAmount * dieselGasPrice
        totalEstPrice += dieselGasNeededEstimate * dieselGasPrice
        
        if totalMaxPrice != 0.0 {
            self.priceGasView.maxLabel.text = "Max: $\(totalMaxPrice.rounded(toPlaces: 2))"
            self.priceGasView.estimateLabel.text = "Est: $\(totalEstPrice.rounded(toPlaces: 2))"
        } else {
            self.priceGasView.maxLabel.isHidden = true
            self.priceGasView.estimateLabel.isHidden = true
        }
        
    }
    
   
    
    private func ordersByFuelType(_ fuelType: FuelType) -> [Car] {
        return order?.fillUps.flatMap({ $0.cars }).filter({ $0.fuel == fuelType }) ?? []
    }
    
    private func calculateMaxGasForCarsByFuelType(_ cars: [Car], fuelType: FuelType) -> CGFloat {
        return cars.reduce(0) { $0 + $1.fuelCapacity }
    }
    
    private func calculateEstimatedGasForCarsByFuelType(_ cars: [Car], fuelType: FuelType) -> CGFloat {
        
        var gasNeeded = 0.0
        cars.forEach { car in
            let estimatedGasLeft = car.gasEstimate ?? 0.0
            gasNeeded += car.fuelCapacity * (1.0 - estimatedGasLeft)
        }
        
        return gasNeeded
    }
    
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsic content size based on the labels' heights
        var totalHeight = label.bounds.height + 16 // Account for spacing
        
        if !regularGasView.isHidden {
            totalHeight += regularGasView.bounds.height
        }
        
        if !midGasView.isHidden {
            totalHeight += midGasView.bounds.height
        }
        
        if !premiumGasView.isHidden {
            totalHeight += premiumGasView.bounds.height
        }
        
        if !dieselGasView.isHidden {
            totalHeight += dieselGasView.bounds.height
        }
        
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}


class AdminOrderFooterGasView: UIView {
    
    let gasLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(16.0)
        label.textColor = ThemeManager.Color.gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.text = ""
        
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(14.0)
        label.textColor = ThemeManager.Color.gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = ""
        
        return label
    }()
    
    let estimateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(14.0)
        label.textColor = ThemeManager.Color.gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = ""
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        addSubview(gasLabel)
        addSubview(maxLabel)
        addSubview(estimateLabel)
        
        gasLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        estimateLabel.snp.makeConstraints { make in
            make.top.equalTo(gasLabel)
            make.trailing.equalToSuperview()
        }
        
        maxLabel.snp.makeConstraints { make in
            make.top.equalTo(gasLabel)
            make.trailing.equalTo(estimateLabel.snp.leading).offset(-5)
        }
    }
        
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsic content size based on the labels' heights
        var totalHeight = gasLabel.bounds.height + 16 // Account for spacing
        
        if maxLabel.text == "0.0 g" {
            totalHeight = 0
        }
        
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}
