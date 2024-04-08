//
//  AdminController.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit

class AdminController: BaseViewController {
    
    private enum AdminCellTypes: Int, CaseIterable {
        case orders = 0
        case support = 1
        case settings = 2
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        
        tv.delegate = self
        tv.dataSource = self
        
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Admin Control"
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension AdminController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminCellTypes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font
        cell.textLabel?.textColor = ThemeManager.Color.text
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.tintColor = ThemeManager.Color.gray
        
        switch AdminCellTypes(rawValue: indexPath.row) {
        case .orders:
            cell.imageView?.image = UIImage(systemName: "fuelpump")
            cell.textLabel?.text = "Orders"
        case .support:
            cell.imageView?.image = UIImage(systemName: "message")
            cell.textLabel?.text = "Support Chats"
        case .settings:
            cell.imageView?.image = UIImage(systemName: "gear")
            cell.textLabel?.text = "Settings"
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AdminCellTypes(rawValue: indexPath.row) {
        case .orders:
            let vc = AdminOrdersController()
            navigationController?.pushViewController(vc, animated: true)
        case .support:
            let vc = AdminSupportController()
            navigationController?.pushViewController(vc, animated: true)
        case .settings:
            let vc = AdminSettingsController()
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
