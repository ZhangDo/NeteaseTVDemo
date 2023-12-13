import UIKit
import NeteaseRequest
class WKRecentSongListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var allModels: [CustomAudioModel] = [CustomAudioModel]()
    
    static func creat() -> WKRecentSongListVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecentSongListVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKSongTableViewCell.self, forCellReuseIdentifier: "WKSongTableViewCell")
        Task {
            await loadData()
            self.tableView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            let recentModel: NRRecentPlayModel = try await fetchRecentSong(cookie: cookie,limit: 1000)
            self.allModels.removeAll()
            for resourceModel in recentModel.list {
                let model = CustomAudioModel()
                model.audioId = resourceModel.data.id
                model.like = likeIds.contains(resourceModel.data.id)
                model.isFree = 1
//                model.fee = resourceModel.data.fee
                model.freeTime = 0
                model.audioTitle = resourceModel.data.name
                model.audioPicUrl = resourceModel.data.al?.picUrl
                model.transTitle = resourceModel.data.tns?.first
                model.albumTitle = resourceModel.data.al?.name
                let min = (resourceModel.data.dt ?? 0) / 1000 / 60
                let sec = (resourceModel.data.dt ?? 0) / 1000 % 60
                model.audioTime = String(format: "%d:%02d", min, sec)
                if let singerModel = resourceModel.data.ar {
                    model.singer = singerModel.map { $0.name ?? "" }.joined(separator: "/")
                }
                self.allModels.append(model)
            }
            
        } catch {
            print(error)
        }
    }

}

extension WKRecentSongListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKSongTableViewCell", for: indexPath) as! WKSongTableViewCell
        cell.indexLabel.text = "\(indexPath.row + 1)" + "."
        cell.setModel(allModels[indexPath.row])
        cell.albumLabel.text = (allModels[indexPath.row].singer ?? "") + " - " + (allModels[indexPath.row].albumTitle ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wk_player.isPlaying && wk_player.currentModel?.audioId == self.allModels[indexPath.row].audioId {
            let playingVC = WKPlayingViewController.creat()
            self.present(playingVC, animated: true)
            return
        }
        wk_player.allOriginalModels = self.allModels
        try? wk_player.play(index: indexPath.row)
        let playingVC = WKPlayingViewController.creat()
        self.present(playingVC, animated: true)
    }

}
