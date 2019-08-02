//
//  AccountViewController.swift
//  NavigationBarTransitionHandler
//
//  Created by Jerry Wong on 2018/3/8.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarHelper

class AccountViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        navigationBarHelper.perform {
            $0.barStyle = .black
            $0.barTintColor = UIColor.orange
            $0.tintColor = UIColor.white
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateBarAlpha(_ val: CGFloat) {
        navigationController?.navigationBar.barStyle = val < 0.5 ? .default : .black
        navigationController?.navigationBar.tintColor = val < 0.2 ? UIColor.darkGray : UIColor.white
        navigationBarHelper.view?.alpha = val
    }
}

extension AccountViewController : NavigationBarHelperDelegate {
    
    func willRestore(backgroundAttr: inout NavigationBarHelper.BackgroundAttr) {}
    
    func didRestore(backgroundAttr: NavigationBarHelper.BackgroundAttr) {}
    
    func willRestore(foregroundAttr: inout NavigationBarHelper.ForegroundAttr) {
        if let val = barAlpha {
            foregroundAttr.barStyle = val < 0.5 ? .default : .black
            foregroundAttr.tintColor = val < 0.2 ? UIColor.darkGray : UIColor.white
        }
    }
    
    func didRestore(foregroundAttr: NavigationBarHelper.ForegroundAttr) {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item % 2 == 0 {
            self.performSegue(withIdentifier: "pushTimeline", sender: nil)
        } else if indexPath.item % 2 == 1 {
            navigationController?.popViewController(animated: true)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
    }
    
}

private let CollectionHeaderHeight = CGFloat(110.0)
