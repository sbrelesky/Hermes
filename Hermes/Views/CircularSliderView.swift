//
//  CircularSliderView.swift
//  Hermes
//
//  Created by Shane on 4/23/24.
//

import Foundation
import UIKit
import SnapKit

protocol CircluarSliderViewDelegate: AnyObject {
    func didSelectValue(value: CGFloat)
}

class CircularSliderView: UIView {
    
    let emptyLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withSize(30.0)
        l.text = "E"
        
        return l
    }()
    
    let quarterLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withSize(30.0)
        l.text = "1/4"
        
        return l
    }()
    
    let halfLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .center
        l.font = ThemeManager.Font.Style.main.font.withSize(30.0)
        l.text = "1/2"
        
        return l
    }()
    
    let threeQuarterLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .right
        l.font = ThemeManager.Font.Style.main.font.withSize(30.0)
        l.text = "3/4"
        
        return l
    }()
    
    let fullLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray.withAlphaComponent(0.43)
        l.textAlignment = .right
        l.font = ThemeManager.Font.Style.main.font.withSize(30.0)
        l.text = "F"
        
        return l
    }()
    
    let centerCircle: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = ThemeManager.Color.gray
        
        return v
    }()
    
    // Declare thumb and line views
    lazy var thumbView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = ThemeManager.Color.primary
        return v
    }()
    
    // Slider properties
    var minimumValue: Float = 0
    var maximumValue: Float = 1.0
    
    var currentValue: Float = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Nearest stopping points
    let stoppingPoints: [Float] = [0, 0.25, 0.5, 0.75, 1.0] // Modify as needed
    let trackWidth: CGFloat = 5.0
    
    // Colors
    var trackColor: UIColor = ThemeManager.Color.gray
    var progressColor: UIColor = ThemeManager.Color.primary
    var thumbColor: UIColor = ThemeManager.Color.primary
    var thumbRadius: CGFloat = 10
    
    var notchRects: [CGRect] = []
            
    var didLayoutSubviews = false
    var gaugeCenter: CGPoint = .zero
    var gaugeRadius: CGFloat = 0.0
    
    let haptic = UIImpactFeedbackGenerator(style: .rigid)
    
    weak var delegate: CircluarSliderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
             
        addSubview(emptyLabel)
        addSubview(quarterLabel)
        addSubview(halfLabel)
        addSubview(threeQuarterLabel)
        addSubview(fullLabel)
        addSubview(centerCircle)
        
        addSubview(thumbView)
    
        haptic.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels(center: CGPoint, radius: CGFloat) {
        
        for (idx, rect) in notchRects.enumerated() {
            let y = rect.maxY + 10
            
            if idx == 0 {
                emptyLabel.frame = CGRect(x: rect.minX + 10, y: y, width: 20, height: 20)
            } else if idx == 1 {
                quarterLabel.frame = CGRect(x: rect.maxX, y: y, width: 40, height: 20)
            } else if idx == 2 {
                halfLabel.frame = CGRect(x: rect.midX - 20, y: y, width: 40, height: 20)
            } else if idx == 3 {
                threeQuarterLabel.frame = CGRect(x: rect.minX - 40, y: y, width: 40, height: 20)
            } else {
                fullLabel.frame = CGRect(x: rect.minX - 10, y: y, width: 20, height: 20)
            }
        }
        
        // fullLabel.frame = CGRect(x: (radius * 2) - 20, y: center.y + 20, width: 40, height: 20)
        centerCircle.frame = CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)
        centerCircle.layer.cornerRadius = 30
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Get context
        guard let _ = UIGraphicsGetCurrentContext() else { return }
     
        // Define center and radius
        gaugeCenter = CGPoint(x: rect.midX, y: rect.midY)
        gaugeRadius = min(rect.width, rect.height) / 2 - 10
        
        // Calculate thumb position
        let thumbAngle = CGFloat(currentValue / maximumValue) * CGFloat.pi + CGFloat.pi
        let thumbCenter = CGPoint(x: gaugeCenter.x + cos(thumbAngle) * gaugeRadius, y: gaugeCenter.y + sin(thumbAngle) * gaugeRadius)
        
        // Draw line from center to thumb
        let linePath = UIBezierPath()
        linePath.move(to: gaugeCenter)
        linePath.addLine(to: thumbCenter)
        ThemeManager.Color.primary.setStroke() // Set line color
        linePath.lineWidth = 5 // Set line width
        linePath.stroke() // Draw the line
        
        
        // Draw track
        let trackPath = UIBezierPath(arcCenter: gaugeCenter, radius: gaugeRadius, startAngle: CGFloat.pi, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackColor.setStroke()
        trackPath.lineWidth = trackWidth
        trackPath.stroke()
        
        // Draw progress
        let progressEndAngle = CGFloat(currentValue / maximumValue) * CGFloat.pi + CGFloat.pi
        let progressPath = UIBezierPath(arcCenter: gaugeCenter, radius: gaugeRadius, startAngle: CGFloat.pi, endAngle: progressEndAngle, clockwise: true)
        progressColor.setStroke()
        progressPath.lineWidth = trackWidth
        progressPath.stroke()
        
        // Calculate notch position at 180 degrees
        drawNotch(angle: CGFloat.pi, center: gaugeCenter, radius: gaugeRadius)
        
        // Calculate notch position at 130 degrees
        drawNotch(angle: (3 * CGFloat.pi) / 4, center: gaugeCenter, radius: gaugeRadius)
        
        // Calculate notch position at 90 degrees
        drawNotch(angle: CGFloat.pi / 2, center: gaugeCenter, radius: gaugeRadius)
        
        // Calculate notch position at 45 degrees
        drawNotch(angle: CGFloat.pi / 4, center: gaugeCenter, radius: gaugeRadius)
        
        // Calculate notch position at 0 degrees
        drawNotch(angle: CGFloat(2 * CFloat.pi), center: gaugeCenter, radius: gaugeRadius)
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestStoppingPoint()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestStoppingPoint()
    }
    
    private func handleTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        // Calculate angle based on touch point
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angle = atan2(touchPoint.y - center.y, touchPoint.x - center.x)
        
        // Prevent from going beyond the half circle
        if touchPoint.y <= bounds.midY {
            // Convert angle to slider value
            currentValue = (Float(angle) + Float.pi) / Float.pi * (maximumValue - minimumValue) + minimumValue
        }
        
    }
    
    private func snapToNearestStoppingPoint() {
        let nearestPoint = stoppingPoints.min { abs($0 - currentValue) < abs($1 - currentValue) } ?? currentValue
        currentValue = nearestPoint
        
        print("Value: ", currentValue)
        haptic.impactOccurred()
        delegate?.didSelectValue(value: CGFloat(currentValue))
    }

    
    private func drawNotch(angle: CGFloat, center: CGPoint, radius: CGFloat) {
        let notchWidth = 20.0 // angle != CGFloat.pi && angle != (2 * CGFloat.pi) ? 5.0 : 20.0
        let notchHeight = 5.0 // angle != CGFloat.pi && angle != (2 * CGFloat.pi) ? 20.0 : 5.0
        let notchX = center.x + cos(angle) * radius
        let notchY = center.y - sin(angle) * radius
        let notchRect = CGRect(x: notchX - (notchWidth / 2.0), y: notchY, width: notchWidth, height: notchHeight)
        
        let notch = UIView(frame: notchRect)
        notch.backgroundColor = ThemeManager.Color.gray
        notch.layer.cornerRadius = 2
        addSubview(notch)
        sendSubviewToBack(notch)
                
        var rotationAngle: CGFloat?
        
        switch angle {
        case (CGFloat.pi / 4):
            rotationAngle = -45.0
        case ((3 * CGFloat.pi) / 4):
            rotationAngle = 45.0
        case (CGFloat.pi / 2):
            rotationAngle = 90.0
        default:
            break
        }
        
        if let rotationAngle = rotationAngle {
            let radians = rotationAngle / 180.0 * CGFloat.pi
            let rotation = notch.transform.rotated(by: radians)
            notch.transform = rotation
        }
        
        notchRects.append(notchRect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutSubviews && !notchRects.isEmpty {
                    
            setupLabels(center: gaugeCenter, radius: gaugeRadius)
            didLayoutSubviews = true
        }
            
        // Calculate thumb position based on slider value
        let thumbAngle = CGFloat(currentValue / maximumValue) * CGFloat.pi + CGFloat.pi
        let thumbCenter = CGPoint(x: gaugeCenter.x + cos(thumbAngle) * gaugeRadius, y: gaugeCenter.y + sin(thumbAngle) * gaugeRadius)
        
        thumbView.frame = CGRect(x: thumbCenter.x - thumbRadius, y: thumbCenter.y - thumbRadius, width: thumbRadius * 2, height: thumbRadius * 2)
        thumbView.center = thumbCenter
        
        thumbView.layer.cornerRadius = thumbView.bounds.width / 2
    }
}
