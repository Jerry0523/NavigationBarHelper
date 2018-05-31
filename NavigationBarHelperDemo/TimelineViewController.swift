//
//  TimelineViewController.swift
//  NavigationBarHelperDemo
//
//  Created by 王杰 on 2018/5/29.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {
    
    let titleLabel = UILabel()
    
    let blanBarItem = UIBarButtonItem()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var barRightItem: UIBarButtonItem!
    
    var lastOffsetY = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 248.0 / 255.0, green: 229.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
            self.navigationController?.navigationBar.tintColor = UIColor.purple
        }
        titleLabel.frame = CGRect(x: 0, y: (navigationBarHelper.view?.frame.height ?? 0) - 25.0, width: view.frame.width, height: 25.0)
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.purple
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        navigationBarHelper.view?.addSubview(titleLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        expandNavigationBar(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TimelineViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        if abs(currentOffsetY - lastOffsetY) < 20 {
            return
        }
        
        if currentOffsetY <= -scrollView.contentInset.top - scrollView.adjustedContentInset.top || currentOffsetY < lastOffsetY {
            expandNavigationBar(true)
        } else {
            collapseNavigationBar()
        }
        lastOffsetY = currentOffsetY
    }
}

extension TimelineViewController {
    
    func collapseNavigationBar() {
        titleLabel.text = "Timeline"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = self.blanBarItem
        if navigationBarHelper.view?.bounds.height ?? 0 > 40 {
            UIView.animate(withDuration: 0.25, animations: {
                self.navigationBarHelper.view?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
            })
        }
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
