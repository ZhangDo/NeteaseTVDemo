
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
            let cloudDataModels: [NRUserCloudDataModel] = try await fetchUserCloudData(cookie: "MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/neapi/feedback; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/eapi/clientlog; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/neapi/feedback; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/eapi/clientlog; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/eapi/feedback; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/eapi/feedback; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/wapi/feedback; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/openapi/clientlog; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/weapi/clientlog; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/api/feedback; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/weapi/feedback; HTTPOnly;__csrf=9a178662dda24db0220e71f72ed1fc5d; Max-Age=1296010; Expires=Thu, 21 Dec 2023 21:55:09 GMT; Path=/;;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/wapi/clientlog; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/wapi/feedback; HTTPOnly;MUSIC_SNS=; Max-Age=0; Expires=Wed, 06 Dec 2023 21:54:59 GMT; Path=/;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/api/clientlog; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/weapi/feedback; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/neapi/clientlog; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/neapi/clientlog; HTTPOnly;MUSIC_U=000649AE032117C112032471065B441EED396B7E8335894173E5C1865E8290925C02066D1E3785AC2B9E8684BEA978769056A8DA0971DDE043E88E79884424F534B8827F21DB475A31717D60B397236BC7CC9C4509831023EC0AD1CD2DB99BFEB00EE514FD43D9A1DA015EAB7FC1601A29280A2E1EC6D3DF047896829806A28017159D688899D20A66BB8AC4EA961A797551C20A271581431A94B3BB7884BF5A6E04A88EAC7FA571C89387C92782F3D142767C3481EBD1B6F457C284A5BA9CF6250CA5DF43064F0ABD73CFD7C15A12B8D483AE2CC3D44C1DDF3C4407AD4C50C385BAC90CA8370609CC54F78DE9E357D73CD136215FDF77D32835BF8D5A94032490FCB00265F7EAD8E4FB6EB09EB8C25AEC0F52291619C4290EFDA45869F8EF94101A1AC266105A75765090FE2D2BB92DDEBAA417D4B0FD4AACE47331C4433BC288; Max-Age=15552000; Expires=Mon, 03 Jun 2024 21:54:59 GMT; Path=/; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/wapi/clientlog; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/weapi/clientlog; HTTPOnly;MUSIC_R_T=1486481142662; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/openapi/clientlog; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/api/feedback; HTTPOnly;MUSIC_A_T=1486481118961; Max-Age=2147483647; Expires=Tue, 25 Dec 2091 01:09:06 GMT; Path=/api/clientlog; HTTPOnly", limit: 1000)
            self.allModels.removeAll()
            for cloudDataModel in cloudDataModels {
                let model = CustomAudioModel()
                model.audioId = cloudDataModel.songId
                model.isFree = 1
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
