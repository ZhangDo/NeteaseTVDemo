
import UIKit
import NeteaseRequest
class WKSongListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var singerId: Int!
    private var allModels: [CustomAudioModel] = [CustomAudioModel]()
    static func creat(singerId: Int) -> WKSongListViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSongListViewController
        vc.singerId = singerId
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
            let songModels: [NRSongModel] = try await fetchArtistSongs(cookie: cookie, id: singerId)
            self.allModels.removeAll()
            for songModel in songModels {
                let model = CustomAudioModel()
                model.audioId = songModel.id
                model.isFree = 1
                model.freeTime = 0
                model.audioTitle = songModel.name
                model.audioPicUrl = songModel.al?.picUrl
                model.transTitle = songModel.tns?.first
                model.albumTitle = songModel.al?.name
                let min = (songModel.dt ?? 0) / 1000 / 60
                let sec = (songModel.dt ?? 0) / 1000 % 60
                model.audioTime = String(format: "%d:%02d", min, sec)
                if let singerModel = songModel.ar {
                    model.singer = singerModel.map { $0.name ?? "" }.joined(separator: "/")
                }
                self.allModels.append(model)
            }
        } catch {
            print(error)
        }
    }

}


extension WKSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKSongTableViewCell", for: indexPath) as! WKSongTableViewCell
        cell.indexLabel.text = "\(indexPath.row + 1)" + "."
        cell.setModel(allModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wk_player.isPlaying && wk_player.currentModel?.audioId == self.allModels[indexPath.row].audioId {
            let playingVC = WKPlayingViewController.creat()
            self.present(playingVC, animated: true)
            return
        }
//        let model: [CustomAudioModel] = [self.allModels[indexPath.row]]
        wk_player.allOriginalModels = self.allModels
        try? wk_player.play(index: indexPath.row)
        let playingVC = WKPlayingViewController.creat()
        self.present(playingVC, animated: true)
    }

}
