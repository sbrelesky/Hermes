//
//  Customer.swift
//  Hermes
//
//  Created by Shane on 3/5/24.
//

import Foundation
import StripePayments

struct Customer: Decodable {
    
    var id: String
    var defaultSource: String?
    
    var paymentMethods: [STPPaymentMethod]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case defaultSource = "default_source"
        case invoiceSettings = "invoice_settings"
    }
    
    // Define the nested structure for invoice_settings
    struct InvoiceSettings: Decodable {
       let defaultPaymentMethod: String?

       // Define CodingKeys enum to map the keys in the JSON response to properties
       enum CodingKeys: String, CodingKey {
           case defaultPaymentMethod = "default_payment_method"
       }
    }

    let invoiceSettings: InvoiceSettings?
}
