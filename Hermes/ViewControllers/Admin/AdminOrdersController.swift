//
//  AdminHomeController.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation
import UIKit
import SnapKit

class AdminOrdersController: BaseViewController {
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Open", "Complete"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return sc
    }()
    
   lazy var tableView: UITableView = {
       let tv = UITableView(frame: .zero, style: .grouped)
       tv.backgroundColor = .clear
       tv.delegate = self
       tv.dataSource = self
       tv.register(AdminFillUpCell.self, forCellReuseIdentifier: "cell")
       tv.separatorStyle = .singleLine
       tv.showsVerticalScrollIndicator = false
       
       return tv
   }()
   
    private enum Mode: Int {
        case open = 0
        case complete = 1
    }
    
    private let headerHeight = 70.0
    private var mode: Mode = .open
    
    var footerViews: [AdminOrderFooter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Orders"
        
        setupViews()
        
        AdminManager.shared.fetchOpenFillUps { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        tableView.reloadData()
    }
    
    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // Handle segmented control value change events
        if let selectedMode = Mode(rawValue: sender.selectedSegmentIndex) {
            mode = selectedMode
            tableView.reloadData()
        }
    }
}

extension AdminOrdersController: UITableViewDelegate, UITableViewDataSource, AdminOrderHeaderDelegate {
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return mode == .open ? AdminManager.shared.openOrders.count : AdminManager.shared.completeOrders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let order = mode == .open ? AdminManager.shared.openOrders[section] : AdminManager.shared.completeOrders[section]
        return order.fillUps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdminFillUpCell
        
        let rowNumber = indexPath.row + (0..<indexPath.section).reduce(0) {
            $0 + tableView.numberOfRows(inSection: $1)
        } + 1
        
        let order = mode == .open ? AdminManager.shared.openOrders[indexPath.section] : AdminManager.shared.completeOrders[indexPath.section]
        let fillUp = order.fillUps[indexPath.row]
        
        cell.fillUp = fillUp
        cell.numberLabel.text = "\(rowNumber)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let order = mode == .open ? AdminManager.shared.openOrders[indexPath.section] : AdminManager.shared.completeOrders[indexPath.section]
        let vc = CompleteFillUpController(fillUp: order.fillUps[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdminOrderHeader(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.delegate = self

        let order = mode == .open ? AdminManager.shared.openOrders[section] : AdminManager.shared.completeOrders[section]
        headerView.date = order.date
        headerView.mapIcon.isHidden = mode == .complete
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = AdminOrderFooter(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100.0))
        footer.order = mode == .open ? AdminManager.shared.openOrders[section] : AdminManager.shared.completeOrders[section]
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.bounds.height * 0.2233
    }
    
    func mapPressed(date: Date) {
        let vc = MapViewController(date: date)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


