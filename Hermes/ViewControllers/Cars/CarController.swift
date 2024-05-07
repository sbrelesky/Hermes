//
//  HomeController.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAnalytics

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
            { _ in completion() }
    }
}

class CarController: BaseViewController {

    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = ThemeManager.Color.gray.withAlphaComponent(0.4)
        tv.separatorStyle = .singleLine
        tv.allowsMultipleSelection = true
        tv.clipsToBounds = true
        
        return tv
    }()
    
    lazy var addNewCarButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate).applyingSymbolConfiguration(.init(pointSize: 40.0)), for: .normal)
        b.tintColor = ThemeManager.Color.gray
        b.imageView?.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(addNewCarPressed), for: .touchUpInside)
        
        return b
    }()
    
    let addNewCarLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font
        l.textColor = ThemeManager.Color.gray
        l.text = "Add New Car"
        l.textAlignment = .center
        
        return l
    }()
    
    let selectCarsLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(18.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Select the cars you'd like fill up"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    lazy var scheduleButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Next", for: .normal)
        b.addTarget(self, action: #selector(schedulePressed), for: .touchUpInside)
        b.layer.opacity = 0.3
        b.isEnabled = false
        
        return b
    }()
    
    
    private var tableViewHeightConstraint: Constraint?
    private var initialFetchLoaded = false
    
    let inFillUpProcess: Bool
    
    init(inFillUpProcess: Bool) {
        self.inFillUpProcess = inFillUpProcess
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cars"
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "cars_screen", "in_fill_up_process": inFillUpProcess])
        
        setupViews()
        
        UserManager.shared.fetchCars { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateTableViewHeight()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialFetchLoaded {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTableViewHeight()
            }
        } else {
            self.initialFetchLoaded = true
        }
        
        checkSelected()
    }
    
    
    private func setupViews() {
        view.addSubview(selectCarsLabel)
        view.addSubview(tableView)
        view.addSubview(addNewCarButton)
        view.addSubview(addNewCarLabel)
        view.addSubview(scheduleButton)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CarTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = 120 // Set an estimated row height for better performance
        
        selectCarsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.7)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
            make.top.greaterThanOrEqualTo(addNewCarLabel.snp.bottom).offset(-Constants.Padding.Vertical.bottomSpacing).priority(.required)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(selectCarsLabel.snp.bottom).offset(20)
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint // Initially set height to 0
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.6)
            make.bottom.lessThanOrEqualTo(scheduleButton.snp.top).offset(-60)
        }
        
        addNewCarButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(20)
        }
        
        addNewCarLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(addNewCarButton.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualTo(scheduleButton.snp.top).offset(-20).priority(.required)
        }
        
        
        scheduleButton.isHidden = !inFillUpProcess
        selectCarsLabel.isHidden = !inFillUpProcess
       
    }
    
    // Function to calculate and update the table view's height
    func updateTableViewHeight() {
        tableView.layoutIfNeeded() // Ensure all cell heights are calculated
        
        // Calculate total height of the table view's content
        let contentHeight = tableView.contentSize.height
                
        // Update the height constraint of the table view
        tableViewHeightConstraint?.update(offset: contentHeight)
    }
    
    
    // MARK: - Targets
    
    @objc func schedulePressed() {
      
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            // Iterate over the indexPaths and get the corresponding cells
            let selectedCars = selectedIndexPaths.compactMap({ (tableView.cellForRow(at: $0) as? CarTableViewCell)?.car })
            
            let vc = GasEstimateController(cars: selectedCars)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addNewCarPressed() {
        let vc = AddEditCarController(car: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
        
    // MARK: - Helper Methods
    
    private func checkSelected() {
        
        if tableView.indexPathForSelectedRow?.count ?? 0 > 0 {
            scheduleButton.layer.opacity = 1.0
            scheduleButton.isEnabled = true
        } else {
            scheduleButton.layer.opacity = 0.3
            scheduleButton.isEnabled = false
        }
    }
    
    
    private func handleEditCar(row: Int) {
        let car = UserManager.shared.cars[row]
        
        let vc = AddEditCarController(car: car)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleDeleteCar(indexPath: IndexPath) {
        let car = UserManager.shared.cars[indexPath.row]

        UserManager.shared.deleteCar(car) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.updateTableViewHeight()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }

}


// MARK: - Table View Data Source

extension CarController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.shared.cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CarTableViewCell
        
        let car = UserManager.shared.cars[indexPath.row]
        cell.car = car
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkSelected()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        checkSelected()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.handleEditCar(row: indexPath.row)
            // Handle edit action
            completionHandler(true)
        }
        editAction.backgroundColor = ThemeManager.Color.gray
        editAction.image = UIImage(systemName: "pencil")
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // Handle delete action
            self.handleDeleteCar(indexPath: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = ThemeManager.Color.primary
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}
