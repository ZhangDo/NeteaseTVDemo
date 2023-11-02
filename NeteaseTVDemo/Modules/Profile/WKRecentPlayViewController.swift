import UIKit

class WKRecentPlayViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    fileprivate var recentSongListVC = WKRecentSongListVC.creat()
    fileprivate var recentVoiceListVC = WKRencentVoiceListVC.creat()
    fileprivate var recentPlaylistVC = WKRencentPlaylistVC.creat()
    fileprivate var recentAlbumListVC = WKRecentAlbumListVC.creat()
    fileprivate var recentVideoListVC = WKRecentVideoVC.creat()
    fileprivate var recentPodcastListVC = WKRecentPodcastListVC.creat()
    static func creat() -> WKRecentPlayViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecentPlayViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
    }
    
    func addChildVC() {
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
        
        addChild(recentPlaylistVC)
        contentView.addSubview(recentPlaylistVC.view)
        recentPlaylistVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(recentAlbumListVC)
        contentView.addSubview(recentAlbumListVC.view)
        recentAlbumListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(recentVideoListVC)
        contentView.addSubview(recentVideoListVC.view)
        recentVideoListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(recentPodcastListVC)
        contentView.addSubview(recentPodcastListVC.view)
        recentPodcastListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recentSongListVC.view.isHidden = false
        recentVoiceListVC.view.isHidden = true
        recentPlaylistVC.view.isHidden = true
        recentAlbumListVC.view.isHidden = true
        recentVideoListVC.view.isHidden = true
        recentPodcastListVC.view.isHidden = true
        
    }

}

extension WKRecentPlayViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        if item.title == "歌曲" {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 1.0
                self.recentVoiceListVC.view.alpha = 0.0
                self.recentPlaylistVC.view.alpha = 0.0
                self.recentAlbumListVC.view.alpha = 0.0
                self.recentVideoListVC.view.alpha = 0.0
                self.recentPodcastListVC.view.alpha = 0.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = false
                self.recentVoiceListVC.view.isHidden = true
                self.recentPlaylistVC.view.isHidden = true
                self.recentAlbumListVC.view.isHidden = true
                self.recentVideoListVC.view.isHidden = true
                self.recentPodcastListVC.view.isHidden = true
            }
            
        } else if item.title == "声音" {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 0.0
                self.recentVoiceListVC.view.alpha = 1.0
                self.recentPlaylistVC.view.alpha = 0.0
                self.recentAlbumListVC.view.alpha = 0.0
                self.recentVideoListVC.view.alpha = 0.0
                self.recentPodcastListVC.view.alpha = 0.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = true
                self.recentVoiceListVC.view.isHidden = false
                self.recentPlaylistVC.view.isHidden = true
                self.recentAlbumListVC.view.isHidden = true
                self.recentVideoListVC.view.isHidden = true
                self.recentPodcastListVC.view.isHidden = true
            }
    
        } else if item.title == "歌单" {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 0.0
                self.recentVoiceListVC.view.alpha = 0.0
                self.recentPlaylistVC.view.alpha = 1.0
                self.recentAlbumListVC.view.alpha = 0.0
                self.recentVideoListVC.view.alpha = 0.0
                self.recentPodcastListVC.view.alpha = 0.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = true
                self.recentVoiceListVC.view.isHidden = true
                self.recentPlaylistVC.view.isHidden = false
                self.recentAlbumListVC.view.isHidden = true
                self.recentVideoListVC.view.isHidden = true
                self.recentPodcastListVC.view.isHidden = true
            }
            
        } else if item.title == "专辑" {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 0.0
                self.recentVoiceListVC.view.alpha = 0.0
                self.recentPlaylistVC.view.alpha = 0.0
                self.recentAlbumListVC.view.alpha = 1.0
                self.recentVideoListVC.view.alpha = 0.0
                self.recentPodcastListVC.view.alpha = 0.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = true
                self.recentVoiceListVC.view.isHidden = true
                self.recentPlaylistVC.view.isHidden = true
                self.recentAlbumListVC.view.isHidden = false
                self.recentVideoListVC.view.isHidden = true
                self.recentPodcastListVC.view.isHidden = true
            }
        } else if item.title == "视频"  {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 0.0
                self.recentVoiceListVC.view.alpha = 0.0
                self.recentPlaylistVC.view.alpha = 0.0
                self.recentAlbumListVC.view.alpha = 0.0
                self.recentVideoListVC.view.alpha = 1.0
                self.recentPodcastListVC.view.alpha = 0.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = true
                self.recentVoiceListVC.view.isHidden = true
                self.recentPlaylistVC.view.isHidden = true
                self.recentAlbumListVC.view.isHidden = true
                self.recentVideoListVC.view.isHidden = false
                self.recentPodcastListVC.view.isHidden = true
            }
        } else if item.title == "播客"  {
            UIView.animate(withDuration: 0.2) {
                self.recentSongListVC.view.alpha = 0.0
                self.recentVoiceListVC.view.alpha = 0.0
                self.recentPlaylistVC.view.alpha = 0.0
                self.recentAlbumListVC.view.alpha = 0.0
                self.recentVideoListVC.view.alpha = 0.0
                self.recentPodcastListVC.view.alpha = 1.0
            } completion: { finished in
                self.recentSongListVC.view.isHidden = true
                self.recentVoiceListVC.view.isHidden = true
                self.recentPlaylistVC.view.isHidden = true
                self.recentAlbumListVC.view.isHidden = true
                self.recentVideoListVC.view.isHidden = true
                self.recentPodcastListVC.view.isHidden = false
            }
        }
    }
}
