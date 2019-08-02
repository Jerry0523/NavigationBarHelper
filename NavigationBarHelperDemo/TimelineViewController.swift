//
//  TimelineViewController.swift
//  NavigationBarHelperDemo
//
//  Created by Jerry Wong on 2018/5/29.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {
    
    let titleLabel = UILabel()
    
    let blanBarItem = UIBarButtonItem()
    
    var lastOffsetY: CGFloat?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var barRightItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.perform {
            $0.barStyle = .default
            $0.barTintColor = UIColor(red: 248.0 / 255.0, green: 229.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
            $0.tintColor = UIColor.purple
        }
        let barHeight = navigationBarHelper.view?.frame.height ?? 0
        titleLabel.frame = CGRect(x: 0, y: 20.0 + (barHeight - 20.0 - 20.0) * 0.5, width: view.frame.width, height: 20)
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.purple
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        navigationBarHelper.view?.addSubview(titleLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTitleViewTap(_:)))
        navigationBarHelper.view?.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        expandNavigationBar(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleTitleViewTap(_ sender: UITapGestureRecognizer) {
        expandNavigationBar(true)
    }
}

extension TimelineViewController: UIScrollViewDelegate {
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        expandNavigationBar(true)
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        if scrollView.isTracking {
            if let lastOffsetY = lastOffsetY, lastOffsetY - currentOffsetY > 0 {
                expandNavigationBar(true)
            } else {
                if currentOffsetY <= -scrollView.contentInset.top - scrollView.adjustedContentInset.top {
                    expandNavigationBar(true)
                } else {
                    collapseNavigationBar(max(-currentOffsetY, 45))
                }
            }
        }
        lastOffsetY = currentOffsetY
    }
}

extension TimelineViewController {
    
    func collapseNavigationBar(_ barHeight: CGFloat) {
        titleLabel.text = "Timeline"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = self.blanBarItem
        self.navigationBarHelper.view?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: barHeight)
    }
    
    func expandNavigationBar(_ animated: Bool) {
        titleLabel.text = nil
        let insetsTop = max(view.safeAreaInsets.top, navigationController?.navigationBar.frame.size.height ?? 0)
        if navigationBarHelper.view?.bounds.height != insetsTop {
            
            func layoutNavigationBar() {
                self.navigationBarHelper.view?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: insetsTop)
            }
            
            func resetNavigationItem() {
                self.navigationItem.rightBarButtonItem = self.barRightItem
                self.navigationItem.leftBarButtonItem = nil
            }
            if animated {
                UIView.animate(withDuration: 0.25, animations: {
                    layoutNavigationBar()
                }) { (completed) in
                    resetNavigationItem()
                }
            } else {
                layoutNavigationBar()
                resetNavigationItem()
            }
        }
    }
}
