//
//  UICollectionView.swift
//  Hermes
//
//  Created by Shane on 4/23/24.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func getCurrentIndexPath() -> IndexPath? {
        // Calculate the index of the currently visible cell
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return self.indexPathForItem(at: visiblePoint)
    }
    
}
