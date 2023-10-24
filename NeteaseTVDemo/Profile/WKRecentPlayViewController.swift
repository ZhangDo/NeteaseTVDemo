import UIKit

class WKRecentPlayViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    fileprivate var recentSongListVC = WKRecentSongListVC.creat()
    fileprivate var recentVoiceListVC = WKRencentVoiceListVC.creat()
    static func creat() -> WKRecentPlayViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecentPlayViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChileVC()
    }
    
    func addChileVC() {
        addChild(recentSongListVC)
        contentView.addSubview(recentSongListVC.view)
        recentSongListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(recentVoiceListVC)
        contentView.addSubview(recentVoiceListVC.view)
        recentVoiceListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recentSongListVC.view.isHidden = false
        recentVoiceListVC.view.isHidden = true
        
    }

}

extension WKRecentPlayViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        if item.title == "歌曲" {
            recentSongListVC.view.isHidden = false
            recentVoiceListVC.view.isHidden = true
        } else if item.title == "声音" {
            recentSongListVC.view.isHidden = true
            recentVoiceListVC.view.isHidden = false
        }
    }
}
