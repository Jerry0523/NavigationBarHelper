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
        navigationBarHelper.perform {
            $0.barStyle = .default
            $0.tintColor = UIColor.red
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "pushAccount", sender: nil)
        case 1:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

}
