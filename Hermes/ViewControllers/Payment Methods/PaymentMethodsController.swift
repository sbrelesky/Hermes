//
//  PaymentMethodsController.swift
//  Hermes
//
//  Created by Shane on 3/6/24.
//

import Foundation
import UIKit
import SnapKit
import StripePaymentSheet

class PaymentMethodsController: BaseViewController {
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        
        return tv
    }()
    
    var paymentSheetFlowController: PaymentSheet.FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment Methods"
        setupViews()
        
        
        UserManager.shared.fetchPaymentMethods { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
     
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCustomerSheet() {
        
    }
    
    
    private func configurePaymentFlow(paymentIntent: PaymentIntent) {
        // MARK: Create a PaymentSheet.FlowController instance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        configuration.customer = .init(
            id: paymentIntent.customerId, ephemeralKeySecret: paymentIntent.ephemeralKey)
        configuration.returnURL = "payments-example://stripe-redirect"
        // Set allowsDelayedPaymentMethods to true if your business can handle payment methods that complete payment after a delay, like SEPA Debit and Sofort.
        configuration.allowsDelayedPaymentMethods = true
        configuration.primaryButtonColor = ThemeManager.Color.yellow
        configuration.primaryButtonLabel = "Pay"
        configuration.style = .alwaysLight
        
        
        PaymentSheet.FlowController.create(
            paymentIntentClientSecret: paymentIntent.clientSecret,
            configuration: configuration
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let paymentSheetFlowController):
                self?.paymentSheetFlowController = paymentSheetFlowController
            }
        }
    }
    
    
    func presentPaymentFlow() {
        self.paymentSheetFlowController?.presentPaymentOptions(from: self, completion: {
            self.updateButtons()
        })
    }
    
    
    
    func updateButtons() {
       // MARK: Update the payment method and buy buttons
       if let paymentOption = paymentSheetFlowController?.paymentOption {
           print("Payment Option: ", paymentOption.label)
       }
    }
    
}

extension PaymentMethodsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Saved payment methods
            return UserManager.shared.customer?.paymentMethods?.count ?? 0
        } else {
            // Add new payment methods
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Default"
            if let paymentMethod = UserManager.shared.customer?.paymentMethods?[indexPath.row],
               let brand = paymentMethod.card?.brand,
               let last4 = paymentMethod.card?.last4 {
                cell.textLabel?.text = brand.description + "**** \(last4)"
            }
            
        } else {
            cell.textLabel?.text = "Credit / Debit Card"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Saved Payment Methods"
        } else {
            return "Add Payment Method"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let paymentMethod = UserManager.shared.customer?.paymentMethods?[indexPath.row] {
                let vc = EditPaymentMethodController(paymentMethod: paymentMethod)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = AddPaymentMethodController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
