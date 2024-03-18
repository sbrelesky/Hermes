//
//  AddressSavedCell.swift
//  Hermes
//
//  Created by Shane on 3/3/24.
//

import Foundation
import UIKit
import SnapKit



protocol AddressCellDelegate: AnyObject {
    func editPressed(address: Address?)
}

class AddressCell: UITableViewCell {
    
    let placemarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "placemark")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = ThemeManager.Color.gray
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let streetLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
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
    
    var address: Address?{
        didSet {
            guard let address = address else { return }
            
            streetLabel.text = address.street
            subAddressLabel.text = "\(address.city), \(address.state) \(address.zip)"
            
            if address.isDefault {
                placemarkImageView.tintColor = ThemeManager.Color.yellow
            } else {
                placemarkImageView.tintColor = ThemeManager.Color.gray
            }
        }
    }
    weak var delegate: AddressCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        setupViews()
        setupAccessory()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        addSubview(placemarkImageView)
        addSubview(streetLabel)
        addSubview(subAddressLabel)
        
        placemarkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(self.snp.centerY)
            make.width.height.equalTo(20)
        }
        
        streetLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.centerY)
            make.leading.equalTo(placemarkImageView.snp.trailing).offset(20)
        }
        
        subAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(streetLabel.snp.bottom)
            make.leading.equalTo(streetLabel)
            make.trailing.equalToSuperview().inset(60)
        }
    }
    
    func setupAccessory() {
//        let editButton = UIButton()
//        editButton.setImage(UIImage(systemName: "pencil.circle")?.withRenderingMode(.alwaysTemplate).applyingSymbolConfiguration(.init(pointSize: 30.0)), for: .normal)
//        editButton.imageView?.tintColor = ThemeManager.Color.gray
//        editButton.imageView?.contentMode = .scaleAspectFill
//        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
//
//        contentView.addSubview(editButton)
//        
//        editButton.snp.makeConstraints { make in
//            make.width.height.equalTo(30)
//            make.centerY.equalToSuperview()
//            make.trailing.equalToSuperview().inset(20)
//        }
    }

    @objc func editPressed() {
        print("Edit Pressed")
        delegate?.editPressed(address: address)
    }
    
    
    private func setDefaultSwipeActionLabelColor() {
        
        if let actionLabels = cellActionButtonLabels, actionLabels.count == 3 {
            let secondSwipeAction = actionLabels[1]
            secondSwipeAction.textColor = ThemeManager.Color.text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setDefaultSwipeActionLabelColor()
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        setDefaultSwipeActionLabelColor()
    }
}
