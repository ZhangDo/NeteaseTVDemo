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
            model1.audioUrl = "http://m701.music.126.net/20230825213436/731a74321f3f2cdda6ee7c5c31f3b937/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/19699213280/1e60/deab/6921/c2cc2014ded5613e1e4c6e6f87ec67f3.mp3"
            model1.isFree = 1
            model1.freeTime = 0
            model1.audioTitle = "音频1"
            
            let model2 = CustomAudioModel()
            model2.audioUrl = "http://m7.music.126.net/20230825214319/46a0221ad09a07d6ae51ba77900c39eb/ymusic/obj/w5zDlMODwrDDiGjCn8Ky/3915666993/252e/5a18/3bf6/7738bbd7ffa009c4fbfd62a1d24203d3.mp3"
            model2.isFree = 0
            model2.freeTime = 100
            model2.audioTitle = "音频2"
            
            let model3 = CustomAudioModel()
            model3.audioUrl = "http://m702.music.126.net/20230825214343/994b8d80e8910277e9dd3484794e06cd/jd-musicrep-ts/6a82/0f8d/b485/7c11722bef48eea2c06cf8ca7b1bed0c.mp3"
            model3.isFree = 0
            model3.freeTime = 0
            model3.audioTitle = "音频3"

            /**
             音频1:可以播放完整音频
             音频2:可以播放100秒
             音频3:不可以播放
             */
            return [model1, model2, model3]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wk_player.delegate = self
        wk_player.allOriginalModels = allModels
        
        try? wk_player.play(index: 0)
    }


}

extension ViewController: WKPlayerDelegate {
    
    func configePlayer() {
        wk_player.function = [.cache]
    }
    
    func playDataSourceWillChange(now: WKPlayerDataSource?, new: WKPlayerDataSource?) {
        debugPrint("设置上一个数据源，说明要切换音频了，当前是\(now?.wk_sourceName!)，即将播放的是\(new?.wk_sourceName!)")
    }
    
    func playDataSourceDidChanged(last: WKPlayerDataSource?, now: WKPlayerDataSource) {
        debugPrint("设置新的数据源，说明已经切换音频了，原来是\(last?.wk_sourceName!)，当前是\(now.wk_sourceName!)")
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
        let durationTime = wk_playerTool.formatTime(seconds: detail.duration)
//        audioDurationLbl.text = currentTime + "/" + durationTime
//        bufferProgress.progress = detail.buffer
//        audioProgressSlider.value = detail.progress
        debugPrint("进度\(currentTime)")
    }
    
    
    func dataSourceDidChange(lastOriginal: [WKPlayerDataSource]?, lastAvailable: [WKPlayerDataSource]?, nowOriginal: [WKPlayerDataSource]?, nowAvailable: [WKPlayerDataSource]?) {
        
        
        
    }
    
    func unifiedExceptionHandle(error: WKPlayerError) {
        debugPrint(error)
        
//        let alert = UIAlertController.init(title: "Error", message: error.errorDescription, preferredStyle: .alert)
//        let confirm = UIAlertAction.init(title: "ok", style: .default, handler: nil)
//        alert.addAction(confirm)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

