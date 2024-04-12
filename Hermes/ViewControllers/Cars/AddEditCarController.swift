//
//  AddEditCarController.swift
//  Hermes
//
//  Created by Shane on 3/1/24.
//

import Foundation
import UIKit
import SnapKit

class AddEditCarController: UIViewController, TextFieldValidation {
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.layer.cornerRadius = 40
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sv.layer.masksToBounds = true
        return sv
    }()
    
    let makeTextField: HermesTextFieldPicker = {
        let tf = HermesTextFieldPicker(frame: .zero)
        tf.setPlaceholder("Make")
        
        return tf
    }()
    
    let modelTextField: HermesTextFieldPicker = {
        let tf = HermesTextFieldPicker(frame: .zero)
        tf.setPlaceholder("Model")
        tf.keyboardType = .emailAddress
        
        return tf
    }()
    
    
    let yearTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Year")
        tf.keyboardType = .phonePad
        
        return tf
    }()
    
    let licenseTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("License Plate #")
        
        return tf
    }()
    
    let gasTypeTextField: HermesTextFieldPicker = {
        let tf = HermesTextFieldPicker(frame: .zero, data: [
            FuelType.regular.rawValue.capitalized,
            FuelType.midgrade.rawValue.capitalized,
            FuelType.premium.rawValue.capitalized,
            FuelType.diesel.rawValue.capitalized,
        ])
        tf.setPlaceholder("Gas Type")
        
        return tf
    }()
    
    let gasCapUnlockTextField: HermesTextFieldPicker = {
        let tf = HermesTextFieldPicker(frame: .zero, data: ["Yes", "No"])
        tf.setPlaceholder("Gas Cap Unlock Needed?")
        
        return tf
    }()
    
    lazy var addEditButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.addTarget(self, action: #selector(addEditPressed), for: .touchUpInside)
        
        return b
    }()
    
    
    // MARK: - Properties
    
    private enum Mode: String {
        case edit
        case add
    }
    
    private var mode: Mode
    private var car: Car?

    // MARK: - Init Methods
    
    init(car: Car?) {
        self.mode = car != nil ? .edit : .add
        self.car = car
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(mode.rawValue.capitalized) Car"
        view.backgroundColor = UIColor(hex: "#F0F0F0")
        
        setupForKeyboard()
        setupViews()
        
        addEditButton.setTitle(mode == .add ? "Add Car" : "Save Car", for: .normal)

        let fetchMakes: (LoadingPopup?) -> Void = { popup in
            
            CarApiManager.shared.fetchMakes { result in
                switch result {
                case .success(let makes):
                    DispatchQueue.main.async {
                        self.makeTextField.updateData(data: makes)
                        self.setCarValues()
                    }
                case .failure(let error):
                    self.presentError(error: error)
                }
                
                DispatchQueue.main.async {
                    popup?.dismissPopup()
                }
            }
        }
        
        if mode == .edit {
            presentLoading(message: "Loading data...") { popup in
                fetchMakes(popup)
            }
        } else {
            fetchMakes(nil)
        }
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        
        // Add constraints for the scroll view
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(yearTextField)
        scrollView.addSubview(makeTextField)
        scrollView.addSubview(modelTextField)
        
        scrollView.addSubview(licenseTextField)
        scrollView.addSubview(gasTypeTextField)
        scrollView.addSubview(gasCapUnlockTextField)
        scrollView.addSubview(addEditButton)
        
        makeTextField.hermesDelegate = self
        
        yearTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        makeTextField.snp.makeConstraints { make in
            make.top.equalTo(yearTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.height.width.equalTo(yearTextField)
        }
        
        modelTextField.snp.makeConstraints { make in
            make.top.equalTo(makeTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.height.width.equalTo(makeTextField)
        }
                
        licenseTextField.snp.makeConstraints { make in
            make.top.equalTo(modelTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.height.width.equalTo(makeTextField)
        }
        
        gasTypeTextField.snp.makeConstraints { make in
            make.top.equalTo(licenseTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.height.width.equalTo(makeTextField)
        }
        
        gasCapUnlockTextField.snp.makeConstraints { make in
            make.top.equalTo(gasTypeTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.centerX.height.width.equalTo(makeTextField)
        }
        
        addEditButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(gasCapUnlockTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }        
    }
    
    private func setCarValues() {
        guard let car = car else { return }
        
        makeTextField.selectData(by: car.make)
        yearTextField.text = car.year
        licenseTextField.text = car.license
        gasTypeTextField.selectData(by: car.fuel.rawValue.capitalized)
        gasCapUnlockTextField.selectData(by: car.gasCapUnlockNeeded)
    }
    
    
    @objc func addEditPressed() {
        
        guard let make = makeTextField.selectedData as? CarMake, validateNonNilEmptyString(makeTextField.text) else {
            makeTextField.showError()
            return
        }
        
        guard let model = modelTextField.selectedData as? CarModel, validateNonNilEmptyString(modelTextField.text) else {
            modelTextField.showError()
            return
        }
        
        guard let year = yearTextField.text, validateNonNilEmptyString(year) else {
            yearTextField.showError()
            return
        }
        
        guard let license = licenseTextField.text, validateNonNilEmptyString(license) else {
            licenseTextField.showError()
            return
        }
        
        guard let gasType = gasTypeTextField.text, validateNonNilEmptyString(gasType) else {
            gasTypeTextField.showError()
            return
        }
        
        guard let gasUnlock = gasCapUnlockTextField.text, validateNonNilEmptyString(gasUnlock) else {
            gasCapUnlockTextField.showError()
            return
        }
        
        guard let fuelType = FuelType(rawValue: gasType.lowercased()) else { return }
        
        addEditButton.setLoading(true)
        
        CarApiManager.shared.fetchFuelCapacity(model: model, year: year) { result in
            
            self.addEditButton.setLoading(false)
            
            switch result {
            case .success(let mileage):
                print("Successfully fetched milage for model: \(model.name)")
                print(mileage)
                guard let fuelCapacity = (mileage.first?.fuelCapacity as? NSString)?.doubleValue else { return }
                
                if self.mode == .add {
                    self.car = Car(make: make.name, model: model.name, year: year, license: license, fuel: fuelType, fuelCapacity: fuelCapacity, gasCapUnlockNeeded: gasUnlock)
                } else {
                    self.car?.make = make.name
                    self.car?.model = model.name
                    self.car?.year = year
                    self.car?.license = license
                    self.car?.fuel = fuelType
                    self.car?.fuelCapacity = fuelCapacity
                    self.car?.gasCapUnlockNeeded = gasUnlock
                }
                
                self.saveCar()

            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            }
        }
    }
    
    private func fetchModelsForMake(completion: ((Bool) -> Void)? = nil) {
        guard let make = makeTextField.selectedData as? CarMake, let year = yearTextField.text else { return }
        
        
        print("Running fetch models for make...")
        
        CarApiManager.shared.fetchModelForMake(make.name, year: year) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    self.modelTextField.text = nil
                    self.modelTextField.updateData(data: models)
                    completion?(true)
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
                
                completion?(false)
            }
        }
    }
    
    private func saveCar() {
        guard let car = car else { return }
        UserManager.shared.saveCar(car) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            } else {
                print("Successfully saved car")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension AddEditCarController: HermesTextFieldPickerDelegate {
    
    func selectionChanged(_ textField: HermesTextFieldPicker, selection: Decodable) {
        
        if textField == makeTextField {
            guard let make = selection as? CarMake else { return }
            print("Load models for make: \(make.name)")
            self.fetchModelsForMake { success in
             
                if success {
                    if self.mode == .edit && self.car?.make == make.name && !self.validateNonNilEmptyString(self.modelTextField.text) {
                        // Set the model text
                        guard let model = self.car?.model else { return }
                        self.modelTextField.selectData(by: model)
                    }
                }
            }
        }
    }
}



