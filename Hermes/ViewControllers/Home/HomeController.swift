//
//  HomeController.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit

class HomeController: BaseViewController {
    
    enum HomeMode {
        case `default`
        case inProgress
        case tonight
    }
    
    let helloLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(20.0)
        l.textColor = ThemeManager.Color.text
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let staticView: HomeStaticView = {
        let v = HomeStaticView(frame: .zero)
        v.isHidden = false
        
        return v
    }()
    
    let orderInProgressLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(24.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Fill Up Schedule"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(HomeFillUpCell.self, forCellReuseIdentifier: "fillUpCell")
        tv.register(HomeInstructionCell.self, forCellReuseIdentifier: "instructionCell")
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.isHidden = true

        return tv
    }()
    
    lazy var scheduleButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Schedule Fill Up", for: .normal)
        b.addTarget(self, action: #selector(schedulePressed), for: .touchUpInside)
        
        return b
    }()
    
    lazy var viewOrderButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("View Orders", for: .normal)
        b.backgroundColor = UIColor(hex: "#FEF8EB")
        b.setTitleColor(ThemeManager.Color.yellow, for: .normal)
        b.layer.borderWidth = 1
        b.layer.borderColor = ThemeManager.Color.yellow.cgColor
        
        b.addTarget(self, action: #selector(viewOrdersPressed), for: .touchUpInside)
        
        return b
    }()
    
    var mode: HomeMode = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hermes"
        
        let accountButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(accountPressed))
        navigationItem.rightBarButtonItem = accountButton
        
        if UserManager.shared.currentUser?.type == .admin {
            let accountButton = UIBarButtonItem(image: UIImage(systemName: "person.2.badge.gearshape.fill"), style: .plain, target: self, action: #selector(adminPressed))
            navigationItem.leftBarButtonItem = accountButton
        }
        
        
        setupViews()
        
        setNameLabel()
        
        // Set the user first login to false so the next time we hit home it's changed
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.userFirstLogin)

        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleMode()
    }
    
    private func setupViews() {
        view.addSubview(helloLabel)
        view.addSubview(scheduleButton)
        view.addSubview(viewOrderButton)
        
        helloLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(scheduleButton)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        viewOrderButton.snp.makeConstraints { make in
            make.bottom.equalTo(scheduleButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        setupStaticView()
        setupTableView()
    }
    
    private func setupStaticView() {
        view.addSubview(staticView)

        staticView.snp.makeConstraints { make in
            make.top.equalTo(helloLabel.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(scheduleButton.snp.top).offset(-60)
        }
    }
    
    private func setupTableView() {
        view.addSubview(orderInProgressLabel)
        view.addSubview(tableView)
                
        orderInProgressLabel.snp.makeConstraints { make in
            make.top.equalTo(helloLabel.snp.bottom).offset(Constants.Padding.Vertical.bottomSpacing)
            make.leading.trailing.equalTo(scheduleButton)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(orderInProgressLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(scheduleButton)
            make.bottom.equalTo(viewOrderButton.snp.top).offset(-20)
        }
    }
    
    private func setNameLabel() {
        guard let name = UserManager.shared.currentUser?.name else { return }
        let attributedGreeting = NSAttributedString(string: "\(!UserDefaults.standard.bool(forKey: Constants.UserDefaults.userFirstLogin) ? "Welcome Back" : "Hello")", attributes: [
            .font: ThemeManager.Font.Style.secondary(weight: .regular).font.withSize(20.0),
            .foregroundColor: ThemeManager.Color.text
        ])
        
        let attributedName = NSAttributedString(string: ", \(name)!", attributes: [
            .font: ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(20.0),
            .foregroundColor: ThemeManager.Color.text
        ])
        
        let attributedString = NSMutableAttributedString(attributedString: attributedGreeting)
        attributedString.append(attributedName)
        
        helloLabel.attributedText = attributedString
    }
    
    
    private func fetchData() {
        
        // Fetch customer if they exist
        if UserManager.shared.currentUser?.stripeCustomerId != nil {
            UserManager.shared.fetchCustomer { error in
                if let error = error {
                    self.presentError(error: error)
                }
            }
        }
        
        FillUpManager.shared.fetchFillUps { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.handleMode()
            }
        }
    }
    
    // MARK: - Button Targets
    
    @objc func accountPressed() {
        let vc = AccountController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func schedulePressed() {
        // let vc = InstructionsController()
        // let vc = CheckoutController(fillUp: FillUp.test)
        let vc = CarController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewOrdersPressed() {
        let vc = FillUpsController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func adminPressed() {
        let vc = AdminHomeController()
        navigationController?.pushViewController(vc, animated: true)
    }
   
    
    // MARK: - Helper Methods
    
    private func handleMode() {
        setMode()
        
        switch mode {
        case .default:
            staticView.isHidden = false
            tableView.isHidden = true
            orderInProgressLabel.isHidden = true
            viewOrderButton.isHidden = true

        case .inProgress, .tonight:
            staticView.isHidden = true
            tableView.isHidden = false
            orderInProgressLabel.isHidden = false
            
            orderInProgressLabel.text = mode == .inProgress ? "Fill Up Schedule" : "Your Fill Up is Scheduled for Tonight!"
            viewOrderButton.isHidden = mode == .inProgress
            
            tableView.reloadData()
        }

    }
    
    private func setMode() {
        if !FillUpManager.shared.openFillUps.isEmpty {
            if let _ = FillUpManager.shared.openFillUps.first(where: { Calendar.current.isDateInTomorrow($0.date) }) {
                mode = .tonight
            } else {
                mode = .inProgress
            }
        } else {
            mode = .default
        }
        
        mode = .tonight
    }
}

// MARK: - TableView Methods

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == .inProgress {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .inProgress {
            return FillUpManager.shared.openFillUps.count
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if mode == .inProgress {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fillUpCell", for: indexPath) as! HomeFillUpCell
            
            let fillUp = FillUpManager.shared.openFillUps[indexPath.row]
            cell.fillUp = fillUp
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell", for: indexPath) as! HomeInstructionCell
            cell.instruction = HomeInstruction(rawValue: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode == .inProgress || mode == .tonight {
            let fillUp = FillUpManager.shared.openFillUps[indexPath.section]
            let vc = ViewOrderController(fillUp: fillUp)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mode == .inProgress ? 130.0 : 110.0
    }
}



