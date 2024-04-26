//
//  AdminOrderHeader.swift
//  Hermes
//
//  Created by Shane on 4/24/24.
//

import Foundation
import UIKit
import SnapKit

protocol AdminOrderHeaderDelegate: AnyObject {
    func mapPressed(date: Date)
}

class AdminOrderHeader: UIView {
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(24.0)
        label.textColor = ThemeManager.Color.text
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var mapIcon: UIButton = {
        let mapIcon = UIButton(frame: .zero)
        mapIcon.addTarget(self, action: #selector(mapPressed), for: .touchUpInside)
        mapIcon.setImage(UIImage(systemName: "map")?.withRenderingMode(.alwaysTemplate), for: .normal)
        mapIcon.tintColor = ThemeManager.Color.gray
        
        return mapIcon
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            let components = date.get(.day, .year)
            guard let day = components.day, let year = components.year else { return }
            label.text = "\(date.dayOfWeek() ?? ""), \(date.monthName()) \(day), \(year)"
        }
    }
    
    weak var delegate: AdminOrderHeaderDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(mapIcon)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        mapIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
            make.centerY.equalTo(label)
        }
    }
    
    @objc func mapPressed() {
        guard let date = date else { return }
        delegate?.mapPressed(date: date)
    }
    
}
