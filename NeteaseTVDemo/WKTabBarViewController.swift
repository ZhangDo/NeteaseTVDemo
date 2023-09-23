//
//  WKTabBarViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit

class WKTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        guard let buttonPress = presses.first?.type else { return }
//        if buttonPress == .playPause {
//            if let reloadVC = topMostViewController() as? BLTabBarContentVCProtocol {
//                print("send reload to \(reloadVC)")
//                reloadVC.reloadData()
//            }
//        }
    }

}
