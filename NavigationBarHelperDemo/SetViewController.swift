//
//  SetViewController.swift
//  NavigationBarTransitionHandler
//
//  Created by Jerry Wong on 2018/3/9.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarHelper

class SetViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.tintColor = UIColor.blue
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bar_background"), for: .default)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
