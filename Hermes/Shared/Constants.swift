//
//  Constants.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit

struct Constants {
    
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
        static let supportCollection = "Support"
        static let disabledDatesCollection = "Disabled_Dates"
        static let deletedAccounts = "Deleted_Accounts"
        static let notices = "Notices"
        static let promos = "Promotions"
        
        static let carsSubCollection = "Cars"
        static let addressesSubCollection = "Addresses"
        static let chatSubCollection = "Chat"
        static let promosSubCollection = "Promotions"
    }
    
    struct StripeKeys {
        static let testKey = "pk_test_51Or3t9BkajlE0Nzvx2qshqdVtsbBJLiPZmKS5gNQGqvCiBdsfaiH5tRWCsIPijZi7jfEZH66H7QcwM9rxRw5cqLp00MEXfuFQt"
        static let key = "pk_live_51Or3t9BkajlE0NzvIdIdbMNza83gMcg00JfvE9GNydGcpq0WNZp7T3wDSpzIVk4lwKL0qyPibcDUjXgh85Q8u0mO00buxD9cSb"
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
