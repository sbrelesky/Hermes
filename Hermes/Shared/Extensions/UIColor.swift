//
//  UIColor.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit


extension UIColor {
    public convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func darken(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = brightness - (brightness * percentage)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        
        return self
    }
    
    func lighten(by percentage: CGFloat)  -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = brightness + (brightness * percentage)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        
        return self
    }
}

extension UITableViewCell {
    var cellActionButtonLabels: [UILabel]? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }
    }
}
