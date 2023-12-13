
import UIKit
import NeteaseRequest

class WKDailySongsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var timeLabel: UILabel!
    fileprivate var dailyAudioModels: [CustomAudioModel] = [CustomAudioModel]()
    fileprivate var dates: [String] = [String]()
    
    static func creat() -> WKDailySongsViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKDailySongsViewController
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        
        collectionView.register(WKSongCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: WKSongCollectionViewCell.self))
        collectionView.collectionViewLayout = makeDailySongCollectionViewLayout()
        
        Task {
            await loadTodayRecommend()
        }
        
        Task {
            await loadDateData()
        }

    }
    
    func loadDateData() async {
        do {
            let historyDate = try await fetchHistoryDate(cookie: cookie)
            dates = historyDate.dates ?? []
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func loadTodayRecommend() async {
        do {
            let dailySongs = try await fetchDailtSongs(cookie: cookie).dailySongs
            self.dailyAudioModels.removeAll()
            for songModel in dailySongs {
                let model = CustomAudioModel()
                model.audioId = songModel.id
                model.like = likeIds.contains(songModel.id)
                model.isFree = 1
//                model.fee = songModel.fee
                model.freeTime = 0
                model.audioTitle = songModel.name
                model.audioPicUrl = songModel.al?.picUrl
                if let singerModel = songModel.ar {
                    model.singer = singerModel.map { $0.name! }.joined(separator: "/")
                }
                self.dailyAudioModels.append(model)
            }
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func loadRecommendSongs(date: String) async {
        do {
            let historyRecommendDetail: NRHistoryDateModel = try await fetchHistoryRecommendDetail(cookie: cookie, date: date)
            self.dailyAudioModels.removeAll()
            if let songs = historyRecommendDetail.songs {
                for songModel in songs {
                    let model = CustomAudioModel()
                    model.audioId = songModel.id
                    model.like = likeIds.contains(songModel.id)
//                    model.fee = songModel.fee
                    model.isFree = 1
                    model.freeTime = 0
                    model.audioTitle = songModel.name
                    model.audioPicUrl = songModel.al?.picUrl
                    if let singerModel = songModel.ar {
                        model.singer = singerModel.map { $0.name! }.joined(separator: "/")
                    }
                    self.dailyAudioModels.append(model)
                }
                collectionView.reloadData()
            }
        } catch {
            print(error)
        }
    }
}

extension WKDailySongsViewController {
    func makeDailySongCollectionViewLayout () -> UICollectionViewLayout {
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

extension WKDailySongsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyAudioModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKSongCollectionViewCell.self), for: indexPath) as! WKSongCollectionViewCell
        cell.loadData(with: dailyAudioModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wk_player.allOriginalModels = self.dailyAudioModels
        try? wk_player.play(index: indexPath.row)
        enterPlayer()
    }
    
    func enterPlayer() {
        let playingVC = WKPlayingViewController.creat()
        playingVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playingVC, animated: true)
    }
}

extension WKDailySongsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dates.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        var content = header?.defaultContentConfiguration()
        if section == 0 {
            content?.text = "今日推荐"
        } else {
            content?.text = "历史日推"
        }
        
        header?.contentConfiguration = content
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if indexPath.section == 0 && indexPath.row == 0 {
            content.text = "今日推荐"
        }
        
        if indexPath.section == 1 {
            content.text = dates[indexPath.row]
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.timeLabel.text = "今日推荐"
            Task {
                await loadTodayRecommend()
            }
        }
        if indexPath.section == 1 {
            let date = self.dates[indexPath.row]
            self.timeLabel.text = date
            Task {
                await loadRecommendSongs(date: date)
            }
        }
    }
}
