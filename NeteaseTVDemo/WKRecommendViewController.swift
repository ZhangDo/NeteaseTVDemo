//
//  WKRecommendViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit
import NeteaseRequest
import Kingfisher
class WKRecommendViewController: UIViewController,FSPagerViewDataSource,FSPagerViewDelegate {

    @IBOutlet weak var DailyRecommendView: UICollectionView!
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    fileprivate var banners: [NRBannerModel]?
    fileprivate var dailyPlaylist: [NRRecommendPlayListModel]?
    
    @IBOutlet weak var bannerView: FSPagerView! {
        didSet {
            self.bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.bannerView.itemSize = FSPagerView.automaticSize
            let transform = CGAffineTransform(scaleX: 0.4, y: 0.75)
            self.bannerView.itemSize = self.bannerView.frame.size.applying(transform)
            self.bannerView.decelerationDistance = FSPagerView.automaticDistance
            self.bannerView.interitemSpacing = 100
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DailyRecommendView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        DailyRecommendView.collectionViewLayout = makeDailyRecommendCollectionViewLayout()
        
        
        Task {
            await loadData()
            self.bannerView.reloadData()
            self.DailyRecommendView.reloadData()
        }
        
        
    }
    
    func loadData() async  {
        self.banners = try! await fetchBanners().filter({ model in
            model.targetType != 3000
        })
        
        self.dailyPlaylist = try! await fetchRecommendPlayList(cookie: cookie)
    }
    

    // MARK:- FSPagerView DataSource
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.banners?.count ?? 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.kf.setImage(with: URL(string: self.banners![index].pic ))
//        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = self.banners![index].typeTitle
        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        print(self.banners![index])
        if self.banners![index].targetType == 1 {
            let model = CustomAudioModel()
            model.audioId = self.banners![index].song?.id
            model.audioTitle = self.banners![index].song?.name
            model.audioPicUrl = self.banners![index].pic
            model.isFree = 1
            wk_player.allOriginalModels = [model]
            try? wk_player.play(index: 0)
            let playingVC = ViewController.creat()
            playingVC.modalPresentationStyle = .blurOverFullScreen
            self.present(playingVC, animated: true)
        }
        
//        let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: 7780071743)
//        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
//        self.present(playListDetaiVC, animated: true)
    }
    
}


extension WKRecommendViewController {
    func makeDailyRecommendCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 40
            return section
        }
    }
}


extension WKRecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dailyPlaylist?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
        cell.playListCover.kf.setImage(with: URL(string: self.dailyPlaylist![indexPath.row].picUrl!))
        cell.titleLabel.text = self.dailyPlaylist![indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: self.dailyPlaylist![indexPath.row].id)
        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playListDetaiVC, animated: true)
    }
    
    
}
