//
//  ViewController.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit
import NeteaseRequest
import Kingfisher
import MarqueeLabel
class ViewController: UIViewController {
    
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    var lyrics: [String]?
    var lyricTuple: (times: [String], words: [String])?
    var current: Int = 0
    var showPlayList: Bool = false

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nameLabel: MarqueeLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playListView: UITableView!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKLyricTableViewCell.self, forCellReuseIdentifier: "cell")
        playListView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        self.coverImageView.layer.cornerRadius = 20;
        Task {
            wk_player.delegate = self
            wk_player.allOriginalModels = await loadData()
            try? wk_player.play(index: 0)
            self.playListView.reloadData()
            
        }
//        wk_player.updateUIHandler = { dataSource, state, isPlaying, detailInfo in
//            guard let detail = detailInfo else { return }
//            let currentTime = wk_playerTool.formatTime(seconds: detail.current)
//            let durationTime = wk_playerTool.formatTime(seconds: detail.duration)
//            debugPrint("进度\(currentTime)")
//        }
        
    }
    
    
    func loadData() async -> [CustomAudioModel] {
        let songModels:[NRSongModel] = try! await fetchPlayListTrackAll(id: 2312165875,limit: 100)

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
        return self.allModels
        
    }
    

    @IBAction func backward(_ sender: Any) {
        wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current + 15) / Float(wk_player.totalTime)))
        
    }
    
    @IBAction func forward(_ sender: Any) {
        wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current + 15) / Float(wk_player.totalTime)))
    }
    
    @IBAction func previous(_ sender: Any) {
        do {
            try wk_player.playLast()
        } catch {
            debugPrint(error)
        }
    }
    @IBAction func playOrPause(_ sender: Any) {
        if wk_player.state == .paused {
            wk_player.resumePlayer()
        } else if  wk_player.state == .isPlaying {
            wk_player.pausePlayer()
        }
        
    }
    
    @IBAction func next(_ sender: Any) {
        do {
            try wk_player.playNext()
        } catch {
            debugPrint(error)
        }
    }
    
    @IBAction func playListAction(_ sender: Any) {
        showPlayList = !showPlayList
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: { [self] in
            self.playListView.alpha = showPlayList ? 1.0 : 0.0
            self.coverImageView.alpha = showPlayList ? 0.0 : 1.0
            self.nameLabel.alpha = showPlayList ? 0.0 : 1.0
        }, completion: { [self] _ in
            self.playListView.isHidden = !showPlayList
            self.coverImageView.isHidden = showPlayList
            self.nameLabel.isHidden = showPlayList
        })
        
        
        
        
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.type == .playPause {
                if wk_player.state == .paused {
                    wk_player.resumePlayer()
                } else if  wk_player.state == .isPlaying {
                    wk_player.pausePlayer()
                }
            }
        }
    }
    
}

extension ViewController: WKPlayerDelegate {
    
    func configePlayer() {
        wk_player.function = [.cache]
    }
    
    func playDataSourceWillChange(now: WKPlayerDataSource?, new: WKPlayerDataSource?) {
        debugPrint("设置上一个数据源，说明要切换音频了，当前是\(String(describing: now?.wk_sourceName!))，即将播放的是\(String(describing: new?.wk_sourceName!))")
    }
    
    func playDataSourceDidChanged(last: WKPlayerDataSource?, now: WKPlayerDataSource) {
        debugPrint("设置新的数据源，说明已经切换音频了，原来是\(String(describing: last?.wk_sourceName!))，当前是\(now.wk_sourceName!)")
        
        Task {
            lyricTuple = parserLyric(lyric: try! await fetchLyric(id: now.wk_audioId!).lyric!)
            tableView.reloadData()
        }
        
        
        if Thread.isMainThread {
            self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""))
            self.nameLabel.text = now.wk_sourceName
        } else {
            DispatchQueue.main.async {
                self.bgImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))])
                self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
                self.nameLabel.text = now.wk_sourceName
                
            }
            
        }
        
    }
    
    func didPlayToEnd(dataSource: WKPlayerDataSource, isTheEnd: Bool) {
        debugPrint("数据源\(dataSource.wk_sourceName!)已播放至结尾")
    }
    
    
    func noPermissionToPlayDataSource(dataSource: WKPlayerDataSource) {
        debugPrint("没有权限播放\(dataSource.wk_sourceName!)")
    }
    
    func didReadTotalTime(totalTime: UInt, formatTime: String, now: WKPlayerDataSource) {
        debugPrint("已经读取到时长为duration = \(totalTime), format = \(formatTime)")
        DispatchQueue.main.async {
            self.rightLabel.text = formatTime
        }
        
        
    }
    
    
    
    func askForWWANLoadPermission(confirmed: @escaping () -> ()) {
//        let alert = UIAlertController.init(title: "网络环境确认", message: "当前非wifi环境，确定继续加载么", preferredStyle: .alert)
//        let confirmAction = UIAlertAction.init(title: "确定", style: .default) {_ in
//            confirmed()
//        }
//        alert.addAction(confirmAction)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func stateDidChanged(_ state: WKPlayerState) {
        DispatchQueue.main.async {
            if (state == .paused) {
                self.playOrPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                self.playOrPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
        
    }
    
    func updateUI(dataSource: WKPlayerDataSource?, state: WKPlayerState, isPlaying: Bool, detailInfo: WKPlayerStateModel?) {
        
//        playBtn.isSelected = isPlaying
//
//        audioTitleLbl.text = dataSource?.wk_sourceName!
        guard let detail = detailInfo else { return }
        let currentTime = wk_playerTool.formatTime(seconds: detail.current)
//        let durationTime = wk_playerTool.formatTime(seconds: detail.duration)
//        audioDurationLbl.text = currentTime + "/" + durationTime
//        bufferProgress.progress = detail.buffer
//        audioProgressSlider.value = detail.progress
//        debugPrint("进度\(currentTime)")
        guard let times = lyricTuple?.times else { return }
        for (index, time) in times.enumerated() {
            let times = time.components(separatedBy: ":")
            if time.count > 1 {
                let lyricTime = Float(times.first ?? "0.0")! * 60 + (Float(times.last ?? "0.0") ?? 0.0)
                if (Float(detail.current) + 0.5) > lyricTime {
                    current = index
                } else {
                    break
                }
                    
            }
            
        }
        
        DispatchQueue.main.async { [self] in
            self.leftTimeLabel.text = currentTime
            self.progressView.progress = detail.progress
            tableView.reloadData()
            if current >= (lyricTuple?.words.count)! {
                return
            }
            tableView.scrollToRow(at: IndexPath(row: current, section: 0), at: .middle, animated: false)
        }
        
        
    }
    
    
    func dataSourceDidChange(lastOriginal: [WKPlayerDataSource]?, lastAvailable: [WKPlayerDataSource]?, nowOriginal: [WKPlayerDataSource]?, nowAvailable: [WKPlayerDataSource]?) {
        
    }
    
    
    
    func unifiedExceptionHandle(error: WKPlayerError) {
        debugPrint(error.errorDescription as Any)
        
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "Error", message: error.errorDescription, preferredStyle: .alert)
            let confirm = UIAlertAction.init(title: "ok", style: .default, handler: nil)
            alert.addAction(confirm)
    //        self.present(alert, animated: true)
            let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .compactMap({$0 as? UIWindowScene})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
            keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.playListView) {
            return self.allModels.count
        } else {
            return lyricTuple?.words.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.playListView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WKPlayListTableViewCell", for: indexPath) as! WKPlayListTableViewCell
            cell.setModel(self.allModels[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WKLyricTableViewCell
            cell.contentLabel!.text = lyricTuple?.words[indexPath.row] ?? ""
            if current == indexPath.row {
                cell.contentLabel?.textColor = UIColor.label
                cell.contentLabel?.font = .systemFont(ofSize: 48, weight: .black)
            } else {
                cell.contentLabel?.textColor = UIColor.lightGray
                cell.contentLabel?.font = .systemFont(ofSize: 38)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.playListView {
            try? wk_player.play(index: indexPath.row)
            self.showPlayList = false
            self.playListView.isHidden = true
            self.coverImageView.isHidden = false
            self.nameLabel.isHidden = false
        }
    }
}

