//
//  ListViewController.swift
//  NavigationBarTransitionHandler
//
//  Created by Jerry Wong on 2018/3/8.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarHelper

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.tintColor = UIColor.red
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
