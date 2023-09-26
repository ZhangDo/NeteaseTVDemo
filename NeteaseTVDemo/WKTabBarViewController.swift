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
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.type == .playPause {
                if wk_player.state == .paused {
                    wk_player.resumePlayer()
                } else if  wk_player.state == .isPlaying {
                    wk_player.pausePlayer()
                }
            }
        }
    }

}
