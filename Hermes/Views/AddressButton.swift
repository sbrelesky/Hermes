//
//  AddressButton.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import UIKit
import SnapKit

class AddressButton: UIButton {
    
    let addressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font
        l.textColor = ThemeManager.Color.gray
        l.text = "Address"
        l.textAlignment = .left
        
        return l
    }()
    
    let streetLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Please Add an Address"
        l.textAlignment = .left
        
        return l
    }()
    
    let subAddressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(14.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    let disclosureImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    var address: Address?{
        didSet {
            guard let address = address else { return }
            
            streetLabel.text = address.street
            subAddressLabel.text = "\(address.city), \(address.state) \(address.zip)"
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
        addSubview(addressLabel)
        addSubview(streetLabel)
        addSubview(subAddressLabel)
        addSubview(disclosureImageView)
        
       
        streetLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalToSuperview().offset(20)
        }
        
        subAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(streetLabel.snp.bottom)
            make.leading.equalTo(streetLabel)
            make.trailing.equalToSuperview().inset(60)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(streetLabel.snp.top).offset(-20)
        }
        
        disclosureImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.height.width.equalTo(30)
        }
    }
}
