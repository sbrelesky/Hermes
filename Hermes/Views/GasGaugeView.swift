//
//  GasGaugeView.swift
//  Hermes
//
//  Created by Shane on 4/25/24.
//

import Foundation
import UIKit
import SnapKit

class GasGaugeView: UIView {
    
    let sliderView: CircularSliderView = {
        let v = CircularSliderView(frame: .zero)
        
        return v
    }()
    
    let gasIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "fuelpump.fill")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = ThemeManager.Color.gray.withAlphaComponent(0.4)
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
        
    var didLayoutSubviews = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = ThemeManager.Color.gray.withAlphaComponent(0.2).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(sliderView)
        addSubview(gasIconImageView)
        
        let topOffset = bounds.width * 0.055
        
        sliderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(sliderView.snp.width)
        }
        
        gasIconImageView.snp.makeConstraints { make in
            make.top.equalTo(sliderView.centerCircle.snp.bottom).offset(topOffset * 2)
            make.centerX.equalToSuperview()
            make.width.equalTo(sliderView.centerCircle)
            make.height.equalTo(gasIconImageView.snp.width)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        
        if !didLayoutSubviews && bounds.width > 0.0 {
            setupViews()
            didLayoutSubviews = true
        }
    }
}
