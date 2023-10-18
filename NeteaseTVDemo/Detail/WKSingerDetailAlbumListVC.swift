import UIKit
import NeteaseRequest
class WKSingerDetailAlbumListVC: UIViewController {

    @IBOutlet weak var albumCollectionView: UICollectionView!
    private var singerId: Int!
    private var singerAlbums = [NRAlbumModel]()
    static func creat(singerId: Int) -> WKSingerDetailAlbumListVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSingerDetailAlbumListVC
        vc.singerId = singerId
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        albumCollectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        albumCollectionView.collectionViewLayout = makeSingerAlbumCollectionViewLayout()
        
        Task {
            await loadData()
            albumCollectionView.reloadData()
        }
        
    }
    
    func loadData() async {
        do {
            singerAlbums = try await fetchArtistAlbum(id: singerId, limit: 100)
        } catch {
            print(error)
        }
    }
    
    func makeSingerAlbumCollectionViewLayout () -> UICollectionViewLayout {
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
            heightDimension:.fractionalWidth(0.4)
        ), repeatingSubitem: item, count: 2)
        let vSpacing: CGFloat =  16
        let baseSpacing: CGFloat = 24
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(baseSpacing), top: .fixed(vSpacing), trailing: .fixed(0), bottom: .fixed(vSpacing))
        let section = NSCollectionLayoutSection(group: group)
        if baseSpacing > 0 {
            section.contentInsets = NSDirectionalEdgeInsets(top: baseSpacing, leading: 0, bottom: 0, trailing: 0)
        }
        return section
    }

}

extension WKSingerDetailAlbumListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singerAlbums.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
        cell.playListCover.kf.setImage(with: URL(string: singerAlbums[indexPath.row].picUrl ?? ""))
        cell.titleLabel.text = singerAlbums[indexPath.row].name ?? ""
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumVC = WKAlbumDetailViewController.creat(playListId: (singerAlbums[indexPath.row].id)!)
        albumVC.modalPresentationStyle = .blurOverFullScreen
        self.present(albumVC, animated: true)
    }
}
