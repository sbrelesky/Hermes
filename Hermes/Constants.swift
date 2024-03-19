//
//  Constants.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit

struct Constants {
    
    static let availableZips = ["89002", "89011", "89012", "89014", "89015", "89044", "89052", "89074"]
    static let maxFillUpsPerDate: Int = 8
    static let gallonsPerContainer = 14.0
    static let dateCutoffHour = 22 // 10 PM
    
    struct Text {
        static let operatingHours = "12am - 4am"
        static let serviceFee = "$10.00"
        static let checkoutDisclaimer = "Due to varying gas prices, you will be charged for the service fee now and charged for the exact gas amount once the fill up has been completed."
    }
    
    struct FirestoreKeys {
        static let userCollection = "User"
        static let waitListCollection = "Waitlist"
        static let fillUpsCollection = "FillUps"
        static let disabledDatesCollection = "Disabled_Dates"
        static let deletedAccounts = "Deleted_Accounts"
        
        static let carsSubCollection = "Cars"
        static let addressesSubCollection = "Addresses"
    }
    
    struct Padding {
        struct Vertical {
            static var textFieldSpacing = 30.0
            static var bottomSpacing = 40.0
        }
    }
    
    struct Heights {
        static var textField: CGFloat = 65.0
        static var button: CGFloat = 60.0
    }
    
    struct WidthMultipliers {
        static let textField: CGFloat = 0.75
        static let button: CGFloat = 0.85
        static let iconImageView: CGFloat = 0.1
    }
    
    struct UserDefaults {
        static let userFirstLogin = "firstLogin"
        static let messageToken = "messageToken"
    }
    
    struct Fees {
        static let stripePercentageFee = 0.029
        static let stripeBaseFee = 0.3
    }
    
     
}
