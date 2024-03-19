//
//  CheckoutController.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import UIKit
import SnapKit
import StripePaymentSheet


class CheckoutController: BaseViewController {
    
    let disclaimerLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.gray
        l.text = Constants.Text.checkoutDisclaimer
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        
        return tv
    }()
    
    lazy var checkoutButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Checkout", for: .normal)
        b.addTarget(self, action: #selector(checkoutPressed), for: .touchUpInside)
        
        return b
    }()
    
    let totalView: TotalCheckoutView = {
        let v = TotalCheckoutView(frame: .zero)
        
        return v
    }()

    var paymentSheet: PaymentSheet?    
    
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
        
        title = "Checkout"
        
        setupViews()        
    }
    
    private func setupViews() {
        view.addSubview(checkoutButton)
        view.addSubview(totalView)
        view.addSubview(disclaimerLabel)
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CheckoutCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CarCheckoutCell.self, forCellReuseIdentifier: "carCell")
        tableView.register(DateCheckoutCell.self, forCellReuseIdentifier: "dateCell")
        
        if let price = calculatePrice().formatCurrency() {
            totalView.totalAmountLabel.text = "\(price)"
        }
        
        if let serviceFee = Settings.shared.serviceFee.formatCurrency() {
            totalView.feeAmountLabel.text = "\(serviceFee)"
        }
        

        checkoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        totalView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.bottom.equalTo(checkoutButton.snp.top)
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        disclaimerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(totalView.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(disclaimerLabel.snp.top)
        }
        
        tableView.reloadData()
    }
    
    @objc func checkoutPressed() {
    
        checkoutButton.setLoading(true)
        
        UserManager.shared.checkForCustomerOrCreate { error in
            if let error = error {
                self.checkoutButton.setLoading(false)
                self.presentError(error: error)
            } else {
                self.createPaymentIntent()
            }
        }
    }
    
    private func createPaymentIntent() {
        let amount = Int(Settings.shared.serviceFee * 100.0)
        
        FirebaseFunctionManager.shared.createPaymentIntent(amount: amount) { result in
            self.checkoutButton.setLoading(false)
            
            switch result {
            case .success(let paymentIntent):
                self.configurePaymentSheet(paymentIntent: paymentIntent)
            case .failure(let error):
                self.presentError(error: error)
            }
        }
    }
    
    private func configurePaymentSheet(paymentIntent: PaymentIntent) {
        // MARK: Create a PaymentSheet instance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        configuration.customer = .init(id: paymentIntent.customerId, ephemeralKeySecret: paymentIntent.ephemeralKey)
        configuration.allowsDelayedPaymentMethods = false
        
        var appearance = PaymentSheet.Appearance()
        appearance.colors.primary = ThemeManager.Color.yellow
        appearance.colors.componentText = ThemeManager.Color.text
        appearance.font.base = ThemeManager.Font.Style.secondary(weight: .medium).font.withSize(16.0)
        appearance.primaryButton.textColor = .white
        
        configuration.appearance = appearance
        
        paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntent.clientSecret, configuration: configuration)
        paymentSheet?.present(from: self, completion: { paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                print("Your order is confirmed")
                self.scheduleFillUp(paymentIntentSecret: paymentIntent.clientSecret)
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print("Payment failed: \(error)")
                self.presentError(error: error)
            }
        })
    }
    
   
   
    private func scheduleFillUp(paymentIntentSecret: String) {
        fillUp.paymentIntentSecret = paymentIntentSecret
        
        FillUpManager.shared.scheduleFillUp(fillUp) { error in
            
            self.checkoutButton.setLoading(false) { success in
                if success {
                    if let error = error {
                        self.presentError(error: error)
                    } else {
                        print("Fill Up Successfully Scheduled")
                        let vc = InstructionsController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    private func calculatePrice() -> Double {
        var price: Double = 0.0

        for car in fillUp.cars {
            var gasPrice = switch car.fuel {
                case .regular: Settings.shared.prices.regular
                case .midgrade: Settings.shared.prices.midgrade
                case .premium: Settings.shared.prices.premium
                case .diesel: Settings.shared.prices.diesel
            }
            
            if car.fuelCapacity == 0.0 {
                // Use an average?
                price += 12.3 * gasPrice
            } else {
                price += car.fuelCapacity * gasPrice
            }
        }
    
        return price
    }
}


extension CheckoutController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch CheckoutCellType(rawValue: indexPath.section) {
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
        default:
            return UITableViewCell()
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch CheckoutCellType(rawValue: section) {
//        case .car:
//            return "Car"
//        case .address:
//            return "Address"
//        case .date:
//            return "Date"
//        default:
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch CheckoutCellType(rawValue: indexPath.section) {
        case .car, .address, .date:
            return 60
        default: return 0
        }
    }
}
