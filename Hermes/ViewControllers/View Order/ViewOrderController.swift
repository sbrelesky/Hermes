//
//  EditOrderController.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation
import UIKit
import SnapKit

enum ViewOrderCellType: Int {
    case progress = 0
    case car = 1
    case address = 2
    case date = 3
    case total = 4
    case cancel = 5
}

class ViewOrderController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        
        tv.delegate = self
        tv.dataSource = self
        tv.register(ViewOrderProgressCell.self, forCellReuseIdentifier: "viewOrderCell")
        tv.register(CheckoutCell.self, forCellReuseIdentifier: "cell")
        tv.register(CarCheckoutCell.self, forCellReuseIdentifier: "carCell")
        tv.register(DateCheckoutCell.self, forCellReuseIdentifier: "dateCell")
        tv.register(ViewOrderTotalCell.self, forCellReuseIdentifier: "totalCell")
        tv.register(ViewOrderCancelCell.self, forCellReuseIdentifier: "cancelCell")
        
        return tv
    }()
       
    private let footerHeight = 50.0
    
    let fillUp: FillUp
    
    init(fillUp: FillUp) {
        self.fillUp = fillUp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fill Up"
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        tableView.reloadData()
    }
    
    private func calculatePrice() -> Double {
        var price: Double = 0.0

        for car in fillUp.cars {
            let gasPrice = switch car.fuel {
                case .regular: SettingsManager.shared.settings.prices.regular
                case .midgrade: SettingsManager.shared.settings.prices.midgrade
                case .premium: SettingsManager.shared.settings.prices.premium
                case .diesel: SettingsManager.shared.settings.prices.diesel
            }
            
            if car.fuelCapacity == 0.0 {
                // Use an average?
                price += 12.3 * gasPrice
            } else {
                price += car.fuelCapacity * gasPrice
            }
        }
        
        price += SettingsManager.shared.settings.serviceFee
    
        return price
    }
}


extension ViewOrderController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch ViewOrderCellType(rawValue: indexPath.section) {
        case .progress:
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewOrderCell", for: indexPath) as! ViewOrderProgressCell
            cell.fillUp = fillUp
            cell.type = ViewOrderProgressCellType(rawValue: indexPath.row)
            
            return cell
        case .car:
            let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath) as! CarCheckoutCell
            cell.cars = fillUp.cars
            
            return cell
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckoutCell
            cell.mainLabel.text = fillUp.address.street
            cell.subLabel.text = fillUp.address.cityStateZip
            
            return cell
        case .date:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateCheckoutCell
            cell.mainLabel.text = fillUp.date.dayOfWeek()
            cell.subLabel.text = fillUp.formattedDate
            
            return cell
        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalCell", for: indexPath) as! ViewOrderTotalCell
            cell.fillUp = fillUp
            
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cancelCell", for: indexPath) as! ViewOrderCancelCell
            cell.delegate = self
            cell.cancelButton.isHidden = fillUp.status == .complete
            
            return cell
        default:
            // This will be total
            return UITableViewCell()
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch ViewOrderCellType(rawValue: indexPath.section) {
        case .progress:
            return tableView.bounds.height * 0.2
        case .car:
            return tableView.bounds.height * 0.15
        case .address, .date:
            return tableView.bounds.height * 0.15
        case .total:
            return tableView.bounds.height * 0.15
        case .cancel:
            return fillUp.status == .open ? tableView.bounds.height * 0.15 : 0.0
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
            
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.bounds.width, height: footerHeight - 20))
            label.font = ThemeManager.Font.Style.secondary(weight: .bold).font.withDynamicSize(24.0)
            label.textColor = ThemeManager.Color.text
            label.text = "Order Details"
            label.textAlignment = .left
            
            let orderLabel = UILabel(frame: CGRect(x: 20, y: footerHeight - 20, width: tableView.bounds.width, height: 20))
            orderLabel.textColor = ThemeManager.Color.gray
            orderLabel.font = ThemeManager.Font.Style.secondary(weight: .medium).font
            orderLabel.textAlignment = .left
            orderLabel.text = "#\(fillUp.id ?? "")"
                        
            headerView.addSubview(label)
            headerView.addSubview(orderLabel)
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
            
            let line = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
            line.backgroundColor = ThemeManager.Color.primary.withAlphaComponent(0.28)
            
            footerView.addSubview(line)
            return footerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? footerHeight : .zero
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? footerHeight : .zero
    }
}

extension ViewOrderController: ViewOrderCancelCellDelegate {
    func cancelPressed() {
        
        self.presentSpeedbump(title: "Cancel Fill Up", message: "Are you sure you want to cancel this fill up?", confirmCompletion:  {
            FillUpManager.shared.cancelFillUp(self.fillUp) { error in
                if let error = error {
                    self.presentError(error: error)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        
   }
}
