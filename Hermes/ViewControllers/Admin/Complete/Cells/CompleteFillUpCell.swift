//
//  CompleteFillUpCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit

// Map Cell & Address
class CompleteFillUpCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {}
}

