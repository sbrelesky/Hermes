//
//  HermesButton.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit

class HermesButton: UIButton {
    
    var originalWidth: CGFloat = 0.0
    var widthConstraint: Constraint?
    let cornerRadius = 5.0
    var title = ""
    
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    var highlightColor: UIColor?
    var originalColor: UIColor?
    let widthMultiplier: CGFloat
    
    override var backgroundColor: UIColor? {
        didSet {
            guard let backgroundColor = backgroundColor, highlightColor == nil, originalColor == nil else { return }
            
            originalColor = backgroundColor
            highlightColor = backgroundColor.darken(by: 0.1)
        }
    }
    
    init(widthMultiplier: CGFloat = Constants.WidthMultipliers.button) {
        self.widthMultiplier = widthMultiplier
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        self.widthMultiplier = Constants.WidthMultipliers.button
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.widthMultiplier = Constants.WidthMultipliers.button
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = ThemeManager.Color.yellow
        titleLabel?.font = ThemeManager.Font.Style.main.font.withDynamicSize(24.0)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = cornerRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = highlightColor
        self.haptic.impactOccurred()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = originalColor
    }
    
    
    // MARK: - Private Methods
    
    private var constraintsAdded = false
    
    private func addConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(Constants.Heights.button)
            widthConstraint = make.width.equalToSuperview().multipliedBy(widthMultiplier).constraint
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set up Auto Layout constraints
        if superview != nil && !constraintsAdded {
            addConstraints()
            constraintsAdded = true
            layoutIfNeeded()
            self.originalWidth = bounds.width
            self.title = self.titleLabel?.text ?? ""
            
        }
    }
}

class HermesLoadingButton: HermesButton {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        return indicator
    }()
    
    
    public func setLoading(_ loading: Bool, completion: ((Bool) -> Void)? = nil) {
        if loading {
            
            self.isEnabled = false
            
            DispatchQueue.main.async {
                
                // Transition to loading state
                self.originalWidth = self.frame.width // Store the original width
                self.layer.cornerRadius = self.frame.height / 2
                
                
                self.setTitle(nil, for: .normal)
                self.addSubview(self.activityIndicator)
                
                self.activityIndicator.snp.makeConstraints { make in
                    make.centerX.centerY.height.equalToSuperview()
                    make.width.equalTo(self.activityIndicator.snp.height)
                }
                
                self.activityIndicator.startAnimating()
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.widthConstraint?.deactivate()
                    
                    self.snp.makeConstraints { make in
                        self.widthConstraint = make.width.equalTo(self.snp.height).constraint
                    }
                    
                    self.layoutIfNeeded()
                    
                }, completion: completion)
              
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.cornerRadius
                
                
                self.setTitle(self.title, for: .normal)
                self.activityIndicator.removeFromSuperview()
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.widthConstraint?.deactivate()
                    self.snp.makeConstraints { make in
                        self.widthConstraint = make.width.equalTo(self.originalWidth).constraint
                    }
                    
                    self.layoutIfNeeded()
                    
                    self.isEnabled = true
                    
                }, completion: completion)
                
                
            }
        }
    }
}
