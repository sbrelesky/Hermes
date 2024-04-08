//
//  AdminSupportController.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit

class AdminSupportController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        
        tv.delegate = self
        tv.dataSource = self
        tv.register(AdminSupportCell.self, forCellReuseIdentifier: "cell")
        tv.separatorStyle = .singleLine
        
        return tv
    }()
    
    var initialLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Support Chats"
        
        setupViews()
        
        AdminManager.shared.fetchAllSupportTickets { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.initialLoad = true
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialLoad {
            self.tableView.reloadData()
        }
    }
    
    private func setupViews() {
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension AdminSupportController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminManager.shared.supportTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdminSupportCell
        cell.support = AdminManager.shared.supportTickets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AdminChatController(support: AdminManager.shared.supportTickets[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}


