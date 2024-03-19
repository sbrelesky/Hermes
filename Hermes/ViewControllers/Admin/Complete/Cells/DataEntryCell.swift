//
//  DataEntryCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit
import SnapKit


struct GasCalculationValues {
    var numberOfFullContainers: Double
    var pricePerGallon: Double
    var leftoverGallons: Double // This should be equal to number of gallons per container?
    var leftoverContainerStartWeight: Double
    var leftoverContainerEndWeight: Double
}

class DataEntryCell: CompleteFillUpCell, TextFieldValidation {
    
    let fullContainersUsedTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("# Of Full Containers")
        tf.keyboardType = .numberPad
        
        return tf
    }()
    
    let pricePerGallonTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("$ Per Gallon")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    let leftoverGallonsStartTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Leftover # Of Gallons")
        tf.keyboardType = .numberPad
        
        return tf
    }()
    
    let leftoverStartWeightTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Leftover Start Weight")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    let leftoverEndWeightTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Leftover End Weight")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    
    override func setupViews() {
        contentView.addSubview(fullContainersUsedTextField)
        contentView.addSubview(pricePerGallonTextField)
        
        contentView.addSubview(leftoverGallonsStartTextField)
        contentView.addSubview(leftoverStartWeightTextField)
        contentView.addSubview(leftoverEndWeightTextField)
        
        fullContainersUsedTextField.delegate = self
        pricePerGallonTextField.delegate = self
        leftoverGallonsStartTextField.delegate = self
        leftoverStartWeightTextField.delegate = self
        leftoverEndWeightTextField.delegate = self
        
        
        fullContainersUsedTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        pricePerGallonTextField.snp.makeConstraints { make in
            make.top.equalTo(fullContainersUsedTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(fullContainersUsedTextField)
            make.height.width.equalTo(fullContainersUsedTextField)
        }
                
        leftoverGallonsStartTextField.snp.makeConstraints { make in
            make.top.equalTo(pricePerGallonTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(fullContainersUsedTextField)
            make.height.width.equalTo(fullContainersUsedTextField)
        }
        
        leftoverStartWeightTextField.snp.makeConstraints { make in
            make.top.equalTo(leftoverGallonsStartTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(fullContainersUsedTextField)
            make.height.width.equalTo(fullContainersUsedTextField)
        }
        
        leftoverEndWeightTextField.snp.makeConstraints { make in
            make.top.equalTo(leftoverStartWeightTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(fullContainersUsedTextField)
            make.height.width.equalTo(fullContainersUsedTextField)
        }
    }
   
    private func getValues() -> GasCalculationValues? {
        guard validateNonNilEmptyString(fullContainersUsedTextField.text), let fullContainersUsed = Double(fullContainersUsedTextField.text ?? "0")  else {
            fullContainersUsedTextField.showError()
            return nil
        }
        
        guard validateNonNilEmptyString(pricePerGallonTextField.text), let pricePerGallon = Double(pricePerGallonTextField.text ?? "0") else {
            pricePerGallonTextField.showError()
            return nil
        }
        
        guard validateNonNilEmptyString(leftoverGallonsStartTextField.text), let leftoverGallonsStart = Double(leftoverGallonsStartTextField.text ?? "0") else {
            leftoverGallonsStartTextField.showError()
            return nil
        }
        
        guard validateNonNilEmptyString(leftoverStartWeightTextField.text), let leftoverGallonsStartWeight = Double(leftoverStartWeightTextField.text ?? "0")  else {
            leftoverStartWeightTextField.showError()
            return nil
        }
        
        guard validateNonNilEmptyString(leftoverEndWeightTextField.text), let leftoverGallonsEndWeight = Double(leftoverEndWeightTextField.text ?? "0") else {
            leftoverEndWeightTextField.showError()
            return nil
        }
        
        return GasCalculationValues(numberOfFullContainers: fullContainersUsed, pricePerGallon: pricePerGallon, leftoverGallons: leftoverGallonsStart, leftoverContainerStartWeight: leftoverGallonsStartWeight, leftoverContainerEndWeight: leftoverGallonsEndWeight)
    }
}

extension DataEntryCell: CompleteFilUpControllerDataEntryDelegate {
   
    func getGasCalculationValues() -> GasCalculationValues? {
        return getValues()
    }
}

extension DataEntryCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullContainersUsedTextField {
            pricePerGallonTextField.becomeFirstResponder()
        } else if textField == pricePerGallonTextField {
            leftoverGallonsStartTextField.becomeFirstResponder()
        } else if textField == leftoverGallonsStartTextField {
            leftoverStartWeightTextField.becomeFirstResponder()
        } else if textField == leftoverStartWeightTextField {
            leftoverEndWeightTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // calculatePressed()
    }
}
