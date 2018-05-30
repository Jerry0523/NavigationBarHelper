//
//  ViewController.swift
//  NavigationBarTransitionHandlerDemo
//
//  Created by Jerry Wong on 2018/2/28.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarHelper

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

