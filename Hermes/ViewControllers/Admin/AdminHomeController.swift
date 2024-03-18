//
//  AdminHomeController.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation
import UIKit
import SnapKit

class AdminHomeController: BaseViewController {
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Open", "Complete"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return sc
    }()
    
   lazy var tableView: UITableView = {
       let tv = UITableView(frame: .zero, style: .grouped)
       tv.backgroundColor = .white
       tv.delegate = self
       tv.dataSource = self
       tv.register(AdminFillUpCell.self, forCellReuseIdentifier: "cell")
       tv.separatorStyle = .singleLine
       
       return tv
   }()
   
    private enum Mode: Int {
        case open = 0
        case complete = 1
    }
    
    private let headerHeight = 70.0
    
    private var mode: Mode = .open
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Admin Control"
        
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsPressed))
        navigationItem.rightBarButtonItem = settingsButton
        
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
    
    @objc func settingsPressed() {
        let vc = AdminSettingsController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AdminHomeController: UITableViewDelegate, UITableViewDataSource, AdminHomeHeaderDelegate {
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return mode == .open ? AdminManager.shared.groupedOpenFillUpsByDate.keys.count : AdminManager.shared.groupedCompleteFillUpsByDate.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mode == .open {
            let key = Array(AdminManager.shared.groupedOpenFillUpsByDate.keys)[section]
            return AdminManager.shared.groupedOpenFillUpsByDate[key]?.count ?? 0
        } else {
            let key = Array(AdminManager.shared.groupedCompleteFillUpsByDate.keys)[section]
            return AdminManager.shared.groupedCompleteFillUpsByDate[key]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdminFillUpCell
        
        let rowNumber = indexPath.row + (0..<indexPath.section).reduce(0) {
            $0 + tableView.numberOfRows(inSection: $1)
        } + 1
        
        if mode == .open {
            
            let key = Array(AdminManager.shared.groupedOpenFillUpsByDate.keys)[indexPath.section]
            if let fillUp = AdminManager.shared.groupedOpenFillUpsByDate[key]?[indexPath.row] {
                cell.fillUp = fillUp
                cell.numberLabel.text = "\(rowNumber)"
            }
        } else {
            
            let key = Array(AdminManager.shared.groupedCompleteFillUpsByDate.keys)[indexPath.section]
            if let fillUp = AdminManager.shared.groupedCompleteFillUpsByDate[key]?[indexPath.row] {
                cell.fillUp = fillUp
                cell.numberLabel.text = "\(rowNumber)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode == .open {
            let key = Array(AdminManager.shared.groupedOpenFillUpsByDate.keys)[indexPath.section]
            if let fillUp = AdminManager.shared.groupedOpenFillUpsByDate[key]?[indexPath.row] {
                let vc = CompleteFillUpController(fillUp: fillUp)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let key = Array(AdminManager.shared.groupedCompleteFillUpsByDate.keys)[indexPath.section]
            if let fillUp = AdminManager.shared.groupedCompleteFillUpsByDate[key]?[indexPath.row] {
                let vc = CompleteFillUpController(fillUp: fillUp)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdminHomeHeader(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.delegate = self

        if mode == .open {
            let date = Array(AdminManager.shared.groupedOpenFillUpsByDate.keys)[section]
            headerView.date = date
            headerView.mapIcon.isHidden = false
        } else {
            let date = Array(AdminManager.shared.groupedCompleteFillUpsByDate.keys)[section]
            headerView.date = date
            headerView.mapIcon.isHidden = true
        }
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func mapPressed(date: Date) {
        let vc = MapViewController(date: date)
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol AdminHomeHeaderDelegate: AnyObject {
    func mapPressed(date: Date)
}

class AdminHomeHeader: UIView {
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withSize(24.0)
        label.textColor = ThemeManager.Color.text
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var mapIcon: UIButton = {
        let mapIcon = UIButton(frame: .zero)
        mapIcon.addTarget(self, action: #selector(mapPressed), for: .touchUpInside)
        mapIcon.setImage(UIImage(systemName: "map")?.withRenderingMode(.alwaysTemplate), for: .normal)
        mapIcon.tintColor = ThemeManager.Color.gray
        
        return mapIcon
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            let components = date.get(.day, .year)
            guard let day = components.day, let year = components.year else { return }
            label.text = "\(date.dayOfWeek() ?? ""), \(date.monthName()) \(day), \(year)"
        }
    }
    
    weak var delegate: AdminHomeHeaderDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(mapIcon)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        mapIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
            make.centerY.equalTo(label)
        }
    }
    
    @objc func mapPressed() {
        guard let date = date else { return }
        delegate?.mapPressed(date: date)
    }
    
}
