//
//  WKPlayListDetailViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/25.
//

import UIKit
import NeteaseRequest
class WKPlayListDetailViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descView: WKDescView!
    private var playListId: Int!
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    static func creat(playListId: Int) -> WKPlayListDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKPlayListDetailViewController
        vc.playListId = playListId
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.coverImageView.layer.cornerRadius = 10;
        tableView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        let playListDetail: NRPlayListDetailModel = try! await fetchPlayListDetail(id: self.playListId)
        self.bgView.kf.setImage(with: URL(string: playListDetail.coverImgUrl))
        self.coverImageView.kf.setImage(with: URL(string: playListDetail.coverImgUrl))
        self.nameLabel.text = playListDetail.name
        self.descView.descLabel.text = playListDetail.description
        
        let songModels:[NRSongModel] = try! await fetchPlayListTrackAll(id: self.playListId,limit: 100)
        self.allModels.removeAll()
        for songModel in songModels {
            let model = CustomAudioModel()
            model.audioId = songModel.id
            model.isFree = 1
            model.freeTime = 0
            model.audioTitle = songModel.name
            model.audioPicUrl = songModel.al.picUrl
            model.singer = "singer"
            self.allModels.append(model)
        }
        tableView .reloadData()
    }

    @IBAction func playAll(_ sender: Any) {
        wk_player.allOriginalModels = self.allModels
        try? wk_player.play(index: 0)
        let playingVC = ViewController.creat()
        self.present(playingVC, animated: true)
    }
}


extension WKPlayListDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKPlayListTableViewCell", for: indexPath) as! WKPlayListTableViewCell
        cell.setModel(self.allModels[indexPath.row])
        return cell
    }
}
