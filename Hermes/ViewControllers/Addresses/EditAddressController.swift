//
//  EditAddressController.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit
import SnapKit
import MapKit

class EditAddressController: BaseViewController, TextFieldValidation {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.mapType = .mutedStandard
        mv.backgroundColor = .blue
        mv.showsUserLocation = true
        mv.layer.cornerRadius = 20
        mv.clipsToBounds = true
        
        return mv
    }()
    
    let addressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let subAddressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(14.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let apartmentTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Apt/Suite")
        
        return tf
    }()
    
    let entryCodeTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Entry Code")
        
        return tf
    }()
    
    let buildingNameTextField: HermesTextField = {
        let tf = HermesTextField(frame: .zero)
        tf.setPlaceholder("Building Name")
        
        return tf
    }()
    
    lazy var saveAddressButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Save Address", for: .normal)
        b.addTarget(self, action: #selector(saveAddressPressed), for: .touchUpInside)
        
        return b
    }()

    let location: Location
    
    init(location: Location) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Address"
        
        setupForKeyboard()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(addressLabel)
        view.addSubview(subAddressLabel)
        view.addSubview(apartmentTextField)
        view.addSubview(entryCodeTextField)
        view.addSubview(buildingNameTextField)
        view.addSubview(saveAddressButton)
        
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.equalTo(mapView)
        }
        
        subAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom)
            make.leading.equalTo(mapView)
        }
        
        let line = UIView()
        line.backgroundColor = ThemeManager.Color.gray.withAlphaComponent(0.3)
        
        view.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.leading.equalTo(subAddressLabel)
            make.top.equalTo(subAddressLabel.snp.bottom).offset(20)
            make.trailing.equalTo(mapView)
            make.height.equalTo(1)
        }
        
        apartmentTextField.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(mapView)
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        entryCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(apartmentTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(mapView)
            make.height.width.equalTo(apartmentTextField)
        }
        
        buildingNameTextField.snp.makeConstraints { make in
            make.top.equalTo(entryCodeTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            make.leading.equalTo(mapView)
            make.height.width.equalTo(apartmentTextField)
        }
        
        saveAddressButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.centerX.equalToSuperview()
        }
        
        setTextFieldValues()
        
        // Set the map location
        guard let placemark = location.placemark else {
            location.address.convertToPlacemark { placemark in
                guard let placemark = placemark else { return }
                self.setMapLocation(placemark: placemark)
            }
            
            return
        }
        
        setMapLocation(placemark: placemark)
    }
    
        
    
    // MARK: - Targets
    
    @objc private func saveAddressPressed() {
        print("Save Address")
        
        var address = location.address
        
        if let apt = apartmentTextField.text, validateNonNilEmptyString(apt) {
            address.apartment = apt
        }
        
        if let entryCode = entryCodeTextField.text, validateNonNilEmptyString(entryCode) {
            address.entryCode = entryCode
        }
        
        if let building = buildingNameTextField.text, validateNonNilEmptyString(building) {
            address.building = building
        }
        
        saveAddressButton.setLoading(true)
        
        UserManager.shared.saveAddress(address) { error in
            
            DispatchQueue.main.async {
                self.saveAddressButton.setLoading(false)

                if let error = error {
                    self.presentError(error: error)
                } else {
                    // Pop back to address screen
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Helpers

    private func setTextFieldValues() {
        addressLabel.text = location.address.street
        subAddressLabel.text = "\(location.address.city), \(location.address.state) \(location.address.zip)"
        
        apartmentTextField.text = location.address.apartment
        entryCodeTextField.text = location.address.entryCode
        buildingNameTextField.text = location.address.building
    }
    
    private func setMapLocation(placemark: CLPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.location!.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension EditAddressController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }


        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        
        view.canShowCallout = true
        view.markerTintColor = ThemeManager.Color.gray
            
       view.image = UIImage(systemName: "mappin")
        
        return view
    }
}

