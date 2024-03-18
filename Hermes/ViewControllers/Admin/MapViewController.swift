//
//  File.swift
//  Hermes
//
//  Created by Shane on 3/16/24.
//

import Foundation
import UIKit
import SnapKit
import MapKit

class MapViewController: BaseViewController {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.mapType = .standard
        mv.backgroundColor = .blue
        mv.showsUserLocation = true
        
        return mv
    }()
        
    let date: Date
    var fillUps: [FillUp]?
    
    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let components = date.get(.day, .year)
        guard let day = components.day, let year = components.year, let weekday = date.dayOfWeek() else { return }
        title =  "\(weekday) \(date.monthName()) \(day), \(year)"
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFillUps()
    }

    func setupViews() {
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "annotation")
                       
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setFillUps() {
        mapView.removeAnnotations(mapView.annotations)
        
        fillUps = AdminManager.shared.groupedOpenFillUpsByDate[date]
        
        fillUps?.enumerated().forEach { idx, fillUp in
            fillUp.address.convertToPlacemark { placemark in
                guard let placemark = placemark else { return }
                self.setMapLocation(placemark: placemark, fillUp: fillUp)
            }
        }
        
        
        guard !mapView.annotations.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mapView.fitAllAnnotations()
        }
    }
        
    private func setMapLocation(placemark: CLPlacemark, fillUp: FillUp) {
        let annotation = MapViewAnnotation(coordinate: placemark.location!.coordinate, title: fillUp.user.name, subtitle: fillUp.address.formatted, fillUp: fillUp)
        
        mapView.addAnnotation(annotation)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? MapViewAnnotation else { return nil }
        
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
//        } else {
//            annotationView!.annotation = annotation
//        }
        
        // annotationView.canShowCallout = true
        // annotationView!.image = UIImage(systemName: "mappin.and.ellipse")!.withRenderingMode(.alwaysTemplate)
        // return annotationView
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        
        view.canShowCallout = true
        view.markerTintColor = ThemeManager.Color.red
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let annotation = annotation as? MapViewAnnotation {
            print("Selected fill up: ", annotation.fillUp)
            
            let vc = CompleteFillUpController(fillUp: annotation.fillUp) {
                self.setFillUps()
            }
            
            present(vc, animated: true)
        }
    }
}

extension MKMapView {
    func fitAllAnnotations() {
        var zoomRect = MKMapRect.null
        
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
            zoomRect = zoomRect.union(pointRect)
        }
        
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
}


final class MapViewAnnotation: NSObject, MKAnnotation {
  
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    let fillUp: FillUp
    
  
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, fillUp: FillUp) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.fillUp = fillUp
        
        super.init()
      }
}

