//
//  WKSingerDetailViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/17.
//

import UIKit
import NeteaseRequest
class WKSingerDetailViewController: UIViewController {
    
    private var singerId: Int!
    @IBOutlet weak var singerNameLabel: UILabel!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var fansCountLabel: UILabel!
    @IBOutlet weak var identifyLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var singerImageView: UIImageView!
    
    @IBOutlet weak var listBgView: UIView!
    private var songListVC: WKSongListViewController!
    private var albumListVC: WKSingerDetailAlbumListVC!
    
    static func creat(singerId: Int) -> WKSingerDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSingerDetailViewController
        vc.singerId = singerId
        vc.songListVC = WKSongListViewController.creat(singerId: singerId)
        vc.albumListVC = WKSingerDetailAlbumListVC.creat(singerId: singerId)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(songListVC)
        listBgView.addSubview(songListVC.view)
        songListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addChild(albumListVC)
        listBgView.addSubview(albumListVC.view)
        albumListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        albumListVC.view.isHidden = true
        
        Task {
            await loadSingerDetail()
        }
    }
    
    func loadSingerDetail() async {
        do {
            let singerDetail: NRArtistDetailModel = try await fetchArtistDetail(id: singerId)
            self.singerImageView.kf.setImage(with: URL(string: singerDetail.artist?.cover ?? ""))
            self.singerNameLabel.text = singerDetail.artist?.name
            self.aliasLabel.text = "JJ Lin"
            self.fansCountLabel.text = "1056.3万粉丝"
            self.identifyLabel.text = singerDetail.identify?.imageDesc
            self.descLabel.text = singerDetail.artist?.briefDesc
        } catch {
            print(error)
        }
    }
}

extension WKSingerDetailViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "单曲" {
            songListVC.view.isHidden = false
            albumListVC.view.isHidden = true
        } else if item.title == "专辑" {
            songListVC.view.isHidden = true
            albumListVC.view.isHidden = false
        } else if item.title == "视频" {
            songListVC.view.isHidden = true
            albumListVC.view.isHidden = true
        }
    }
}
