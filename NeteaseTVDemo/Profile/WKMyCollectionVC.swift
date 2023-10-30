import UIKit

class WKMyCollectionVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    fileprivate var myCollectionPlaylistVC = WKMyCollectionPlaylistVC.creat()
    
    static func creat() -> WKMyCollectionVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKMyCollectionVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(myCollectionPlaylistVC)
        contentView.addSubview(myCollectionPlaylistVC.view)
        myCollectionPlaylistVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension WKMyCollectionVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        if item.title == "歌单" {
            myCollectionPlaylistVC.view.isHidden = false
        } else if item.title == "专辑" {
            
        } else if item.title == "播客" {
            
        }
    }
}
