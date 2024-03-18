//
//  CompleteFillUpController.swift
//  Hermes
//
//  Created by Shane on 3/14/24.
//

import Foundation
import UIKit
import SnapKit
import MapKit
import Stripe


protocol CompleteFilUpControllerDataEntryDelegate: AnyObject {
    func getGasCalculationValues() -> GasCalculationValues?
}

protocol CompleteFilUpControllerCalculationsDelegate: AnyObject {
    func setValuesForCost(_ cost: Double)
}


class CompleteFillUpController: BaseViewController, TextFieldValidation {
    
    
    private enum CellIdentifiers: String {
        case map = "mapCell"
        case car = "carCell"
        case data = "dataCell"
        case calculations = "calcCell"
        case buttons = "buttonCell"
    }
    
    enum CompleteFillUpCellType: Int, CaseIterable {
        case map = 0
        case car = 1
        case data = 2
        case calculations = 3
        case buttons = 4
    }
    
    let nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.text
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withSize(18.0)
        l.textAlignment = .center
        
        return l
    }()
 
    
    let orderLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.font = ThemeManager.Font.Style.secondary(weight: .medium).font
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
 
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        
        tv.delegate = self
        tv.dataSource = self
        
        tv.register(MapAddressCell.self, forCellReuseIdentifier: CellIdentifiers.map.rawValue)
        tv.register(CarTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.car.rawValue)
        tv.register(DataEntryCell.self, forCellReuseIdentifier: CellIdentifiers.data.rawValue)
        tv.register(CalculationsCell.self, forCellReuseIdentifier: CellIdentifiers.calculations.rawValue)
        tv.register(ButtonsCell.self, forCellReuseIdentifier: CellIdentifiers.buttons.rawValue)
        
        tv.separatorStyle = .none
        
        return tv
    }()
   
    weak var dataDelegate: CompleteFilUpControllerDataEntryDelegate?
    weak var calculationsDelegate: CompleteFilUpControllerCalculationsDelegate?

    var totalInCents: Int?
    
    let fillUp: FillUp
    let closure: (() -> Void)?
    
    init(fillUp: FillUp, closure: (() -> Void)? = nil) {
        self.fillUp = fillUp
        self.closure = closure
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Complete Fill Up"
        
        orderLabel.text = "Order #\(fillUp.id ?? "")"
        nameLabel.text = fillUp.user.name
        
        
        setupForKeyboard()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(nameLabel)
        view.addSubview(orderLabel)
        view.addSubview(tableView)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        orderLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.leading.equalTo(nameLabel)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(orderLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension CompleteFillUpController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CompleteFillUpCellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CompleteFillUpCellType(rawValue: section) {
            
        case .map, .calculations, .data, .buttons:
            return 1
        case .car:
            return fillUp.cars.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CompleteFillUpCellType(rawValue: indexPath.section) {
        
        case .map:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.map.rawValue, for: indexPath) as! MapAddressCell
            cell.fillUp = fillUp
            return cell
        case .car:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.car.rawValue, for: indexPath) as! CarTableViewCell
            cell.car = fillUp.cars[indexPath.row]
            cell.yearLabel.text = "\(fillUp.cars[indexPath.row].fuelCapacity) gallons"
            cell.selectionStyle = .none
            return cell
        case .data:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.data.rawValue, for: indexPath) as! DataEntryCell
            dataDelegate = cell
            return cell
        case .calculations:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.calculations.rawValue, for: indexPath) as! CalculationsCell
            calculationsDelegate = cell
            return cell
        case .buttons:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.buttons.rawValue, for: indexPath) as! ButtonsCell
            cell.delegate = self
            return cell
            
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height - 60 - 10 - 100 - 20
        
        switch CompleteFillUpCellType(rawValue: indexPath.section) {
        case .map:
            return screenHeight * 0.4
        case .car:
            return screenHeight * 0.15
        case .data:
            return screenHeight * 0.7
        case .calculations:
            return screenHeight * 0.18
        case .buttons:
            return screenHeight * 0.25
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch CompleteFillUpCellType(rawValue: section) {
        
        case .map :
            return "Location"
        case .car:
            return "Cars"
        case .data, .calculations, .buttons:
            return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
}

extension CompleteFillUpController: ButtonCellDelegate, Calculations {
    
    func calculate() {
        if let gasCalculationValues = dataDelegate?.getGasCalculationValues() {
            let cost = calculateCosts(values: gasCalculationValues)
            let processingFee = calculateProcessingFee(cost: cost)
            
            totalInCents = Int((cost + processingFee) * 100)
            
            calculationsDelegate?.setValuesForCost(cost)
        }
    }
    
    func chargeCustomer(button: HermesLoadingButton) {
        guard let totalInCents = totalInCents else { return }
        
        button.setLoading(true)
        
        fillUp.totalAmountPaid = totalInCents
        
        AdminManager.shared.completeFillUp(fillUp) { error in
            button.setLoading(false)
            if let error = error {
                self.presentError(error: error)
            } else {
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.closure?()
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    
    private func calculateCosts(values: GasCalculationValues) -> Double {
        // let poundPerGallon = (values.leftoverContainerStartWeight / values.leftoverGallons).truncate(places: 2)
        // let weightOfGasUsed = (values.leftoverContainerStartWeight - values.leftoverContainerEndWeight).truncate(places: 2)
        // let gallonsUsed = (poundPerGallon / weightOfGasUsed).truncate(places: 2)
        
        let pricePerContainer = Constants.gallonsPerContainer * values.pricePerGallon
        let weightUsed = (1.0 - (values.leftoverContainerEndWeight / values.leftoverContainerStartWeight)).truncate(places: 2)
        let allFullContainerPrice = ((values.numberOfFullContainers * Constants.gallonsPerContainer) * values.pricePerGallon)
        let totalCost = (weightUsed * pricePerContainer) + allFullContainerPrice
        
        return totalCost
    }
    
}
