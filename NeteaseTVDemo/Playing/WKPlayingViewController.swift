
import UIKit
import NeteaseRequest
import Kingfisher
import MarqueeLabel
class WKPlayingViewController: UIViewController {

//    /    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    var lyrics: [String]?
    var lyricTuple: (times: [String], words: [String])?
    var current: Int = 0
    var isPodcast: Bool = false
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var progressView: WKSlider!
    @IBOutlet weak var nameLabel: MarqueeLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImageView: UIImageView!
    //    @IBOutlet weak var playListView: UITableView!
        
    @IBOutlet weak var audioQualityLabel: UILabel!
//        @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var singerLabel: MarqueeLabel!
//        @IBOutlet weak var bottomActionView: UIView!
//        @IBOutlet weak var sliderStackView: UIStackView!
    @IBOutlet weak var bottomActionView: UIStackView!
    static func creat(isPodcast: Bool = false) -> WKPlayingViewController {
            let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKPlayingViewController
            vc.isPodcast = isPodcast
            return vc
        }
        
    deinit {
        wk_player.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wk_player.delegate = nil
        self.progressView.delegate = self
        wk_player.delegate = self
        if wk_player.isPlaying {
            self.bgImageView.kf.setImage(with: URL(string: wk_player.currentModel?.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))])
            self.coverImageView.kf.setImage(with: URL(string: wk_player.currentModel?.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
            self.nameLabel.text = wk_player.currentModel?.wk_sourceName
            self.audioQualityLabel.text = wk_player.currentModel?.audioQuality
            
            Task {
                do {
                    lyricTuple = try await fetchLyric(id: (wk_player.currentModel?.wk_audioId)!).lyric?.parserLyric()
//                    lyricTuple = parserLyric(lyric: try await fetchLyric(id: (wk_player.currentModel?.wk_audioId!)!).lyric!)
                    tableView.isHidden = lyricTuple?.words.count == 1
                    tableView.reloadData()
                } catch {
                    print(error)
                    tableView.isHidden = true
                }
                
            }
        }
        
        guard (wk_player.allOriginalModels?.count) != nil else {
            self.bottomActionView.isHidden = true
//            self.sliderStackView.isHidden = true
            return
        }
        self.bottomActionView.isHidden = wk_player.allOriginalModels?.count == 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKLyricTableViewCell.self, forCellReuseIdentifier: "cell")
//        playListView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        self.coverImageView.layer.cornerRadius = 20;
        
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
//MARK:  WKPlayerDelegate
extension WKPlayingViewController: WKPlayerDelegate {
    
    
    func configePlayer() {
        wk_player.function = [.cache]
    }

    func playDataSourceWillChange(now: CustomAudioModel?, new: CustomAudioModel?) {
        debugPrint("设置上一个数据源，说明要切换音频了，当前是\(String(describing: now?.wk_sourceName!))，即将播放的是\(String(describing: new?.wk_sourceName!))")
    }

    func playDataSourceDidChanged(last: CustomAudioModel?, now: CustomAudioModel) {
        debugPrint("设置新的数据源，说明已经切换音频了，原来是\(String(describing: last?.wk_sourceName!))，当前是\(now.wk_sourceName!)")

        Task {
            do {
                lyricTuple = try await fetchLyric(id: (wk_player.currentModel?.wk_audioId)!).lyric?.parserLyric()
                tableView.isHidden = lyricTuple?.words.count == 1
                tableView.reloadData()
            } catch {
                tableView.isHidden = true
                print(error)
            }
        }


        if Thread.isMainThread {
            self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""))
            self.nameLabel.text = now.wk_sourceName
            self.audioQualityLabel.text = now.audioQuality
        } else {
            DispatchQueue.main.async {
                self.bgImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))])
                self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
                self.nameLabel.text = now.wk_sourceName
                self.singerLabel.text = now.singer
                self.audioQualityLabel.text = now.audioQuality
            }

        }

    }

    func didPlayToEnd(dataSource: CustomAudioModel, isTheEnd: Bool) {
        debugPrint("数据源\(dataSource.wk_sourceName!)已播放至结尾")
    }


    func noPermissionToPlayDataSource(dataSource: CustomAudioModel) {
        debugPrint("没有权限播放\(dataSource.wk_sourceName!)")
    }

    func didReadTotalTime(totalTime: UInt, formatTime: String, now: CustomAudioModel) {
//        debugPrint("已经读取到时长为duration = \(totalTime), format = \(formatTime)")
        DispatchQueue.main.async {
            self.rightLabel.text = formatTime
        }


    }

    func stateDidChanged(_ state: WKPlayerState) {
    }

    func updateUI(dataSource: CustomAudioModel?, state: WKPlayerState, isPlaying: Bool, detailInfo: WKPlayerStateModel?) {
        guard let detail = detailInfo else { return }
        let currentTime = wk_playerTool.formatTime(seconds: detail.current)
        guard let times = lyricTuple?.times else { return }
        for (index, time) in times.enumerated() {
            let times = time.components(separatedBy: ":")
            if time.count > 1 {
                let lyricTime = (Float(times.first ?? "0.0") ?? 0.0) * 60 + (Float(times.last ?? "0.0") ?? 0.0)
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


    func dataSourceDidChange(lastOriginal: [CustomAudioModel]?, lastAvailable: [CustomAudioModel]?, nowOriginal: [CustomAudioModel]?, nowAvailable: [CustomAudioModel]?) {

    }



    func unifiedExceptionHandle(error: WKPlayerError) {
        debugPrint(error.errorDescription as Any)

        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "提示", message: error.errorDescription, preferredStyle: .alert)
            let confirm = UIAlertAction.init(title: "ok", style: .default, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }


    }
}
//MARK:  SliderDelegate
extension WKPlayingViewController: WKSliderDelegate {
    func forward() {
        wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current + 15) / Float(wk_player.totalTime)))
    }
    
    func backward() {
        if wk_player.currentModelState!.current >= 15 {
            wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current - 15) / Float(wk_player.totalTime)))
        }
        
    }
    
    func playOrPause() {
        if wk_player.state == .paused {
            wk_player.resumePlayer()
        } else if  wk_player.state == .isPlaying {
            wk_player.pausePlayer()
        }
    }
}
//MARK:  UITableView
extension WKPlayingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricTuple?.words.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WKLyricTableViewCell
        cell.contentLabel!.text = lyricTuple?.words[indexPath.row] ?? ""
        if current == indexPath.row {
            cell.contentLabel?.textColor = UIColor.label
            cell.contentLabel?.font = .systemFont(ofSize: 70, weight: .bold)
        } else {
            cell.contentLabel?.textColor = UIColor.lightGray
            cell.contentLabel?.font = .systemFont(ofSize: 60, weight: .bold)
        }
        return cell
        
    }
}
