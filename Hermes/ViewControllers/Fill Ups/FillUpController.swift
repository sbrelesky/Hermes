//
//  FillUpController.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation
import UIKit
import SnapKit

class FillUpsController: BaseViewController {
 
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(FillUpCell.self, forCellReuseIdentifier: "cell")
        tv.separatorStyle = .none
        
        return tv
    }()
    
    private let headerHeight = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Fill Ups"
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalToSuperview()
        }
    }
}

extension FillUpsController: UITableViewDelegate, UITableViewDataSource {
  
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return FillUpManager.shared.openFillUps.count
        } else {
            return FillUpManager.shared.completeFillUps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FillUpCell
        
        if indexPath.section == 0 {
            cell.fillUp = FillUpManager.shared.openFillUps[indexPath.row]
        } else {
            cell.fillUp = FillUpManager.shared.completeFillUps[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = ViewOrderController(fillUp: FillUpManager.shared.openFillUps[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ViewOrderController(fillUp: FillUpManager.shared.completeFillUps[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width, height: headerHeight))
        label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withSize(18.0)
        label.textColor = ThemeManager.Color.text
        label.text = section == 0 ? "Open Fill Ups": "Completed Fill Ups"
        label.textAlignment = .left
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
}

class FillUpCell: HomeFillUpCell {
    
}
