//
//  TextFieldValidation.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation


protocol TextFieldValidation: AnyObject {
    func validateNonNilEmptyString(_ text: String?) -> Bool
    func getTextFieldValue<T>(_ textField: HermesTextField) -> T? where T: LosslessStringConvertible
}

extension TextFieldValidation {
    func validateNonNilEmptyString(_ text: String?) -> Bool {
        return (text != nil && text != "")
    }
    
    
    func getTextFieldValue<T>(_ textField: HermesTextField) -> T? where T: LosslessStringConvertible {
        guard validateNonNilEmptyString(textField.text), let value = textField.text, let returnValue = T(value) else {
            textField.showError()
            return nil
        }
        
        return returnValue
    }
}
