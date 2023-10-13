//
//  WKPodcastViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/12.
//

import UIKit
import NeteaseRequest

class WKPodcastViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var djCatelist = [NRDJCatelistModel]()
    var djHotRadios = [NRDJRadioModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        collectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        collectionView.collectionViewLayout = makeRecommendCollectionViewLayout()
        Task {
            await loadData()
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            djCatelist = try await fetchDJCatelist()
            print(djCatelist)
            
            djHotRadios = try await fetchDJHotRadio(cateId: djCatelist.first?.id ?? 0)
//            print(djHotRadios.first!)
            
        } catch {
            print(error)
        }
    }

}

extension WKPodcastViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return djCatelist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = djCatelist[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cat = djCatelist[indexPath.row].id
        Task {
            djHotRadios = try await fetchDJHotRadio(cateId: cat)
            collectionView.reloadData()
        }
    }
}

extension WKPodcastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return djHotRadios.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
        cell.playListCover.kf.setImage(with: URL(string: djHotRadios[indexPath.row].picUrl))
        cell.titleLabel.text = djHotRadios[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playListDetaiVC = WKPodcastDetailViewController.creat(djRadioModel: djHotRadios[indexPath.row])
        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playListDetaiVC, animated: true)
    }
}

extension WKPodcastViewController {
    
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
