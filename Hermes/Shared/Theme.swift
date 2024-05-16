//
//  Theme.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit


struct ThemeManager {
    
    struct Color {
        static let gray = UIColor(hex: "#8DA1B9")
        static let placeholder = UIColor(hex: "#C8D1DC")
        static let text = UIColor(hex: "#274653")
        static let red = UIColor(hex: "#D92E48")
        static let yellow = UIColor(hex: "#eeb422")
        static let textFieldBackground = UIColor(hex: "#F7F7F7")
        static let green = UIColor(hex: "#21A0A0")
        
        static let primary = ThemeManager.Color.yellow
    }
    
    struct Font {
        
// Usage Examples
        
// let mainFont = Font.Style.main.font // Default size
// let secondaryFont = Font.Style.secondary(weight: .bold).font // Default size
// let customSizeFont = Font.Style.main.font.withDynamicSize(20) // Custom size
        
        static let defaultFontSize: CGFloat = 16
        static let placeholderFontSize: CGFloat = 33.0
        
        static let mainFontName = "BebasKai"
        static let secondaryFontName = "AvenirNext"
        
        enum Style {
            case main
            case secondary(weight: SecondaryFontWeight)

            var fontName: String {
                switch self {
                case .main:
                    return mainFontName
                case .secondary:
                    return secondaryFontName
                }
            }

            var defaultSize: CGFloat {
                return Font.defaultFontSize
            }

            var font: UIFont {
                switch self {
                case .main:
                    return UIFont(name: fontName, size: defaultSize) ?? .systemFont(ofSize: defaultSize)
                case .secondary(let weight):
                    let weightName: String
                    switch weight {
                    case .light: weightName = "-Light"
                    case .regular: weightName = "-Regular"
                    case .medium: weightName = "-Medium"
                    case .demiBold: weightName = "-DemiBold"
                    case .bold: weightName = "-Bold"
                    case .heavy: weightName = "-Heavy"
                    }
                    return UIFont(name: fontName + weightName, size: defaultSize) ?? .systemFont(ofSize: defaultSize)
                }
            }
        }
        
        enum SecondaryFontWeight {
            case light
            case regular
            case medium
            case demiBold
            case bold
            case heavy
        }
    }
}

extension UIFont {
    func withDynamicSize(_ fontSize: CGFloat) -> UIFont {
        guard let screenHeight = UIScreen.current?.bounds.height else {
            return withSize(fontSize)
        }
        
        let min = fontSize - (fontSize * 0.25)
        let adjustedSize = max(screenHeight * 0.00118 * fontSize, min)
        return withSize(adjustedSize)
    }
}
