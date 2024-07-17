//
//  FillUpController.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAnalytics

class FillUpsController: BaseViewController {
 
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(FillUpCell.self, forCellReuseIdentifier: "cell")
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        
        return tv
    }()
    
    private let headerHeight = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Fill Ups"
        
        HermesAnalytics.shared.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "view_fill_ups_screen"
        ])
        
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
        
        let fillUp = indexPath.section == 0 ? FillUpManager.shared.openFillUps[indexPath.row] : FillUpManager.shared.completeFillUps[indexPath.row]
        
        cell.configure(cars: fillUp.cars)
        cell.fillUp = fillUp
        
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
        label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(18.0)
        label.textColor = ThemeManager.Color.text
        label.text = section == 0 ? "Open Fill Ups": "Previous Fill Ups"
        label.textAlignment = .left
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
}
