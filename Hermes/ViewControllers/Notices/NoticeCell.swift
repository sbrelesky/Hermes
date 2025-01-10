//
//  NoticeCell.swift
//  Hermes
//
//  Created by Shane on 3/20/24.
//

import Foundation
import UIKit
import SnapKit

class NoticeCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.tintColor = ThemeManager.Color.gray
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    var notice: Notice? {
        didSet {
            guard let notice = notice else { return }
            titleLabel.text = notice.title
            messageLabel.text = notice.message
            
            if let imageName = notice.systemImageName {
                imageView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(imageView.snp.width).multipliedBy(0.61)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
    }
    
}
