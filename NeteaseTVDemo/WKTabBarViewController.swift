
import UIKit

class WKTabBarViewController: UITabBarController {
    
    static func creat() -> WKTabBarViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKTabBarViewController
        vc.modalPresentationStyle = .blurOverFullScreen
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var vcs = [UIViewController]()
        
        let recommendVC = WKRecommendViewController.creat()
        recommendVC.tabBarItem.title = "推荐"
        vcs.append(recommendVC)
        
        let findVC = WKFindViewController.creat()
        findVC.tabBarItem.title = "浏览"
        vcs.append(findVC)
        
        let podcastVC = WKPodcastViewController.creat()
        podcastVC.tabBarItem.title = "播客"
        vcs.append(podcastVC)
        
        let mvVC = WKMVViewController.creat()
        mvVC.tabBarItem.title = "MV"
        vcs.append(mvVC)
        
        let playingVC = ViewController.creat()
        playingVC.tabBarItem.title = "正在播放"
        vcs.append(playingVC)
        
        let profileVC = WKProfileViewController.creat()
        profileVC.tabBarItem.title = "我的"
        vcs.append(profileVC)
        
        let searchVC = WKSearchViewController()
        searchVC.tabBarItem.title = "搜索"
        vcs.append(searchVC)
        
        setViewControllers(vcs, animated: false)
        
    }
    
}
