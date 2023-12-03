import UIKit
import NeteaseRequest
class WKMVViewController: UIViewController {
    
    fileprivate var mvModelList = [NRMVListModel]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var mvAreas = ["全部","内地","港台","欧美","日本","韩国"]
    static func creat() -> WKMVViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKMVViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        collectionView.register(WKMVCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKMVCollectionViewCell.self))
        collectionView.collectionViewLayout = makeMVCollectionViewLayout()
        Task {
            await loadData()
            collectionView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            mvModelList = try await fetchAllMV()
            print(mvModelList)
        } catch {
            self.showAlert(error.localizedDescription)
        }
    }
    
    func makeMVCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
    }
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1)
        ))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalWidth(0.195)
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

extension WKMVViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mvAreas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = mvAreas[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = mvAreas[indexPath.row]
        Task {
            do {
                mvModelList = try await fetchAllMV(area: area)
                print(mvModelList)
                collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

extension WKMVViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mvModelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKMVCollectionViewCell.self), for: indexPath) as! WKMVCollectionViewCell
        cell.coverImageView.kf.setImage(with: URL(string: mvModelList[indexPath.row].cover ?? ""))
        cell.titleLabel.text = mvModelList[indexPath.row].name
        let min = mvModelList[indexPath.row].duration / 1000 / 60
        let sec = mvModelList[indexPath.row].duration / 1000 % 60
        cell.duartionLabel.text = String(format: "%02d:%02d", min, sec)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (wk_player.isPlaying) {
            wk_player.pausePlayer()
        }
        let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: mvModelList[indexPath.row].id, r: 1080, isMV: true))
        self.present(videoPlayerVC, animated: true)
    }
}
