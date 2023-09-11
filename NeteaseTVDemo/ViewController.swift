//
//  ViewController.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit
import NeteaseRequest
class ViewController: UIViewController {
    
    var allModels: [CustomAudioModel] {
        get {
            
            let model1 = CustomAudioModel()
            model1.audioId = 5025180
            model1.isFree = 1
            model1.freeTime = 0
            model1.audioTitle = "Titoli"
            
            let model2 = CustomAudioModel()
            model2.audioId = 5025186
            model2.isFree = 1
            model2.freeTime = 0
            model2.audioTitle = "Doppi Giochi"
            
            let model3 = CustomAudioModel()
            model3.audioId = 5025187
            model3.isFree = 1
            model3.freeTime = 0
            model3.audioTitle = "Per un Pugno di Dollari"
            
            let model4 = CustomAudioModel()
            model3.audioId = 5025187
            model3.isFree = 1
            model3.freeTime = 0
            model3.audioTitle = "Per Qualche Dollaro In Piu"
            
            let model5 = CustomAudioModel()
            model3.audioId = 5025187
            model3.isFree = 1
            model3.freeTime = 0
            model3.audioTitle = "La Resa Dei Conti"
            
            let model6 = CustomAudioModel()
            model3.audioId = 5025187
            model3.isFree = 1
            model3.freeTime = 0
            model3.audioTitle = "Il Vizio Di Uccidere"
            
            return [model1, model2, model3, model4, model5, model6]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wk_player.delegate = self
        wk_player.allOriginalModels = allModels
        
        try? wk_player.play(index: 0)
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
//        debugPrint(error.errorDescription as Any)
        
        let alert = UIAlertController.init(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: "ok", style: .default, handler: nil)
        alert.addAction(confirm)
        self.present(alert, animated: true)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

