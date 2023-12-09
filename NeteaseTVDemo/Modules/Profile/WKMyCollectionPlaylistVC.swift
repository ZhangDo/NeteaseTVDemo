import UIKit
import NeteaseRequest
class WKMyCollectionPlaylistVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var playList = [NRPlayListModel]()
    static func creat() -> WKMyCollectionPlaylistVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKMyCollectionPlaylistVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        collectionView.collectionViewLayout = makeRencentPlaylistCollectionViewLayout()
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            if  let userModel: NRProfileModel = UserDefaults.standard.codable(forKey: "userModel") {
                playList = try await fetchUserPlaylist(cookie: cookie, uid: userModel.userId, limit: 1000).filter { model in
                    model.userId != userModel.userId
                }
                collectionView.reloadData()
            }
        } catch {
            print(error)
        }
    }

}


extension WKMyCollectionPlaylistVC {
    
    func makeRencentPlaylistCollectionViewLayout () -> UICollectionViewLayout {
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
            heightDimension:.fractionalWidth(1/3)
        ), repeatingSubitem: item, count: 3)
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

extension WKMyCollectionPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
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
