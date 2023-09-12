//
//  ViewController.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit
import NeteaseRequest
class ViewController: UIViewController {
    
    var allModels: [CustomAudioModel] = [CustomAudioModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            wk_player.delegate = self
            wk_player.allOriginalModels = await loadData()
            try? wk_player.play(index: 0)
        }
        
        
    }
    
    
    func loadData() async -> [CustomAudioModel] {
        let songModels:[NRSongModel] = try! await fetchPlayListTrackAll(id: 53558869)
        self.allModels.removeAll()
        for songModel in songModels {
            let model = CustomAudioModel()
            model.audioId = songModel.id
            model.isFree = 1
            model.freeTime = 0
            model.audioTitle = songModel.name
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
    }
    
    func didPlayToEnd(dataSource: WKPlayerDataSource, isTheEnd: Bool) {
        debugPrint("数据源\(dataSource.wk_sourceName!)已播放至结尾")
    }
    
    
    func noPermissionToPlayDataSource(dataSource: WKPlayerDataSource) {
        debugPrint("没有权限播放\(dataSource.wk_sourceName!)")
    }
    
    func didReadTotalTime(totalTime: UInt, formatTime: String) {
        debugPrint("已经读取到时长为duration = \(totalTime), format = \(formatTime)")
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
        debugPrint("进度\(currentTime)")
    }
    
    
    func dataSourceDidChange(lastOriginal: [WKPlayerDataSource]?, lastAvailable: [WKPlayerDataSource]?, nowOriginal: [WKPlayerDataSource]?, nowAvailable: [WKPlayerDataSource]?) {
        
        
        
    }
    
    func unifiedExceptionHandle(error: WKPlayerError) {
        debugPrint(error.errorDescription as Any)
        
        let alert = UIAlertController.init(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: "ok", style: .default, handler: nil)
        alert.addAction(confirm)
        self.present(alert, animated: true)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

