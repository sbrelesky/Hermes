//
//  UIViewController+Error.swift
//  Hermes
//
//  Created by Shane on 3/1/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentError(error: Error, completion: (() -> Void)? = nil) {
        print(error)
        presentError(message: error.localizedDescription,  completion: completion)
    }
    
    func presentError(message: String, completion: (() -> Void)? = nil) {
        let haptic = UINotificationFeedbackGenerator()
        haptic.prepare()
        haptic.notificationOccurred(.error)
        
        let popup = ErrorPopup(message: message, completion: completion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
    }
    
    func presentLoading(message: String, popupInstance: @escaping (LoadingPopup) ->(), dismissCompletion: (() -> Void)? = nil) {
        let popup = LoadingPopup(message: message, dismissCompletion: dismissCompletion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true) {
            popupInstance(popup)
        }
    }
    
    func presentLoading(message: String, dismissCompletion: (() -> Void)? = nil) -> LoadingPopup {
        let popup = LoadingPopup(message: message, dismissCompletion: dismissCompletion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
        return popup
    }
    
    
    func presentSpeedbump(title: String = "Are You Sure?", message: String, completion: (() -> Void)? = nil, confirmCompletion: (() -> Void)? = nil) {
        let popup = SpeedbumpPopup(title: title, message: message, completion: completion, confirmCompletion: confirmCompletion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
    }
    
    func presentSuccess(title: String = "Success!", message: String, completion: (() -> Void)? = nil) {
        let haptic = UINotificationFeedbackGenerator()
        haptic.prepare()
        haptic.notificationOccurred(.success)
        
        let popup = SuccessPopup(title: title, message: message, completion: completion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
    }
    
}
