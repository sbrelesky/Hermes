//
//  CheckZipController.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit

class CheckZipController: UIViewController {
    
    let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.text
        l.numberOfLines = 0
        l.text = "Lets check your zip code to make sure Hermes is currently available in your area."
        
        return l
    }()
    
    let zipTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Zip Code")
        tf.keyboardType = .numberPad
        return tf
    }()
    
    lazy var checkButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Check Location", for: .normal)
        b.addTarget(self, action: #selector(checkZip), for: .touchUpInside)
        
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = "Check Availibility"

        view.backgroundColor = .white
       
        setupForKeyboard()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(descriptionLabel)
        view.addSubview(zipTextField)
        view.addSubview(checkButton)
        
        checkButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.leading.trailing.equalTo(checkButton)
        }
        
        zipTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(80)
            make.leading.trailing.equalTo(checkButton)
            make.height.equalTo(65)
        }
        
        zipTextField.text = "89002"
    }
    
    @objc func checkZip() {
        guard let zip = zipTextField.text, validateZipCode(zip) else { return }        
        if SettingsManager.shared.settings.availableZips.contains(zip) {
            presentSuccess(title: "Woohoo!", message: "We currently operate in your area!") {
                let vc = SignUpController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            let popup = GetNotifiedPopup(areaCode: zip, completion: nil)
            popup.modalPresentationStyle = .overCurrentContext
            popup.modalTransitionStyle = .crossDissolve
            present(popup, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateZipCode(_ zipCode: String) -> Bool {
        let zipCodeRegex = #"^\d{5}(-\d{4})?$"#
        let zipCodePredicate = NSPredicate(format: "SELF MATCHES %@", zipCodeRegex)
        return zipCodePredicate.evaluate(with: zipCode)
    }
}
