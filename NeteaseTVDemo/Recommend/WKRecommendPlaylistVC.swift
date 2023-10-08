//
//  WKRecommendPlaylistVC.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/8.
//

import UIKit
import NeteaseRequest
import Kingfisher
class WKRecommendPlaylistVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var recommendPlayList:[NRRecommendPlayListModel]?
    
    static func creat() -> WKRecommendPlaylistVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecommendPlaylistVC
        vc.modalPresentationStyle = .blurOverFullScreen
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        collectionView.collectionViewLayout = makeRecommendCollectionViewLayout()
        Task {
            await loadData()
        }
    }
    
    func loadData() async  {
        self.recommendPlayList = try! await fetchPersonalizedPlayList(cookie: cookie, limit: 1000)
        self.collectionView.reloadData()
    }

}

extension WKRecommendPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendPlayList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
        cell.playListCover.kf.setImage(with: URL(string: self.recommendPlayList![indexPath.row].picUrl!))
        cell.titleLabel.text = self.recommendPlayList![indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: self.recommendPlayList![indexPath.row].id)
        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playListDetaiVC, animated: true)
    }
    
}

extension WKRecommendPlaylistVC {
    
    func makeRecommendCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
    }
    
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        
//        let style = styleOverride ?? Settings.displayStyle
        let heightDimension = NSCollectionLayoutDimension.estimated(380)
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

        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(44))
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
