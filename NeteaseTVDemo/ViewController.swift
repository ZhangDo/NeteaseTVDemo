//
//  ViewController.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit

class ViewController: UIViewController {
    
    var allModels: [CustomAudioModel] {
        get {
            
            let model1 = CustomAudioModel()
            model1.audioUrl = "http://m702.music.126.net/20230826113535/decafc4ab8fb39f373e9ebbc4ac2bd2d/jd-musicrep-ts/d793/92f8/4f25/b8e48ba861e9bceb4b346e0fe25ad383.mp3"
            model1.isFree = 1
            model1.freeTime = 0
            model1.audioTitle = "画"
            
            let model2 = CustomAudioModel()
            model2.audioUrl = "http://m801.music.126.net/20230826113554/b60c400d5eb39e312ffc1bfdfbcbbdd7/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/14096441296/e92c/4fed/0188/7999b19d0e517402cc7157d1103426cc.mp3"
            model2.isFree = 1
            model2.freeTime = 0
            model2.audioTitle = "簇拥烈日的花"
            
            let model3 = CustomAudioModel()
            model3.audioUrl = "http://m7.music.126.net/20230826113617/c373aadf0fbbd985aff52b79941bc561/ymusic/obj/w5zDlMODwrDDiGjCn8Ky/14053489035/c480/f221/194e/d330f85f6077e73010ce81539f802972.mp3"
            model3.isFree = 1
            model3.freeTime = 0
            model3.audioTitle = "风吟诛仙"

            return [model1, model2, model3]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wk_player.delegate = self
        wk_player.allOriginalModels = allModels
        
        try? wk_player.play(index: 0)
    }

    @IBAction func backward(_ sender: Any) {
        Task {
            await wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current + 15) / Float(wk_player.totalTime)))
        }
        
    }
    
    @IBAction func forward(_ sender: Any) {
        
        Task {
            await wk_player.prepareForSeek(to: (Float(wk_player.currentModelState!.current + 15) / Float(wk_player.totalTime)))
        }
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

