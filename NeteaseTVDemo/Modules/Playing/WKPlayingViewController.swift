
import UIKit
import NeteaseRequest
import Kingfisher
import MarqueeLabel
import ColorfulX
import CoreImage
class WKPlayingViewController: UIViewController {
    var lyrics: [String]?
    var lyricTuple: (times: [String], words: [String])?
    var current: Int = 0
    var isPodcast: Bool = false
    var animateView = AnimatedMulticolorGradientView()
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
                self.likeBtn.isHidden = true
                self.playModeBtn.isHidden = true
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
        animateView.setColors(self.getDefalutColors(), interpolationEnabled: false)
        animateView.speed = 1
        animateView.transitionDuration = 5.2
        animateView.noise = 10
        self.bgImageView.addSubview(animateView)
        animateView.snp.makeConstraints { make in
            make.edges.equalTo(self.bgImageView)
        }
        
        tableView.register(WKLyricTableViewCell.self, forCellReuseIdentifier: "cell")
        self.coverImageView.layer.cornerRadius = 20;
        self.progressView.isHidden = true
        self.leftTimeLabel.isHidden = true
        self.rightLabel.isHidden = true
        self.commentBtn.isHidden = true
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            animateView.setColors([RGBColor(UIColor.white), RGBColor(UIColor.black)], interpolationEnabled: false)
//
//        }
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
        if !isPodcast {
            if let songId = wk_player.currentModel?.wk_audioId {
                guard let like = wk_player.currentModel?.like else {
                    return
                }
                likeMusic(cookie: cookie, id: songId, like: !like) { result in
                    wk_player.currentModel?.like = !(wk_player.currentModel?.like)!
                    if let like = wk_player.currentModel?.like {
                        self.likeBtn.tintColor = like ? .systemPink : .lightGray
                        self.likeBtn.setImage(UIImage(systemName: like ? "heart.fill" : "heart"), for: .normal)
                    }
                    Task {
                         await fetchLikeIds()
                    }
                }
            }
            
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
        wk_player.function = [.default]
    }

    func playDataSourceWillChange(now: CustomAudioModel?, new: CustomAudioModel?) {
    }

    func playDataSourceDidChanged(last: CustomAudioModel?, now: CustomAudioModel) {
        Task {
            do {
                let lyricModel: NRLyricModel = try await fetchLyric(id:(wk_player.currentModel?.wk_audioId)!)
                if let lyric = lyricModel.lyric {
                    lyricTuple = lyric.parserLyric()
                    tableView.isHidden = lyricTuple?.words.count == 1
                    tableView.reloadData()
                } else {
                    tableView.isHidden = true
                    tableView .reloadData()
                }
            } catch {
                tableView.isHidden = true
            }
        }


        if Thread.isMainThread {
            self.bgImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))]) 
//            { result in
//                //TODO: 获取封面图片颜色
//                guard let image = try? result.get().image else {
//                    return
//                }
//                self.animateView.setColors(self.getDominantColors(image: image, count: 2), interpolationEnabled: false)
//            }
            self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""))
            self.nameLabel.text = now.wk_sourceName
            self.audioQualityLabel.text = now.audioQuality
            if let like = now.like {
                self.likeBtn.tintColor = like ? .systemPink : .lightGray
                self.likeBtn.setImage(UIImage(systemName: like ? "heart.fill" : "heart"), for: .normal)
            }
            
        } else {
            DispatchQueue.main.async {
                self.bgImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),placeholder: UIImage(named: "bgImage"), options: [.transition(.fade(0.5))]) 
//                { result in
//                    //TODO: 获取封面图片颜色
//                    guard let image = try? result.get().image else {
//                        return
//                    }
//                    self.animateView.setColors(self.getDominantColors(image: image, count: 2), interpolationEnabled: false)
//                }
                self.coverImageView.kf.setImage(with: URL(string: now.wk_audioPic ?? ""),options: [.transition(.flipFromBottom(0.6))])
                self.nameLabel.text = now.wk_sourceName
                self.singerLabel.text = now.singer
                self.audioQualityLabel.text = now.audioQuality
                if let like = now.like {
                    self.likeBtn.tintColor = like ? .systemPink : .lightGray
                    self.likeBtn.setImage(UIImage(systemName: like ? "heart.fill" : "heart"), for: .normal)
                }
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
    
    func getDominantColors(image: UIImage, count: Int) -> [RGBColor] {
        guard let cgImage = image.cgImage else {
            return []
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return []
        }
        
        var colorCounts: [UIColor: Int] = [:]
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        for y in 0..<height {
            for x in 0..<width {
                let byteIndex = bytesPerRow * y + bytesPerPixel * x
                let red = CGFloat(buffer[byteIndex]) / 255.0
                let green = CGFloat(buffer[byteIndex + 1]) / 255.0
                let blue = CGFloat(buffer[byteIndex + 2]) / 255.0
                let alpha = CGFloat(buffer[byteIndex + 3]) / 255.0
                
                let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                
                if let count = colorCounts[color] {
                    colorCounts[color] = count + 1
                } else {
                    colorCounts[color] = 1
                }
            }
        }
        
        let sortedColors = colorCounts.keys.sorted(by: { colorCounts[$0]! > colorCounts[$1]! })
        let dominantColors = Array(sortedColors.prefix(count))
        
        var rgbColors: [RGBColor] = []
        for rgbColor in dominantColors {
            rgbColors.append(RGBColor(rgbColor))
        }
        let colors = [UIColor(red: 22.0 / 255.0, green: 4.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0),
                      UIColor(red: 240.0 / 255.0, green: 54.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
                      UIColor(red: 79.0 / 255.0, green: 216.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
                      UIColor(red: 74.0 / 255.0, green: 0.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)]
        for color in colors {
            rgbColors.append(RGBColor(color))
        }
        return rgbColors
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
