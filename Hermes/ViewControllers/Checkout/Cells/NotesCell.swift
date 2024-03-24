//
//  NotesCell.swift
//  Hermes
//
//  Created by Shane on 3/24/24.
//

import UIKit
import SnapKit

class NotesCell: UITableViewCell {
    
    
    let label: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Additional Notes"
        l.textAlignment = .left
        
        return l
    }()
    
    let textView: UITextView = {
        let l = UITextView()
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(16.0)
        l.textColor = ThemeManager.Color.text
        l.tintColor = ThemeManager.Color.text
        l.textAlignment = .left
        l.layer.cornerRadius = 5
        l.layer.borderColor = ThemeManager.Color.placeholder.cgColor
        l.layer.borderWidth = 1.25
        
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(label)
        contentView.addSubview(textView)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
}
