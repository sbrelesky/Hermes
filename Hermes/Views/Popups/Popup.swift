//
//  Popup.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit

class PopupController: UIViewController {

    let popupView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        
        return v
    }()
    
    lazy var dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = ThemeManager.Color.text
        b.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        return b
    }()
   
    let completionHandler: (() -> Void)?
    
    init(_ completion: (() -> Void)?) {
        self.completionHandler = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // definesPresentationContext = true
        view.backgroundColor = ThemeManager.Color.gray.withAlphaComponent(0.6)
        
        // Add blur effect
//        let blurEffect = UIBlurEffect(style: .extraLight) // Choose the desired blur style
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        view.addSubview(blurEffectView)
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(popupView)
        popupView.addSubview(dismissButton)
        
        // Add constraints for popup view and dismiss button using SnapKit
        popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
                
        dismissButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        
        setupAdditionalViews()
        
//        
//        // Add tap gesture recognizer to dismiss popup when background is tapped
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
//        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissPopup() {
        dismiss(animated: true, completion: completionHandler)
    }
 
    // MARK: - Override this methods in subclasses
    func setupAdditionalViews() {
        fatalError("Subclasses must override setupAdditionalViews()")
    }
}
