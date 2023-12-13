
import UIKit
import NeteaseRequest
import Kingfisher
import MarqueeLabel
class WKPlayingViewController: UIViewController {
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
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var playModeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var audioQualityLabel: UILabel!
    @IBOutlet weak var singerLabel: MarqueeLabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var bottomActionView: UIStackView!
    var isTableViewFocused: Bool = false
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
        if (wk_player.currentModel != nil) {
            self.progressView.isHidden = false
            self.leftTimeLabel.isHidden = false
            self.rightLabel.isHidden = false
            self.commentBtn.isHidden = !Settings.hotComment
            let currentTime = wk_playerTool.formatTime(seconds: wk_player.currentModelState!.current)
            let totalTime = wk_playerTool.formatTime(seconds: wk_player.currentModelState!.duration)
            self.leftTimeLabel.text = currentTime
            self.rightLabel.text = totalTime
            self.playBtn.setImage(UIImage(systemName: wk_player.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
            self.bgImageView.kf.setImage(with: URL(string: wk_player.currentModel?.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))])
            self.coverImageView.kf.setImage(with: URL(string: wk_player.currentModel?.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
            self.nameLabel.text = wk_player.currentModel?.wk_sourceName
            self.audioQualityLabel.text = wk_player.currentModel?.audioQuality
            if let like = wk_player.currentModel?.like {
                self.likeBtn.tintColor = like ? .systemPink : .lightGray
                self.likeBtn.setImage(UIImage(systemName: like ? "heart.fill" : "heart"), for: .normal)
            }
            self.playModeBtn.setImage(UIImage(systemName: shufflePlay ? "shuffle" : "list.bullet"), for: .normal)
            if isPodcast {
                self.commentBtn.isHidden = true
            }
            Task {
                do {
                    lyricTuple = try await fetchLyric(id: (wk_player.currentModel?.wk_audioId)!).lyric?.parserLyric()
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
            return
        }
        self.bottomActionView.isHidden = wk_player.allOriginalModels?.count == 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKLyricTableViewCell.self, forCellReuseIdentifier: "cell")
        self.coverImageView.layer.cornerRadius = 20;
        self.progressView.isHidden = true
        self.leftTimeLabel.isHidden = true
        self.rightLabel.isHidden = true
        self.commentBtn.isHidden = true
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
    
    @IBAction func comment(_ sender: Any) {
        if let songid = wk_player.currentModel?.audioId {
            let vc = WKCommentViewController.creat(songId: songid)
            vc.modalPresentationStyle = .blurOverFullScreen
            self.present(vc, animated: true)
        }
        
        
    }
    @IBAction func changePlayMode(_ sender: Any) {
        shufflePlay = !shufflePlay
        self.playModeBtn.setImage(UIImage(systemName: shufflePlay ? "shuffle" : "list.bullet"), for: .normal)
    }
    @IBAction func likeAudio(_ sender: Any) {
        showAlert("该功能还在开发中")
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
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if !isTableViewFocused {
            return [self.playBtn]
        }
                // 如果播放按钮不存在，调用父类的实现
        return super.preferredFocusEnvironments
    }
    
    // 当焦点更新后
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        // 如果焦点更新到了播放按钮，重置标记
        if context.nextFocusedView == playBtn {
            isTableViewFocused = false
        }
    }
    
}
//MARK:  WKPlayerDelegate
extension WKPlayingViewController: WKPlayerDelegate {
    
    
    func configePlayer() {
        wk_player.function = [.cache]
    }

    func playDataSourceWillChange(now: CustomAudioModel?, new: CustomAudioModel?) {
    }

    func playDataSourceDidChanged(last: CustomAudioModel?, now: CustomAudioModel) {
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
            self.likeBtn.tintColor = (now.like)! ? .systemPink : .lightGray
            self.likeBtn.setImage(UIImage(systemName: now.like! ? "heart.fill" : "heart"), for: .normal)
        } else {
            DispatchQueue.main.async {
                self.bgImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))])
                self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
                self.nameLabel.text = now.wk_sourceName
                self.singerLabel.text = now.singer
                self.audioQualityLabel.text = now.audioQuality
                self.likeBtn.tintColor = (now.like)! ? .systemPink : .lightGray
                self.likeBtn.setImage(UIImage(systemName: now.like! ? "heart.fill" : "heart"), for: .normal)
            }

        }

    }
    //MARK: 播放至结尾
    func didPlayToEnd(dataSource: CustomAudioModel, isTheEnd: Bool) {
        debugPrint("数据源\(dataSource.wk_sourceName!)已播放至结尾")
    }

    //MARK: 没有权限播放
    func noPermissionToPlayDataSource(dataSource: CustomAudioModel) {
    }

    func didReadTotalTime(totalTime: UInt, formatTime: String, now: CustomAudioModel) {
        DispatchQueue.main.async {
            self.rightLabel.text = formatTime
            self.progressView.isHidden = false
            self.leftTimeLabel.isHidden = false
            self.rightLabel.isHidden = false
            self.commentBtn.isHidden = !Settings.hotComment
        }
    }

    func stateDidChanged(_ state: WKPlayerState) {
        if state == .paused {
            DispatchQueue.main.async {
                self.playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } else if state == .isPlaying {
            DispatchQueue.main.async {
                self.playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
    }

    func updateUI(dataSource: CustomAudioModel?, state: WKPlayerState, isPlaying: Bool, detailInfo: WKPlayerStateModel?) {
        guard let detail = detailInfo else { return }
        let currentTime = wk_playerTool.formatTime(seconds: detail.current)
        let totalTime = wk_playerTool.formatTime(seconds: detail.duration)
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
            self.rightLabel.text = totalTime
            self.progressView.progress = detail.progress
            
            if current >= (lyricTuple?.words.count)! {
                return
            }
            if !isTableViewFocused {
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: current, section: 0), at: .middle, animated: false)
            }
            
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
            cell.contentLabel?.textColor = isTableViewFocused ? UIColor.black : UIColor.white
            cell.contentLabel?.font = .systemFont(ofSize: 70, weight: .bold)
        } else {
            cell.contentLabel?.textColor = UIColor.lightGray
            cell.contentLabel?.font = .systemFont(ofSize: 60, weight: .bold)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(lyricTuple?.times[indexPath.row] ?? "")
        let selectTimeStr = lyricTuple?.times[indexPath.row] ?? ""
        let time = selectTimeStr.convertToSeconds()
        wk_player.prepareForSeek(to: (Float(time) / Float(wk_player.totalTime)))
        isTableViewFocused = false
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .middle, animated: false)
        self.playBtn.isHighlighted = true
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath {
            isTableViewFocused = true
        } else {
            isTableViewFocused = false
        }
    }
}
