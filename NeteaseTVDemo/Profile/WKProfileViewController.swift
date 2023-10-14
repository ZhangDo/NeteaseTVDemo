//
//  WKProfileViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/13.
//

import UIKit
import TVUIKit
import NeteaseRequest
class WKProfileViewController: UIViewController {

    @IBOutlet weak var userHeaderView: TVMonogramView!
    
    static func creat() -> WKProfileViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKProfileViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userHeaderView.contentMode = .scaleAspectFill
        Task {
            await loadUserInfo()
        }
    }
    
    
    func loadUserInfo() async {
        do {
            let userIno: NRProfileModel = try await fetchAccountInfo(cookie: cookie)
            self.userHeaderView.kf.setImage(with: URL(string: userIno.avatarUrl))
            self.userHeaderView.title = userIno.nickname
            print(userIno)
        } catch {
            print(error)
        }
    }
    
    @IBAction func changeAccount(_ sender: Any) {
        print("切换账号")
    }
}
