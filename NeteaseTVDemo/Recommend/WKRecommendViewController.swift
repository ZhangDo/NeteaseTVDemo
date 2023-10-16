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

    @IBOutlet weak var dailyRecommendView: UICollectionView!
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    fileprivate var banners: [NRBannerModel]?
    fileprivate var dailyPlaylist: [NRRecommendPlayListModel]?
    fileprivate var dailyAudioModels: [CustomAudioModel] = [CustomAudioModel]()
    
    @IBOutlet weak var recommendView: UICollectionView!
    fileprivate var recommendPlayList:[NRRecommendPlayListModel]?
    @IBOutlet weak var songView1: WKSingleSongView!
    @IBOutlet weak var songView2: WKSingleSongView!
    @IBOutlet weak var songView3: WKSingleSongView!
    @IBOutlet weak var songView4: WKSingleSongView!
    @IBOutlet weak var songView5: WKSingleSongView!
    @IBOutlet weak var songView6: WKSingleSongView!
    @IBOutlet weak var songView7: WKSingleSongView!
    @IBOutlet weak var songView8: WKSingleSongView!
    @IBOutlet weak var songView9: WKSingleSongView!
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
    
    static func creat() -> WKRecommendViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecommendViewController
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyRecommendView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        dailyRecommendView.collectionViewLayout = makeDailyRecommendCollectionViewLayout()
        
        recommendView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        recommendView.collectionViewLayout = makeRecommendCollectionViewLayout()
        recommendView.isScrollEnabled = false
        
        Task {
            await loadData()
        }
        
    }
    
    func loadData() async  {
        do {
            self.banners = try await fetchBanners().filter({ model in
                model.targetType != 3000
            })
            self.bannerView.reloadData()
        } catch {
            print(error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.banners!.count > 1 {
                self.bannerView.scrollToItem(at: 1, animated: true)
            }
            
        }
        do {
            self.dailyPlaylist = try await fetchRecommendPlayList(cookie: cookie)
            self.dailyRecommendView.reloadData()
        } catch {
            print(error)
        }
        
        do {
            let dailySongs = try await fetchDailtSongs(cookie: cookie).dailySongs
            self.dailyAudioModels.removeAll()
            for songModel in dailySongs {
                let model = CustomAudioModel()
                model.audioId = songModel.id
                model.isFree = 1
                model.freeTime = 0
                model.audioTitle = songModel.name
                model.audioPicUrl = songModel.al?.picUrl
                if let singerModel = songModel.ar {
                    model.singer = singerModel.map { $0.name! }.joined(separator: "/")
                }
                self.dailyAudioModels.append(model)
            }
            self.songView1.setModel(audioModel: self.dailyAudioModels[0])
            self.songView1.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 0)
                self!.enterPlayer()
            }
                
            self.songView2.setModel(audioModel: self.dailyAudioModels[1])
            self.songView2.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 1)
                self!.enterPlayer()
            }
            self.songView3.setModel(audioModel: self.dailyAudioModels[2])
            self.songView3.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 2)
                self!.enterPlayer()
            }
            self.songView4.setModel(audioModel: self.dailyAudioModels[3])
            self.songView4.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 3)
                self!.enterPlayer()
            }
            self.songView5.setModel(audioModel: self.dailyAudioModels[4])
            self.songView5.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 4)
                self!.enterPlayer()
            }
            self.songView6.setModel(audioModel: self.dailyAudioModels[5])
            self.songView6.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 5)
                self!.enterPlayer()
            }
            self.songView7.setModel(audioModel: self.dailyAudioModels[6])
            self.songView7.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 6)
                self!.enterPlayer()
            }
            self.songView8.setModel(audioModel: self.dailyAudioModels[7])
            self.songView8.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 7)
                self!.enterPlayer()
            }
            self.songView9.setModel(audioModel: self.dailyAudioModels[8])
            self.songView9.onPrimaryAction = { [weak self] model in
                wk_player.allOriginalModels = self!.dailyAudioModels
                try? wk_player.play(index: 8)
                self!.enterPlayer()
            }
        } catch {
            print(error)
        }
        
        do {
            self.recommendPlayList = try await fetchPersonalizedPlayList(cookie: cookie)
            self.recommendView.reloadData()
        } catch {
            print(error)
        }
        
        
        
    }
    
    func enterPlayer() {
        let playingVC = ViewController.creat()
        playingVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playingVC, animated: true)
    }
    
    @IBAction func moreRecommendPlaylist(_ sender: Any) {
        print("更多歌单")
        let vc = WKRecommendPlaylistVC.creat()
        self.present(vc, animated: true)
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
        } else if self.banners![index].targetType == 10 {
            let albumVC = WKAlbumDetailViewController.creat(playListId: self.banners![index].targetId!)
            albumVC.modalPresentationStyle = .blurOverFullScreen
            self.present(albumVC, animated: true)
        }
        
//        let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: 7780071743)
//        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
//        self.present(playListDetaiVC, animated: true)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.type == .playPause {
                Task {
                    await self.loadData()
                    self.dailyRecommendView.reloadData()
                    self.recommendView.reloadData()
                }
            }
        }
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
    
    func makeRecommendCollectionViewLayout () -> UICollectionViewLayout {
        
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
        

    }
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        
//        let style = styleOverride ?? Settings.displayStyle
//        let heightDimension = NSCollectionLayoutDimension.estimated(380)
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalHeight(1)
        ))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalWidth(0.25/1.15)
        ), repeatingSubitem: item, count: 4)
        let vSpacing: CGFloat =  16
        let baseSpacing: CGFloat = 24
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(baseSpacing), top: .fixed(vSpacing), trailing: .fixed(0), bottom: .fixed(vSpacing))
        let section = NSCollectionLayoutSection(group: group)
        if baseSpacing > 0 {
            section.contentInsets = NSDirectionalEdgeInsets(top: baseSpacing, leading: 0, bottom: 0, trailing: 0)
        }

//        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .estimated(44))
//        if showHeader {
//            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: titleSize,
//                elementKind: TitleSupplementaryView.reuseIdentifier,
//                alignment: .top
//            )
//            section.boundarySupplementaryItems = [titleSupplementary]
//        }
        return section
    }

    
}


extension WKRecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case dailyRecommendView:
            return self.dailyPlaylist?.count ?? 0
        case recommendView:
            return self.recommendPlayList?.count ?? 0
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case dailyRecommendView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
            cell.playListCover.kf.setImage(with: URL(string: self.dailyPlaylist![indexPath.row].picUrl!))
            cell.titleLabel.text = self.dailyPlaylist![indexPath.row].name
            return cell
        case recommendView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
            cell.playListCover.kf.setImage(with: URL(string: self.recommendPlayList![indexPath.row].picUrl!))
            cell.titleLabel.text = self.recommendPlayList![indexPath.row].name
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dailyRecommendView {
            let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: self.dailyPlaylist![indexPath.row].id)
            playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
            self.present(playListDetaiVC, animated: true)
        } else {
            let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: self.recommendPlayList![indexPath.row].id)
            playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
            self.present(playListDetaiVC, animated: true)
        }
        
    }
    
    
}
