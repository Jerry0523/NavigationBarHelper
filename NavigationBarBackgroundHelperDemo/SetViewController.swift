//
//  SetViewController.swift
//  NavigationBarTransitionHandler
//
//  Created by 王杰 on 2018/3/9.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarBackgroundHelper

class SetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        barBackgroundHelper.performNavigationBarUpdates {
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.tintColor = UIColor.blue
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bar_background"), for: .default)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
