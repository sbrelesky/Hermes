//
//  BaseViewController.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    typealias onCompleteHandler = (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = ThemeManager.Color.yellow
        navigationController?.navigationBar.titleTextAttributes = [
            .font: ThemeManager.Font.Style.main.font.withDynamicSize(29.0),
            .foregroundColor: ThemeManager.Color.text
        ]
        
        view.backgroundColor = .white
    }
}
