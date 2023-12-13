
import UIKit
import NeteaseRequest

class WKMyCloudSongVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var allModels: [CustomAudioModel] = [CustomAudioModel]()
    
    static func creat() -> WKMyCloudSongVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKMyCloudSongVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKSongTableViewCell.self, forCellReuseIdentifier: "WKSongTableViewCell")
        Task {
            await loadData()
            self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    func loadData() async {
        do {
            let cloudDataModels: [NRUserCloudDataModel] = try await fetchUserCloudData(cookie: cookie, limit: 1000)
            self.allModels.removeAll()
            for cloudDataModel in cloudDataModels {
                let model = CustomAudioModel()
                model.audioId = cloudDataModel.songId
                model.like = likeIds.contains(cloudDataModel.songId)
                model.isFree = 1
//                model.fee = cloudDataModel.fee
                model.freeTime = 0
                model.audioTitle = cloudDataModel.songName
                model.audioPicUrl = cloudDataModel.simpleSong.al?.picUrl
                model.transTitle = cloudDataModel.simpleSong.tns?.first
                model.albumTitle = cloudDataModel.album ?? ""
                let min = (cloudDataModel.simpleSong.dt ?? 0) / 1000 / 60
                let sec = (cloudDataModel.simpleSong.dt ?? 0) / 1000 % 60
                model.audioTime = String(format: "%d:%02d", min, sec)
                if let singerModel = cloudDataModel.simpleSong.ar {
                    model.singer = singerModel.map { $0.name ?? "" }.joined(separator: "/")
                }
                self.allModels.append(model)
            }
        } catch {
            showAlert(error.localizedDescription)
        }
    }


}

extension WKMyCloudSongVC: UITableViewDelegate, UITableViewDataSource {
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
