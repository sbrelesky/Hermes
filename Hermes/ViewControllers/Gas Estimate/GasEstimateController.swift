//
//  GasEstimateController.swift
//  Hermes
//
//  Created by Shane on 4/22/24.
//

import Foundation
import UIKit
import SnapKit

class GasEstimateController: BaseViewController, CircluarSliderViewDelegate {
    
    let selectLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(18.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "How much gas is left in the car?"
        l.textAlignment = .left
        l.numberOfLines = 0
        
        return l
    }()
    
    let gaugeView: GasGaugeView = {
        let v = GasGaugeView(frame: .zero)
        v.backgroundColor = .clear
        
        return v
    }()
    
    let selectedAmountLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = ThemeManager.Color.gray
        l.textAlignment = .left
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(48.0)
        l.text = ""
        
        return l
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.register(GasEstimateCarCell.self, forCellWithReuseIdentifier: "cell")
        cv.isPagingEnabled = true
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    lazy var nextButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Next", for: .normal)
        b.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        return b
    }()
    
    var cars: [Car]
    var currentIndex = 0
    
    init(cars: [Car]) {
        self.cars = cars
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Gas Estimate"
        
        // Create a custom bar button item
        let customBackButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backPressed))
        // Set it as the left navigation item
        navigationItem.leftBarButtonItem = customBackButton
        
        setupViews()
        
        // Default to Quarter Tank
        didSelectValue(value: 0.0)
    }
    
    private func setupViews() {
        view.addSubview(selectLabel)
        view.addSubview(gaugeView)
        view.addSubview(selectedAmountLabel)
        view.addSubview(nextButton)
        view.addSubview(collectionView)
        
        gaugeView.sliderView.delegate = self
        
        let spacing = view.bounds.height * 0.02
        
        selectLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        gaugeView.snp.makeConstraints { make in
            make.top.equalTo(selectLabel.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(gaugeView.snp.width)
        }
        
        selectedAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(gaugeView.snp.bottom).offset(spacing)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedAmountLabel.snp.bottom) //.offset(8)
            make.leading.trailing.equalTo(gaugeView)
            make.bottom.equalTo(nextButton.snp.top)
        }
    }
    
    // MARK: - Targets
    
    @objc func backPressed() {
        print("Custom back button tapped")
        if currentIndex > 0 {
            let indexPath = IndexPath(item: currentIndex - 1, section: 0)
            scrollToIndexPath(indexPath)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func nextPressed() {
        if currentIndex == cars.count - 1 {
            print("Go to next step")
            // Fetch addresses so we have the default on the next page
            UserManager.shared.fetchAddresses { error in
                if let error = error {
                    self.presentError(error: error)
                } else {
                    let vc = SelectAddressController(cars: self.cars)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        } else {
            let indexPath = IndexPath(item: currentIndex + 1, section: 0)
            scrollToIndexPath(indexPath)
        }
    }
    
    // MARK: - Helper Methods
    
    private func scrollToIndexPath(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.isPagingEnabled = false
            self.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
            self.collectionView.isPagingEnabled = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView,
              let indexPath = collectionView.getCurrentIndexPath() else { return }
        
        self.currentIndex = indexPath.item
    }
    
    // MARK: - Slider View Delegate
    
    func didSelectValue(value: CGFloat) {
        
        switch GasEstimateAmount(rawValue: value) {
        case .empty:
            selectedAmountLabel.text = "Empty Tank"
        case .quarter:
            selectedAmountLabel.text = "Quarter Tank"
        case .half:
            selectedAmountLabel.text = "Half Tank"
        case .threeQuarters:
            selectedAmountLabel.text = "Three Quarters Tank"
        case .full:
            selectedAmountLabel.text = "Full Tank"
        default: break
        }
        
        cars[currentIndex].gasEstimate = value
    }
}

// MARK: - CollectionView Methods

extension GasEstimateController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GasEstimateCarCell
        cell.car = cars[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}






