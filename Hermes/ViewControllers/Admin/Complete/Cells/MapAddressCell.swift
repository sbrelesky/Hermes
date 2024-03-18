//
//  MapAddressCell.swift
//  Hermes
//
//  Created by Shane on 3/15/24.
//

import Foundation
import UIKit
import SnapKit
import MapKit

class MapAddressCell: CompleteFillUpCell {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.mapType = .mutedStandard
        mv.backgroundColor = .blue
        mv.showsUserLocation = true
        mv.layer.cornerRadius = 20
        mv.clipsToBounds = true
        mv.showsUserLocation = true
        
        return mv
    }()
    
    
    let addressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let subAddressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(14.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    var fillUp: FillUp? {
        didSet {
            guard let fillUp = fillUp else { return }
            
            addressLabel.text = fillUp.address.street
            subAddressLabel.text = "\(fillUp.address.city), \(fillUp.address.state) \(fillUp.address.zip)"
            
            fillUp.address.convertToPlacemark { placemark in
                guard let placemark = placemark else { return }
                self.setMapLocation(placemark: placemark)
            }
        }
    }
    
    override func setupViews() {
        contentView.addSubview(mapView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(subAddressLabel)
        
        
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        
        mapView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0)
            make.height.equalTo(mapView.snp.width).multipliedBy(0.5)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.equalTo(mapView).offset(20)
        }
        
        subAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom)
            make.leading.equalTo(addressLabel)
        }
    }
    
    private func setMapLocation(placemark: CLPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.location!.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
   
}


extension MapAddressCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }


        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        
        view.canShowCallout = true
        view.markerTintColor = ThemeManager.Color.gray
            
       view.image = UIImage(systemName: "mappin")
        
        return view
    }
}
