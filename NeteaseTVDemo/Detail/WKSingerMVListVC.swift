
import UIKit
import NeteaseRequest
class WKSingerMVListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var singerId: Int!
    private var singerMVs = [NRMVListModel]()
    static func creat(singerId: Int) -> WKSingerMVListVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSingerMVListVC
        vc.singerId = singerId
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(WKMVCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKMVCollectionViewCell.self))
        collectionView.collectionViewLayout = makeSingerMVCollectionViewLayout()
        Task {
            await loadData()
            collectionView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            singerMVs = try await fetchArtistMV(id: singerId)
        } catch {
            print(error)
        }
    }
    
    func makeSingerMVCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
    }
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        
        //        let style = styleOverride ?? Settings.displayStyle
        //        let heightDimension = NSCollectionLayoutDimension.estimated(380)
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/2),
            heightDimension: .fractionalHeight(1)
        ))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalWidth(0.3)
        ), repeatingSubitem: item, count: 2)
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

extension WKSingerMVListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singerMVs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKMVCollectionViewCell.self), for: indexPath) as! WKMVCollectionViewCell
        cell.coverImageView.kf.setImage(with: URL(string: singerMVs[indexPath.row].imgurl16v9 ?? ""))
        cell.titleLabel.text = singerMVs[indexPath.row].name 
        let min = singerMVs[indexPath.row].duration / 1000 / 60
        let sec = singerMVs[indexPath.row].duration / 1000 % 60
        cell.duartionLabel.text = String(format: "%02d:%02d", min, sec)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: singerMVs[indexPath.row].id, r: 1080))
        self.present(videoPlayerVC, animated: true)
    }
}
