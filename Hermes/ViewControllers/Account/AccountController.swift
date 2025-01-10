//
//  AccountController.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation
import UIKit
import SnapKit
import StripePaymentSheet

class AccountController: BaseViewController, PaymentMethodsDelegate {
    
    private enum AccountType: String, CaseIterable {
        case info = "Account Info"
        case fillUps = "Orders"
        case cars = "Cars"
        case addresses = "Addresses"
        case paymentMethods = "Payment Methods"
        case support = "Support"
        case resetPassword = "Reset Password"
        case logout = "Log Out"
        case deleteAccount = "Delete Account"
    }
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        
        return tv
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account"
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func resetPassword() {
        presentSpeedbump(title: "Reset Password", message: "Are you sure you want to reset your password?") {
            print("Cancelled")
        } confirmCompletion: {
            UserManager.shared.resetPassword { error in
                if let error = error {
                    self.presentError(error: error)
                } else {
                    self.presentSuccess(message: "Password reset email sent successfully")
                }
            }
        }
    }
    
    private func logout() {
        presentSpeedbump(title: "Log Out", message: "Are you sure you want to log out?") {
            print("Cancelled")
        } confirmCompletion: {
            do {
                try UserManager.shared.signOut()
                self.navigationController?.dismiss(animated: true)
            } catch let error {
                self.presentError(error: error)
            }
        }
    }
    
    private func deleteAccount() {
        presentSpeedbump(message: "This will permanately delete your account and this action cannot be undone.") {
            print("Cancelled?")
        } confirmCompletion: {
            UserManager.shared.deleteAccount { error in
                if let error = error {
                    self.presentError(error: error)
                } else {
                    do {
                        try UserManager.shared.signOut()
                        self.navigationController?.dismiss(animated: true)
                    } catch let error {
                        self.presentError(error: error)
                    }
                }
            }
        }
    }
    
    private func handleSupport() {
        SupportManager.shared.fetchOpenSupportTicket { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                
                guard let openTicket = SupportManager.shared.openSupportTicket else {
                    let vc = SupportController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
                let vc = ChatController(support: openTicket)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension AccountController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = AccountType.allCases[indexPath.row].rawValue
        cell.textLabel?.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withDynamicSize(18.0)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AccountType.allCases[indexPath.row] {
        case .info:
            let vc = EditInfoController()
            navigationController?.pushViewController(vc, animated: true)
        case .fillUps:
            let vc = FillUpsController()
            navigationController?.pushViewController(vc, animated: true)
        case .cars:
            let vc = CarController(inFillUpProcess: false)
            navigationController?.pushViewController(vc, animated: true)
        case .addresses:
            let vc = AddressController()
            navigationController?.pushViewController(vc, animated: true)
        case .paymentMethods:
            handlePaymentMethods()
        case .support:
            handleSupport()
        case .resetPassword:
            resetPassword()
        case .logout:
            logout()
        case .deleteAccount:
            deleteAccount()
        }
    }
}

extension PaymentMethodsDelegate where Self: UIViewController  {
    
    // MARK: Main Method to be called
    
    func handlePaymentMethods() {
        
        UserManager.shared.checkForCustomerOrCreate { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                Task {
                    await self.presentPaymentMethods()
                }
            }
        }
    }
    
    func presentPaymentMethods() async {
        var sheet: CustomerSheet?
        
        let popup = await presentLoading(message: "Loading payment methods") {
            self.presentCustomerSheet(sheet)
        }
            
        do {
            sheet = try await setupCustomerSheet()
            await popup.dismissPopup()
            
        } catch (let error) {
            await self.presentError(error: error)
        }
        
        
    }
    
    func setupCustomerSheet() async throws -> CustomerSheet {
        let configuration = configureCustomerSheet()
                
        // So if users don't have a customer
        guard let customerId = UserManager.shared.customer?.id else {
            throw CustomError.unknown
        }
        
        do {
            let key = try await FirebaseFunctionManager.shared.createEphemeralKey()
            let setupIntent = try await FirebaseFunctionManager.shared.createSetupIntent()
        
            let customerAdapter = StripeCustomerAdapter(customerEphemeralKeyProvider: {
                return CustomerEphemeralKey(customerId: customerId, ephemeralKeySecret: key)
            }, setupIntentClientSecretProvider: {
                return setupIntent.clientSecret
            })

            return CustomerSheet(configuration: configuration, customer: customerAdapter)
            
        } catch (let error) {
            throw error
        }
       
    }
    
    func configureCustomerSheet() -> CustomerSheet.Configuration {
        var configuration = CustomerSheet.Configuration()
        var appearance = configuration.appearance
        
//        configuration.primaryButtonColor = ThemeManager.Color.primary
//        configuration.primaryButtonLabel = "Pay"
        configuration.style = .alwaysLight
        appearance.font.base = ThemeManager.Font.Style.secondary(weight: .medium).font.withSize(18.0)
        appearance.primaryButton.textColor = .white
        appearance.primaryButton.backgroundColor = ThemeManager.Color.primary
        appearance.primaryButton.font = ThemeManager.Font.Style.secondary(weight: .medium).font.withSize(18.0)
        appearance.primaryButton.successTextColor = .white
        appearance.primaryButton.successBackgroundColor = ThemeManager.Color.green
        appearance.colors.primary = ThemeManager.Color.primary
        appearance.colors.text = ThemeManager.Color.text

        configuration.appearance = appearance

        configuration.headerTextForSelectionScreen = "Manage your payment method"
        
        return configuration
    
    }
        
    func presentCustomerSheet(_ customerSheet: CustomerSheet?)  {
        customerSheet?.present(from: self, completion: { result in
            
            switch result {
            case .canceled(_):
              break
            case .selected(_):
                UserManager.shared.fetchPaymentMethods { error in
                    if let error = error {
                        self.presentError(error: error)
                    }
                }
            case .error(let error):
                self.presentError(error: error)
            }
        })
    }
}


protocol PaymentMethodsDelegate: AnyObject {
    func handlePaymentMethods()
    func presentPaymentMethods() async
    func configureCustomerSheet() -> CustomerSheet.Configuration
    func setupCustomerSheet() async throws -> CustomerSheet
    func presentCustomerSheet(_ customerSheet: CustomerSheet?)
}

