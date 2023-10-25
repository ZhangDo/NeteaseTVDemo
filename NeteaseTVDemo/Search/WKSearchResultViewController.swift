
import UIKit
import NeteaseRequest
class WKSearchResultViewController: UIViewController {
    private var types: [WKSearchTypeModel] =
    [WKSearchTypeModel(isSelected: true, name: "单曲", type: 1),
     WKSearchTypeModel(isSelected: false, name: "专辑", type: 10),
     WKSearchTypeModel(isSelected: false, name: "歌手", type: 100),
     WKSearchTypeModel(isSelected: false, name: "歌单", type: 1000),
     WKSearchTypeModel(isSelected: false, name: "用户", type: 1002),
     WKSearchTypeModel(isSelected: false, name: "电台", type: 1009),
     WKSearchTypeModel(isSelected: false, name: "MV", type: 1004),
     WKSearchTypeModel(isSelected: false, name: "视频", type: 1014)]
    var query: String?
    private var searchResult: NRSearchModel?
    fileprivate var audioModels: [CustomAudioModel] = [CustomAudioModel]()
    @IBOutlet weak var segmentView: UICollectionView!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    private var currentIndx = 0
    static func creat() -> WKSearchResultViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSearchResultViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentView.register(WKSegmentCell.self, forCellWithReuseIdentifier: String(describing: WKSegmentCell.self))
        segmentView.collectionViewLayout = makeSegmentCollectionViewLayout()
        
        resultCollectionView.register(WKPlayListCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self))
        resultCollectionView.collectionViewLayout = makeResultCollectionViewLayout()
        
    }
    
    func enterPlayer() {
        let playingVC = WKPlayingViewController.creat()
        playingVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playingVC, animated: true)
    }
    
    
    func searchData() {
        Task {
            let index: Int = UserDefaults.standard.object(forKey: "searchIndex") as! Int
            let type = types[index].type
            let keywords: String = UserDefaults.standard.object(forKey: "searchText") as! String
            do {    
                searchResult = try await search(keywords: keywords, type: type, limit: 100)
                if type == 1 {
                    let ids: String = searchResult?.songs!.map { String($0.id) }.joined(separator: ",") ?? ""
                    let songModels = try await fetchSongDetail(ids: ids)
                    self.audioModels.removeAll()
                    for songModel in songModels {
                        let model = CustomAudioModel()
                        model.audioId = songModel.id
                        model.isFree = 1
                        model.freeTime = 0
                        model.audioTitle = songModel.name
                        model.audioPicUrl = songModel.al?.picUrl
                        if let singerModel = songModel.ar {
                            model.singer = singerModel.map { $0.name! }.joined(separator: "/")
                        }
                        self.audioModels.append(model)
                    }
                }
                if let collectionView = resultCollectionView {
                    collectionView.reloadData()
                }
                
            } catch {
                print(error)
            }
            
            
        }
        
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
    
    func makeResultCollectionViewLayout () -> UICollectionViewLayout {
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
        return section
    }
}

extension WKSearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == segmentView {
            return types.count
        } else {
            let index: Int = UserDefaults.standard.object(forKey: "searchIndex") as! Int
            let type = types[index].type
            switch type {
            case 1:
                return audioModels.count
            case 10:
                return searchResult?.albums?.count ?? 0
            case 100:
                return searchResult?.artists?.count ?? 0
            case 1000:
                return searchResult?.playlists?.count ?? 0
            case 1002:
                return searchResult?.userprofiles?.count ?? 0
            case 1009:
                return searchResult?.djRadios?.count ?? 0
            case 1004:
                return searchResult?.mvs?.count ?? 0
            case 1014:
                return searchResult?.videos?.count ?? 0
            default:
                return 0
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == segmentView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKSegmentCell.self), for: indexPath) as! WKSegmentCell
            cell.titleLabel.text = types[indexPath.row].name
            cell.selectedView.isHidden = !types[indexPath.row].isSelected
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKPlayListCollectionViewCell.self), for: indexPath) as! WKPlayListCollectionViewCell
            let index: Int = UserDefaults.standard.object(forKey: "searchIndex") as! Int
            let type = types[index].type
            switch type {
            case 1:
                cell.playListCover.kf.setImage(with: URL(string: self.audioModels[indexPath.row].wk_audioPic!))
                cell.titleLabel.text = self.audioModels[indexPath.row].wk_sourceName
            case 10:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.albums![indexPath.row].picUrl ?? ""))
                cell.titleLabel.text = searchResult?.albums![indexPath.row].name
            case 100:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.artists![indexPath.row].picUrl ?? ""))
                cell.titleLabel.text = searchResult?.artists![indexPath.row].name
            case 1000:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.playlists![indexPath.row].coverImgUrl ?? ""))
                cell.titleLabel.text = searchResult?.playlists![indexPath.row].name
            case 1002:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.userprofiles![indexPath.row].avatarUrl ?? ""))
                cell.titleLabel.text = searchResult?.userprofiles![indexPath.row].nickname
            case 1009:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.djRadios![indexPath.row].picUrl ?? ""))
                cell.titleLabel.text = searchResult?.djRadios![indexPath.row].name
            case 1004:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.mvs![indexPath.row].cover ?? ""))
                cell.titleLabel.text = searchResult?.mvs![indexPath.row].name
            case 1014:
                cell.playListCover.kf.setImage(with: URL(string: searchResult?.videos![indexPath.row].coverUrl ?? ""))
                cell.titleLabel.text = searchResult?.videos![indexPath.row].title
            default: break
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == segmentView {
            var i = 0
            var newTypes = [WKSearchTypeModel]()
            for var type in self.types {
                if i == indexPath.row {
                    type.isSelected = true
                    currentIndx = i
                    UserDefaults.standard.set(currentIndx, forKey: "searchIndex")
                } else {
                    type.isSelected = false
                }
                type.isSelected = i == indexPath.row
                i += 1
                newTypes.append(type)
            }
            searchData()
            types = newTypes
            segmentView.reloadData()
        } else {
            let index: Int = UserDefaults.standard.object(forKey: "searchIndex") as! Int
            let type = types[index].type
            switch type {
            case 1:
                if wk_player.isPlaying && wk_player.currentModel?.audioId == self.audioModels[indexPath.row].audioId {
                    self.enterPlayer()
                    return
                }
                wk_player.allOriginalModels = [self.audioModels[indexPath.row]]
                try? wk_player.play(index: 0)
                self.enterPlayer()
            case 10:
                let albumVC = WKAlbumDetailViewController.creat(playListId: (searchResult?.albums![indexPath.row].id)!)
                albumVC.modalPresentationStyle = .blurOverFullScreen
                self.present(albumVC, animated: true)
            case 100:
                let singerDetailVC = WKSingerDetailViewController.creat(singerId: (searchResult?.artists![indexPath.row].id)!)
                singerDetailVC.modalPresentationStyle = .blurOverFullScreen
                self.present(singerDetailVC, animated: true)
            case 1000:
                let playListDetaiVC = WKPlayListDetailViewController.creat(playListId: (searchResult?.playlists![indexPath.row].id)!)
                playListDetaiVC.modalPresentationStyle = .blurOverFullScreen
                self.present(playListDetaiVC, animated: true)
            case 1009:
                let podcastDetaiVC = WKPodcastDetailViewController.creat(djRadioModel: (searchResult?.djRadios![indexPath.row])!)
                podcastDetaiVC.modalPresentationStyle = .blurOverFullScreen
                self.present(podcastDetaiVC, animated: true)
            case 1004:
                let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: (searchResult?.mvs![indexPath.row].id)!, r: 1080, isMV: true))
                self.present(videoPlayerVC, animated: true)
            case 1014:
                let videoPlayerVC = WKVideoViewController(playInfo: WKPlayInfo(id: Int((searchResult?.videos![indexPath.row].vid)!)!, r: 1080, isMV: true))
                self.present(videoPlayerVC, animated: true)
            default:
                break
            }
        }
        
    }
}

