//
//  SupportController.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit



class SupportController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        
        tv.delegate = self
        tv.dataSource = self
        tv.register(FillUpCell.self, forCellReuseIdentifier: "cell")
        tv.separatorStyle = .none
        tv.backgroundColor = .white
        
        return tv
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Support"
        
        setupViews()
                
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func presentChatForSupport(_ support: Support) {
        let vc = ChatController(support: support)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SupportController: UITableViewDelegate, UITableViewDataSource {
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FillUpManager.shared.completeFillUps.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FillUpCell
        cell.fillUp = FillUpManager.shared.completeFillUps[indexPath.row]
        cell.timeLabel.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fillUp = FillUpManager.shared.completeFillUps[indexPath.row]
        // Create new support ticket
        SupportManager.shared.createSupportTicket(fillUp: fillUp) { result in
            switch result {
            case .success(let support):
                self.presentChatForSupport(support)
            case .failure(let error):
                self.presentError(error: error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60.0))
        header.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width - 10, height: 60.0))
        label.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font
        label.textColor = ThemeManager.Color.text
        label.text = "Need help with a previous order?"
        
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

}
