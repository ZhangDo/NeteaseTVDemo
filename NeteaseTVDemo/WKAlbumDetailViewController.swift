//
//  WKAlbumDetailViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/25.
//

import UIKit
import NeteaseRequest
class WKAlbumDetailViewController: UIViewController {
    
    static func creat(playListId: Int) -> WKAlbumDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKAlbumDetailViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
