//
//  WKFindViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/11.
//

import UIKit
import NeteaseRequest
class WKFindViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var categories = [WKFindModel]()
    var playList = [NRPlayListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        collectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        collectionView.collectionViewLayout = makeRecommendCollectionViewLayout()
        
        
        Task {
            await loadData()
            tableView.reloadData()
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            
            let cat = categories.first!.cateInfoModels.first?.name
            playList = (try? await fetchTopPlayList(order: .hot, cat: cat!)) ?? []
            collectionView.reloadData()
        }
        
        
    }
    
    func loadData() async {
        do {
            let catListModel: NRCatModel = try await fetchPlayCatList()
            for (key, value) in catListModel.categories.sorted(by: { $0.key < $1.key }) {
                print("Key: \(key), Value: \(value)")
                let sub:[NRCatInfoModel] = catListModel.sub
                let filterModels: [NRCatInfoModel] = sub.filter { model in
                    model.category == Int(key)
                }
                let findModel = WKFindModel(title: value, cateInfoModels: filterModels)
                categories.append(findModel)
            }
        } catch {
            print(error)
        }
        
        
        
    }


}

extension WKFindViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories[section].cateInfoModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        var content = header?.defaultContentConfiguration()
        content?.text = categories[section].title
        header?.contentConfiguration = content
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.section].cateInfoModels[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cat = categories[indexPath.section].cateInfoModels[indexPath.row].name
        Task {
            playList = (try? await fetchTopPlayList(order: .hot, cat: cat)) ?? []
            collectionView.reloadData()
        }
    }
}

extension WKFindViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
        cell.playListCover.kf.setImage(with: URL(string: playList[indexPath.row].coverImgUrl!))
        cell.titleLabel.text = playList[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: playList[indexPath.row].id)
        playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playListDetaiVC, animated: true)
    }
}

extension WKFindViewController {
    
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
