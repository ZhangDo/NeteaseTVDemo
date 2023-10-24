
import UIKit
import NeteaseRequest

class WKRecentVideoVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var videoList = [NRVideoModel]()
    static func creat() -> WKRecentVideoVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecentVideoVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(WKMVCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKMVCollectionViewCell.self))
        collectionView.collectionViewLayout = makeVideoCollectionViewLayout()
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let recentModel: NRRecentPlayModel = try await fetchRecentVideo(cookie: cookie, limit: 1000)
            videoList = recentModel.list.map({ model in
                model.data
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
            heightDimension:.fractionalWidth(0.2)
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

extension WKRecentVideoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKMVCollectionViewCell.self), for: indexPath) as! WKMVCollectionViewCell
        cell.coverImageView.kf.setImage(with: URL(string: videoList[indexPath.row].coverUrl ?? ""))
        cell.titleLabel.text = videoList[indexPath.row].title
        let min = videoList[indexPath.row].duration! / 1000 / 60
        let sec = videoList[indexPath.row].duration! / 1000 % 60
        cell.duartionLabel.text = String(format: "%02d:%02d", min, sec)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: Int(videoList[indexPath.row].vid!)!, r: 1080, isMV: true))
        self.present(videoPlayerVC, animated: true)
    }
}
