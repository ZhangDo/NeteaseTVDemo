
import UIKit
import NeteaseRequest

class WKMyCollectionMVVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var mvSublistModels = [NRMVSublistModel]()
    
    static func creat() -> WKMyCollectionMVVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKMyCollectionMVVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(WKMVCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKMVCollectionViewCell.self))
        collectionView.collectionViewLayout = makeVideoCollectionViewLayout()
        Task {
            await loadCollectionMVData()
        }
    }
    
    func loadCollectionMVData() async {
        do {
            mvSublistModels = try await fetchMVSublist(cookie: cookie).filter({ model in
                return model.type == 0
            })
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func makeVideoCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
    }
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        
        //        let style = styleOverride ?? Settings.displayStyle
        //        let heightDimension = NSCollectionLayoutDimension.estimated(380)
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1)
        ))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalWidth(1/5)
        ), repeatingSubitem: item, count: 3)
        let vSpacing: CGFloat =  16
        let baseSpacing: CGFloat = 24
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(baseSpacing), top: .fixed(vSpacing), trailing: .fixed(0), bottom: .fixed(vSpacing))
        let section = NSCollectionLayoutSection(group: group)
        if baseSpacing > 0 {
            section.contentInsets = NSDirectionalEdgeInsets(top: baseSpacing, leading: 0, bottom: 0, trailing: hSpacing)
        }
        return section
    }
}
extension WKMyCollectionMVVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mvSublistModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKMVCollectionViewCell.self), for: indexPath) as! WKMVCollectionViewCell
        cell.coverImageView.kf.setImage(with: URL(string: mvSublistModels[indexPath.row].coverUrl))
        cell.titleLabel.text = mvSublistModels[indexPath.row].title
        let min = mvSublistModels[indexPath.row].durationms / 1000 / 60
        let sec = mvSublistModels[indexPath.row].durationms / 1000 % 60
        cell.duartionLabel.text = String(format: "%02d:%02d", min, sec)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: Int(mvSublistModels[indexPath.row].vid)!, r: 1080, isMV: true))
        self.present(videoPlayerVC, animated: true)
    }
}
