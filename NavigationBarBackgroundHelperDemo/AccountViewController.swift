//
//  AccountViewController.swift
//  NavigationBarTransitionHandler
//
//  Created by 王杰 on 2018/3/8.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellReuseIdentifiers = ["order", "member", "callCenter"]
    
    var barAlpha: CGFloat? {
        didSet {
            guard let alpha = barAlpha else {
                return
            }
            updateBarAlpha(alpha)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let itemWidth = (view.frame.size.width - 20 * 4) / 3.0
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: itemWidth, height: itemWidth)
        barBackgroundHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.barTintColor = UIColor.orange
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateBarAlpha(_ val: CGFloat) {
        navigationController?.navigationBar.barStyle = val < 0.5 ? .default : .black
        navigationController?.navigationBar.tintColor = val < 0.2 ? UIColor.darkGray : UIColor.white
        barBackgroundHelper.view?.alpha = val
    }
    
}

extension AccountViewController : NavigationBarBackgroundHelperDelegate {
    
    func navigationBarForegroundAttrDidRestore() {
        if let alpha = barAlpha {
            updateBarAlpha(alpha)
        }
    }
    
}

extension AccountViewController : UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.isViewLoaded, self.view.window != nil else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let topEdge = view.safeAreaInsets.top
        barAlpha = offsetY >= (CollectionHeaderHeight - topEdge) ? 1.0 : (offsetY < -topEdge ? 0 : (offsetY + topEdge) / CollectionHeaderHeight)
    }
    
}

extension AccountViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellReuseIdentifiers.count * 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifiers[indexPath.item % cellReuseIdentifiers.count], for: indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
    }
    
}

private let CollectionHeaderHeight = CGFloat(110.0)
