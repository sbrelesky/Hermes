//
//  HermesTextField+Picker.swift
//  Hermes
//
//  Created by Shane on 3/1/24.
//

import Foundation
import UIKit
import SnapKit

protocol HermesTextFieldPickerDelegate {
    func selectionChanged(_ textField: HermesTextFieldPicker, selection: Decodable)
}

// Protocol to define objects that provide a 'name' property
protocol NameProviding {
    var name: String { get }
}

class HermesTextFieldPicker: HermesTextField, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let pickerView: UIPickerView = {
        let pv = UIPickerView()
        return pv
    }()
    
    var data: [Decodable] = []
    var row = 0
    
    var selectedData: Decodable {
        return data[row]
    }
    
    var hermesDelegate: HermesTextFieldPickerDelegate?
    
    init(frame: CGRect, data: [Decodable] = []) {
        self.data = data
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        
        print("Bounds: ", bounds.height)
        
        floatingPlaceholderLabel.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(padding.right * 4)
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        inputView = pickerView
        
        // Create a toolbar with a "Done" button
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100.0, height: 44.0))
        toolbar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        print("Adding toolbar... ")
        
        inputAccessoryView = toolbar
        
        addDropdownIcon()
    }
    
    private func addDropdownIcon() {
        let iconView = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = ThemeManager.Color.gray
        
        addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.width.equalTo(iconView.snp.height)
        }
    }
    
    // MARK: - UIPickerViewDelegate and UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let object = data[row] as? NameProviding else {

            if let string = data[row] as? String {
                self.row = row
                text = string
                hermesDelegate?.selectionChanged(self, selection: data[row])
            }
            
            return
        }
        
        self.row = row
        text = object.name
        hermesDelegate?.selectionChanged(self, selection: data[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let object = data[row] as? NameProviding else {
            
            if let string = data[row] as? String {
                return string
            }
            
            return nil
        }
        return object.name
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: - Actions
       
    @objc private func doneButtonTapped() {
        guard !data.isEmpty else {
            resignFirstResponder()
            return
        }
        
        guard let object = data[row] as? NameProviding else {

            if let string = data[row] as? String {
                text = string
                hermesDelegate?.selectionChanged(self, selection: data[row])
                resignFirstResponder()
            }
            
            return
        }

        text = object.name
        hermesDelegate?.selectionChanged(self, selection: data[row])
        resignFirstResponder()
        // _ = delegate?.textFieldShouldReturn?(self)
    }
    
    // MARK: - Public Methods
    
    func updateData(data: [Decodable]) {
        self.data = data
        pickerView.reloadAllComponents()
        row = 0
        // select the first row
    }
    
    func selectData(by name: String) {
        guard let objects = data as? [NameProviding] else {
            
            if let objects = data as? [String],
               let selectedIndex = objects.firstIndex(where: { $0 == name }){
                self.row = selectedIndex
                text = objects[row]
                hermesDelegate?.selectionChanged(self, selection: data[row])
            }
            
            return
        }
        
        if let selectedIndex = objects.firstIndex(where: { $0.name == name }) {
            self.row = selectedIndex
            text = objects[row].name
            hermesDelegate?.selectionChanged(self, selection: data[row])
        }
    }
}
