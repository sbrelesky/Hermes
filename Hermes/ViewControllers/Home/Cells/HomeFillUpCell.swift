//
//  HomeFillUpCell.swift
//  Hermes
//
//  Created by Shane on 3/10/24.
//

import Foundation
import UIKit
import SnapKit


class HomeFillUpCell: FillUpCell {
    
    override func configure(cars: [Car]) {
        super.configure(cars: cars)
        
        statusLabel.text = "\(Constants.Text.operatingHours)"
    }
}
