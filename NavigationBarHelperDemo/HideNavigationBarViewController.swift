//
//  HideNavigationBarViewController.swift
//  NavigationBarHelperDemo
//
//  Created by 王杰 on 2018/12/28.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import UIKit
import NavigationBarHelper

class HideNavigationBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHelper.perform { _ in
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    @IBAction func didClickPopBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
