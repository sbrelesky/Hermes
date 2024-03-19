//
//  InstructionsController.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation
import UIKit
import SnapKit


class InstructionsController: BaseViewController {
    
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(22.0)
        l.textColor = ThemeManager.Color.text
        l.text = "Your fill up has been scheduled"
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl(frame: .zero)
        pc.currentPageIndicatorTintColor = ThemeManager.Color.yellow
        pc.pageIndicatorTintColor = ThemeManager.Color.gray
        pc.currentPage = 0
        
        return pc
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
       cv.isScrollEnabled = false

        return cv
    }()
   
    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.secondary(weight: .regular).font
        l.textColor = ThemeManager.Color.text
        l.text = "Leave your vehicle in an easily accessible location for our driver to get to."
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    lazy var nextButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Next", for: .normal)
        b.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        return b
    }()
    
    var instructions: [InstructionType] = [.car, .gasCap]
    
    var currentIndex = 0 {
        didSet {
            self.pageControl.currentPage = currentIndex
            
            if currentIndex == 0 {
                navigationItem.leftBarButtonItem?.isHidden = true
            } else {
                navigationItem.leftBarButtonItem?.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instructions"
        
        // Create a custom bar button item
        let customBackButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backPressed))
        // Set it as the left navigation item
        navigationItem.leftBarButtonItem = customBackButton

        setupViews()
        currentIndex = 0
        pageControl.numberOfPages = instructions.count
    }
    
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(pageControl)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(InstructionCell.self, forCellWithReuseIdentifier: "cell")
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-10)
            make.width.equalTo(nextButton)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Padding.Vertical.bottomSpacing)
            make.bottom.equalTo(pageControl.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview()
        }

    }
    
    // MARK: - Button Targets
    
    @objc func backPressed() {
        print("Custom back button tapped")
        if currentIndex > 0 {
            let indexPath = IndexPath(item: currentIndex - 1, section: 0)
            scrollToIndexPath(indexPath)
        }
    }
    
    @objc func nextPressed() {
        print("Next")
        // Scroll to next cell
        
        if currentIndex == instructions.count - 1 {
            navigationController?.popToRootViewController(animated: false)
        } else {
            let indexPath = IndexPath(item: currentIndex + 1, section: 0)
            scrollToIndexPath(indexPath)
        }
    }
    
    
    // MARK: - Helper Methods
    private func scrollToIndexPath(_ indexPath: IndexPath) {
        print("Scroll to: ", indexPath.item)
        DispatchQueue.main.async {
            self.collectionView.isPagingEnabled = false
            //Then call the scollToItem method
            self.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
            //After that you have to enable the paging if you have initially enabled it
            self.collectionView.isPagingEnabled = true
        }
    }
    
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView,
              let indexPath = getCurrentIndexPath(collectionView: collectionView) else { return }
        
        self.currentIndex = indexPath.item
    }
    
    func getCurrentIndexPath(collectionView: UICollectionView) -> IndexPath? {
        // Calculate the index of the currently visible cell
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }
}

extension InstructionsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InstructionCell
        cell.type = instructions[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

enum InstructionType {
    case car
    case gasCap
}
