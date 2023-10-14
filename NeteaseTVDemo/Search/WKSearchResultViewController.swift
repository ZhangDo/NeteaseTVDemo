//
//  WKSearchResultViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/14.
//

import UIKit

class WKSearchResultViewController: UIViewController {
    private var types: [WKSearchTypeModel] =
    [WKSearchTypeModel(isSelected: true, name: "单曲", type: 1),
     WKSearchTypeModel(isSelected: false, name: "专辑", type: 10),
     WKSearchTypeModel(isSelected: false, name: "歌手", type: 100),
     WKSearchTypeModel(isSelected: false, name: "歌单", type: 1000),
     WKSearchTypeModel(isSelected: false, name: "用户", type: 1002),
     WKSearchTypeModel(isSelected: false, name: "电台", type: 1009)]
    @IBOutlet weak var segmentView: UICollectionView!
    static func creat() -> WKSearchResultViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSearchResultViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentView.register(WKSegmentCell.self, forCellWithReuseIdentifier: String(describing: WKSegmentCell.self))
        segmentView.collectionViewLayout = makeSegmentCollectionViewLayout()
    }
    
    func makeSegmentCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 40
            return section
        }
    }
}

extension WKSearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKSegmentCell.self), for: indexPath) as! WKSegmentCell
        cell.titleLabel.text = types[indexPath.row].name
        cell.selectedView.isHidden = !types[indexPath.row].isSelected
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var i = 0
        var newTypes = [WKSearchTypeModel]()
        for var type in self.types {
            type.isSelected = i == indexPath.row
            i += 1
            newTypes.append(type)
        }
        types = newTypes
        segmentView.reloadData()
    }
}

