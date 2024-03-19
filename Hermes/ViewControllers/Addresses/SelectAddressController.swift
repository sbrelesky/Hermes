//
//  ScheduleController.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit
import SnapKit
import CVCalendar

class SelectAddressController: BaseViewController {
    
    lazy var addressButton: AddressButton = {
        let b = AddressButton(frame: .zero)
        b.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        
        return b
    }()
    
    let emptyDesertView: DesertEmptyView = {
        let v = DesertEmptyView(frame: .zero)
        v.isHidden = true
        
        return v
    }()
    
    
    lazy var scheduleButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Schedule Fill Up", for: .normal)
        b.addTarget(self, action: #selector(schedulePressed), for: .touchUpInside)
        
        return b
    }()
    

    let cars: [Car]
    
    var address: Address? {
        didSet {
            guard let address = address else { return }
            addressButton.address = address
            checkAddress()
        }
    }
    
    init(cars: [Car]) {
        self.cars = cars
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Address"
        
        setupViews()
        
        if let defaultAddress = UserManager.shared.defaultAddress {
            selectedAddress(defaultAddress)
        } else {
            scheduleButton.isEnabled = false
            scheduleButton.layer.opacity = 0.3
        }
    }
    
    private func setupViews() {
        view.addSubview(addressButton)
        view.addSubview(scheduleButton)
        view.addSubview(emptyDesertView)
        
        
        addressButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
                
        // Empty View
        emptyDesertView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
    }
    
    
    @objc func locationButtonPressed() {
        // Consider making this a present over context
        // let vc = UINavigationController(rootViewController: AddressController())
        
        let vc = AddressController {
            self.navigationController?.popViewController(animated: true)
        }
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func checkAddress() {
        guard let address = address else {
            scheduleButton.isEnabled = false
            scheduleButton.layer.opacity = 0.3
            return
        }
        
        let addressIsAvailable = Constants.availableZips.contains(address.zip)
        
        emptyDesertView.isHidden = addressIsAvailable
        // addressButton.isHidden = !addressIsAvailable
        
        scheduleButton.isEnabled = addressIsAvailable ? true : false
        scheduleButton.layer.opacity = addressIsAvailable ? 1.0 : 0.3
    }
    
    @objc func schedulePressed() {
        guard let address = address else { return }
        
        let vc = SelectDateController(cars: cars, address: address)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SelectAddressController: AddressControllerDelegate {
    
    func selectedAddress(_ address: Address) {
        self.address = address
    }
}


