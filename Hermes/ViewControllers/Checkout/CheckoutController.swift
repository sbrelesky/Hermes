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
import FirebaseAnalytics


@resultBuilder
public class NSAttributedStringBuilder {
    public static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")

        return components.reduce(into: result) { (result, current) in result.append(current) }
    }
}

extension NSAttributedString {
    public class func composing(@NSAttributedStringBuilder _ parts: () -> NSAttributedString) -> NSAttributedString {
        return parts()
    }
}

class CheckoutController: BaseViewController, PaymentMethodsDelegate {
    
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

    var serviceFeeAmount = SettingsManager.shared.settings.serviceFee
    
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
        setupForKeyboard()
        
        HermesAnalytics.shared.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "checkout_screen"])
        HermesAnalytics.shared.logEvent(AnalyticsEventBeginCheckout, parameters: nil)

        title = "Checkout"
        
        UserManager.shared.fetchPromotions { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.setupViews()
            }
        }
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
        tableView.register(NotesCell.self, forCellReuseIdentifier: "notesCell")
        
        if let price = calculatePrice().formatCurrency() {
            totalView.totalAmountLabel.text = "\(price)"
        }
        
        if let serviceFee = SettingsManager.shared.settings.serviceFee.formatCurrency() {
            
            if let promo = UserManager.shared.promotions.first {
                
                var discountedPrice = promo.discountPercentage == 1.0 ? "Free" : "\((SettingsManager.shared.settings.serviceFee * promo.discountPercentage).formatCurrency() ?? serviceFee)"
                
                serviceFeeAmount = promo.discountPercentage == 1.0 ? 0.0 : (SettingsManager.shared.settings.serviceFee * promo.discountPercentage)
                
                let attributedString = NSAttributedString.composing {
                    NSAttributedString(string: "\(serviceFee)", attributes: [.strikethroughStyle : NSUnderlineStyle.single.rawValue])
                    NSAttributedString(string: " \(discountedPrice)")
                }
                
                totalView.feeAmountLabel.attributedText = attributedString
            } else {
                totalView.feeAmountLabel.text = "\(serviceFee)"
            }
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
    
        guard let notesCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? NotesCell, let notes = notesCell.textView.text else { return }
        
        fillUp.notes = notes
        
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
        let amount = Int(serviceFeeAmount * 100.0)
        
        guard amount != 0 else {
            self.presentPopup(title: "Please add a payment method", buttonTitle: "Okay", description: "We need a card to charge for just the gas after your fill up is complete.") {
                print("Go to payment method controller")
                self.handlePaymentMethods()
            }
            
            return
        }
        
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
        configuration.merchantDisplayName = "Hermes"
        configuration.customer = .init(id: paymentIntent.customerId, ephemeralKeySecret: paymentIntent.ephemeralKey)
        configuration.allowsDelayedPaymentMethods = false
        
        var appearance = PaymentSheet.Appearance()
        appearance.colors.primary = ThemeManager.Color.primary
        appearance.colors.componentText = ThemeManager.Color.text
        appearance.font.base = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(16.0)
        appearance.primaryButton.textColor = .white
        
        configuration.appearance = appearance
        
        paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntent.clientSecret, configuration: configuration)
        paymentSheet?.present(from: self, completion: { paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                print("Your order is confirmed")
                self.scheduleFillUp(paymentIntent: paymentIntent)
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print("Payment failed: \(error)")
                self.presentError(error: error)
            }
        })
    }
    
   
   
    private func scheduleFillUp(paymentIntent: PaymentIntent) {
        
        fillUp.payments?.append(paymentIntent)
        
        FillUpManager.shared.scheduleFillUp(fillUp) { error in
            
            self.checkoutButton.setLoading(false) { success in
                if success {
                    if let error = error {
                        self.presentError(error: error)
                    } else {
                        print("Fill Up Successfully Scheduled")
                        HermesAnalytics.shared.logEvent(AnalyticsEventPurchase, parameters: [
                          AnalyticsParameterPrice: paymentIntent.amount,
                        ])
                        
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
    
        return price
    }
}


extension CheckoutController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesCell
            
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
        case .notes:
            return 100
        default: return 0
        }
    }
}
