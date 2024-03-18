//
//  AddressController.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import UIKit
import SnapKit
import MapKit

protocol AddressControllerDelegate: AnyObject {
    func selectedAddress(_ address: Address)
}

class AddressController: BaseViewController, AddressCellDelegate, Geocode {
    
    private enum Mode {
        case `default`
        case searching
    }
    
    lazy var searchBarTextField: HermeSearchBarTextField = {
        let v = HermeSearchBarTextField()
        v.setPlaceholder("Search for an address")
        v.searchDelegate = self
        
        return v
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .singleLine
        
        return tv
    }()
    
    private var mode: Mode = .default
    
    let completer = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
   
    weak var delegate: AddressControllerDelegate?
    
    let onComplete: onCompleteHandler
    
    init(onComplete: onCompleteHandler = nil){
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Address"

        completer.delegate = self
        completer.filterType = .locationsOnly
        completer.pointOfInterestFilter = .excludingAll
        
        completer.queryFragment = "3788 Elliott St"
        
        setupForKeyboard()
        setupViews()
        
        UserManager.shared.fetchAddresses { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBarTextField.text = nil
        mode = .default
        tableView.reloadData()
    }
    
    private func setupViews() {
        view.addSubview(searchBarTextField)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddressCell.self, forCellReuseIdentifier: "addressCell")
        tableView.register(AddressSuggestionCell.self, forCellReuseIdentifier: "suggestionCell")
                
        // Configure constraints using SnapKit to position the search bar just below the navigation bar
        searchBarTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBarTextField.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func editPressed(address: Address?) {
        guard let address = address else { return }
        
        let vc = EditAddressController(location: Location(placemark: nil, address: address))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleDeleteAddress(indexPath: IndexPath) {
        let address = UserManager.shared.addresses[indexPath.row]

        UserManager.shared.deleteAddress(address) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    private func handleSetDefaultAddress(indexPath: IndexPath) {
        let address = UserManager.shared.addresses[indexPath.row]
        UserManager.shared.setDefaultAddress(address) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.tableView.reloadData()
            }
        }
    }
}

extension AddressController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mode == .default ? UserManager.shared.addresses.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if mode == .default {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
            
            cell.delegate = self
            cell.address = UserManager.shared.addresses[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! AddressSuggestionCell
      
            let suggestion = searchResults[indexPath.row]
            cell.streetLabel.text = suggestion.title
            cell.subAddressLabel.text = suggestion.subtitle
            
            return cell
        }        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        if mode == .default {
            // Go Back with Selected Address
            
            onComplete?()
            
            let address = UserManager.shared.addresses[indexPath.row]
            delegate?.selectedAddress(address)
            
        } else {
            let selectedSuggestion = searchResults[indexPath.row]
            let address = selectedSuggestion.title + " " + selectedSuggestion.subtitle
            
            geocodeAddress(address) { result in
                switch result {
                case .success(let location):
                    let vc = EditAddressController(location: location)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .failure(let error):
                    self.presentError(error: error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mode == .default ? "Saved Addresses" : ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.editPressed(address: UserManager.shared.addresses[indexPath.row])
            // Handle edit action
            completionHandler(true)
        }
        editAction.backgroundColor = ThemeManager.Color.gray
        editAction.image = UIImage(systemName: "pencil")
        
        let setDefaultAction = UIContextualAction(style: .normal, title: "Default") { (action, view, completionHandler) in
            self.handleSetDefaultAddress(indexPath: indexPath)
            completionHandler(true)
        }
        
        setDefaultAction.backgroundColor = ThemeManager.Color.textFieldBackground
        setDefaultAction.image = UIImage(named: "placemark_red")?.resizeImage(targetSize: CGSize(width: 30, height: 30))
     
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // Handle delete action
            self.handleDeleteAddress(indexPath: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = ThemeManager.Color.yellow
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, setDefaultAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
        }
    }
}


// MARK: - HermesSearchBarTextFieldDelegate
extension AddressController: HermesSearchBarTextFieldDelegate {
    
    func searching(searchText: String) {
        if mode == .default {
            mode = .searching
            tableView.reloadData()
        }
                
        // Update the query fragment of the completer
        DispatchQueue.main.async {
            self.completer.queryFragment = searchText
        }
    }
    
    func stopSearching() {
        if mode == .searching {
            mode = .default
            tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate
extension AddressController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            mode = .searching
        } else {
            mode = .default
        }
        
        searchBar.resignFirstResponder()
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        searchResults = completer.results.filter { result in
//            let address = result.title + " " + result.subtitle
//            if let zip = extractZipCode(from: address) {
//                return true
//                // return Constants.availableZips.contains(zip)
//            }
//            
//            return false
//        }

        searchResults = completer.results
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search failed with error: \(error)")
    }
    
    func extractZipCode(from address: String) -> String? {
        print("\n\nChecking Address: ", address)
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
        let matches = detector.matches(in: address, options: [], range: NSRange(location: 0, length: address.utf16.count))

        for match in matches {
            print("Match: ", match.resultType == .address)
            print(match.addressComponents)
            
            if match.resultType == .address,
               let components = match.addressComponents,
               let zip = components[.zip] {
                
                print("Zip: ", zip)
                
                return zip
            }
        }
        
        return nil
    }
}
