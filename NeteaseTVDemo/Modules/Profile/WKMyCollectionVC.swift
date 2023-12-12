import UIKit

class WKMyCollectionVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    fileprivate var myCollectionPlaylistVC = WKMyCollectionPlaylistVC.creat()
    fileprivate var myCollectionAlbumVC = WKMyCollectionAlbumVC.creat()
    fileprivate var myCollectionPodcastVC = WKMyCollectionPodcastVC.creat()
    fileprivate var myCollectionMVVC = WKMyCollectionMVVC.creat()
    
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
        
        addChild(myCollectionAlbumVC)
        contentView.addSubview(myCollectionAlbumVC.view)
        myCollectionAlbumVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(myCollectionPodcastVC)
        contentView.addSubview(myCollectionPodcastVC.view)
        myCollectionPodcastVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(myCollectionMVVC)
        contentView.addSubview(myCollectionMVVC.view)
        myCollectionMVVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        myCollectionPlaylistVC.view.isHidden = false
        myCollectionAlbumVC.view.isHidden = true
        myCollectionPodcastVC.view.isHidden = true
        myCollectionMVVC.view.isHidden = true
    }

}

extension WKMyCollectionVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        if item.title == "歌单" {
            myCollectionPlaylistVC.view.isHidden = false
            myCollectionAlbumVC.view.isHidden = true
            myCollectionPodcastVC.view.isHidden = true
            myCollectionMVVC.view.isHidden = true
        } else if item.title == "专辑" {
            myCollectionPlaylistVC.view.isHidden = true
            myCollectionAlbumVC.view.isHidden = false
            myCollectionPodcastVC.view.isHidden = true
            myCollectionMVVC.view.isHidden = true
        } else if item.title == "播客" {
            myCollectionPlaylistVC.view.isHidden = true
            myCollectionAlbumVC.view.isHidden = true
            myCollectionPodcastVC.view.isHidden = false
            myCollectionMVVC.view.isHidden = true
        } else if item.title == "MV" {
            myCollectionPlaylistVC.view.isHidden = true
            myCollectionAlbumVC.view.isHidden = true
            myCollectionPodcastVC.view.isHidden = true
            myCollectionMVVC.view.isHidden = false
        }
    }
}
