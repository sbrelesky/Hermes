//
//  NoticeController.swift
//  Hermes
//
//  Created by Shane on 3/20/24.
//

import Foundation
import UIKit
import SnapKit

class NoticeController: BaseViewController {
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl(frame: .zero)
        pc.currentPageIndicatorTintColor = ThemeManager.Color.primary
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
    
    lazy var nextButton: HermesButton = {
        let b = HermesButton(frame: .zero)
        b.setTitle("Next", for: .normal)
        b.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        return b
    }()
        
    var currentIndex = 0 {
        didSet {
            self.pageControl.currentPage = currentIndex
        }
    }
        
    let notices: [Notice]
    
    init(notices: [Notice]) {
        self.notices = notices
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        currentIndex = 0
        pageControl.numberOfPages = notices.count
        pageControl.isHidden = notices.count <= 1
        
        checkNextButton()
    }
    
    private func setupViews() {
        view.addSubview(pageControl)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NoticeCell.self, forCellWithReuseIdentifier: "cell")
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-10)
            make.width.equalTo(nextButton)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.bottom.equalTo(pageControl.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    // MARK: - Button Targets

    @objc func nextPressed() {
        // Scroll to next cell
        if currentIndex == notices.count - 1 {
            if let _ = notices.first(where: { !$0.dismissable }) {
                // Lock it down
                
            } else {
                // Present Login
                let controller = UINavigationController(rootViewController: LoginController())
                SceneDelegate.shared?.setCurrentWindow(controller: controller)
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
        self.checkNextButton()
    }
    
    func getCurrentIndexPath(collectionView: UICollectionView) -> IndexPath? {
        // Calculate the index of the currently visible cell
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }
    
    func checkNextButton() {
        if self.currentIndex == notices.count - 1 {
            nextButton.setTitle("Done", for: .normal)
        }
        
        if !notices[self.currentIndex].dismissable {
            nextButton.isHidden = true
        }
    }
}


extension NoticeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoticeCell
        cell.notice = notices[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
