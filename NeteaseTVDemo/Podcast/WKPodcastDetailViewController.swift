
import UIKit
import NeteaseRequest
class WKPodcastDetailViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descView: WKDescView!
    private var djRadioModel: NRDJRadioModel?
    private var djPrograms = [NRProgramModel]()
    
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    
    
    static func creat(djRadioModel: NRDJRadioModel) -> WKPodcastDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKPodcastDetailViewController
        vc.djRadioModel = djRadioModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        self.coverImageView.layer.cornerRadius = 10;
        self.bgView.kf.setImage(with: URL(string: djRadioModel!.picUrl), options: [.transition(.flipFromBottom(0.6))])
        self.coverImageView.kf.setImage(with: URL(string: djRadioModel!.picUrl), options: [.transition(.flipFromBottom(0.6))])
        self.nameLabel.text = djRadioModel?.name
        self.descView.descLabel.text = djRadioModel?.desc
        self.descView.onPrimaryAction = { [weak self] _ in
            let vc = WKDescViewController.creat(desc: self!.djRadioModel?.desc ?? "")
            self!.present(vc, animated: true)
        }
        
        Task {
            await loadData()
            tableView.reloadData()
        }
    }
    
    func loadData() async {
        do {
            djPrograms = try await fetchDJProgram(rid: djRadioModel!.id, limit: 1000)
            print(djPrograms)
            for songModel in djPrograms {
                let model = CustomAudioModel()
                model.audioId = songModel.mainTrackId
                model.isFree = 1
                model.freeTime = 0
                model.audioTitle = songModel.name
                model.audioPicUrl = songModel.radio.picUrl
                let min = songModel.duration / 1000 / 60
                let sec = songModel.duration / 1000 % 60
                model.audioTime = String(format: "%d:%02d", min, sec)
                model.singer =  songModel.dj.nickname
                self.allModels.append(model)
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func playAll(_ sender: Any) {
        wk_player.allOriginalModels = self.allModels
        try? wk_player.play(index: 0)
        let playingVC = ViewController.creat(isPodcast: true)
        playingVC.modalPresentationStyle = .blurOverFullScreen
        self.present(playingVC, animated: true)
    }

}

extension WKPodcastDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
            let playingVC = ViewController.creat()
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
