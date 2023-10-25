
import UIKit
import NeteaseRequest
class WKRencentVoiceListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    static func creat() -> WKRencentVoiceListVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRencentVoiceListVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        Task {
            await loadData()
            self.tableView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            let rencentModel: NRRecentPlayModel = try await fetchRecentVoice(cookie: cookie, limit: 1000)
            for songModel in rencentModel.list {
                let model = CustomAudioModel()
                model.audioId = songModel.data.pubDJProgramData.mainTrackId
                model.isFree = 1
                model.freeTime = 0
                model.audioTitle = songModel.data.pubDJProgramData.name
                model.audioPicUrl = songModel.data.pubDJProgramData.coverUrl
                let min = songModel.data.pubDJProgramData.duration / 1000 / 60
                let sec = songModel.data.pubDJProgramData.duration / 1000 % 60
                model.audioTime = String(format: "%d:%02d", min, sec)
                model.singer =  songModel.data.pubDJProgramData.dj.nickname
                self.allModels.append(model)
            }
        } catch {
            print(error)
        }
    }

}

extension WKRencentVoiceListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKPlayListTableViewCell", for: indexPath) as! WKPlayListTableViewCell
        cell.setModel(allModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wk_player.isPlaying && wk_player.currentModel?.audioId == self.allModels[indexPath.row].audioId {
            let playingVC = WKPlayingViewController.creat()
            self.present(playingVC, animated: true)
            return
        }
        let model: [CustomAudioModel] = [self.allModels[indexPath.row]]
        wk_player.allOriginalModels = model
        try? wk_player.play(index: 0)
        let playingVC = ViewController.creat(isPodcast: true)
        self.present(playingVC, animated: true)
    }
}
