
import UIKit
import NeteaseRequest

class WKSongCollectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var allModels: [CustomAudioModel] = [CustomAudioModel]()
    
    static func creat() -> WKSongCollectionVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSongCollectionVC
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(WKSongCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKSongCollectionViewCell.self))
        collectionView.collectionViewLayout = makeSongCollectionViewLayout()
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            if  let userModel: NRProfileModel = UserDefaults.standard.codable(forKey: "userModel") {
                let playList:[NRPlayListModel] = try await fetchUserPlaylist(cookie: cookie, uid: userModel.userId, limit: 1000).filter { model in
                    model.userId == userModel.userId
                }
                
                guard playList.count > 0 else {
                    return
                }
                
                
                let songModels:[NRSongModel] = try await fetchPlayListTrackAll(cookie: cookie, id: playList.first?.id ?? 0,limit: 500)
                self.allModels.removeAll()
                for songModel in songModels {
                    let model = CustomAudioModel()
                    model.audioId = songModel.id
                    model.like = likeIds.contains(songModel.id)
                    model.isFree = 1
                    model.freeTime = 0
                    model.audioTitle = songModel.name
                    model.audioPicUrl = songModel.al?.picUrl
                    
                    let min = (songModel.dt ?? 0) / 1000 / 60
                    let sec = (songModel.dt ?? 0) / 1000 % 60
                    model.audioTime = String(format: "%d:%02d", min, sec)
                    if let singerModel = songModel.ar {
                        model.singer = singerModel.map { $0.name ?? "" }.joined(separator: "/")
                    }
                    self.allModels.append(model)
                }
                collectionView.reloadData()
            }
        } catch {
            print(error)
        }
    }

}

extension WKSongCollectionVC {
    func makeSongCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
    }
    
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1)))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalWidth(1/10)
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

extension WKSongCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKSongCollectionViewCell.self), for: indexPath) as! WKSongCollectionViewCell
        cell.loadData(with: allModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wk_player.allOriginalModels = self.allModels
        try? wk_player.play(index: indexPath.row)
        enterPlayer()
    }
    
    func enterPlayer() {
        let playingVC = WKPlayingViewController.creat()
        playingVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playingVC, animated: true)
    }
}
