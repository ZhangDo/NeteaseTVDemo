//
//  WKTabBarViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit

class WKTabBarViewController: UITabBarController {
    
    static func creat() -> WKTabBarViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKTabBarViewController
        vc.modalPresentationStyle = .blurOverFullScreen
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
