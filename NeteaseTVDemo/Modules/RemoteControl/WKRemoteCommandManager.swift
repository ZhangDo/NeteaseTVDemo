//
//  WKRemoteControlCommandManager.swift
//  NeteaseTVDemo
//
//  Created by DLancerC on 2023/12/23.
//

import Foundation
import MediaPlayer

class WKRemoteCommandManager {
    fileprivate let remoteCommandCenter = MPRemoteCommandCenter.shared()
    let player : WKPlayer
    
    init(player: WKPlayer) {
        self.player = player
    }
    
    func playTrackCommand() -> Self {
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.playCommand.addTarget { event in
            if !wk_player.isPlaying {
                wk_player.resumePlayer()
            }
            return .success
        }
        return self
    }
    
    func pauseTrackCommand() -> Self {
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget { event in
            if wk_player.isPlaying {
                wk_player.pausePlayer()
            }
            return .success
        }
        return self
    }
    
    func nextTrackCommand() -> Self {
        remoteCommandCenter.nextTrackCommand.isEnabled = true
        remoteCommandCenter.nextTrackCommand.addTarget { event in
            do {
                try wk_player.playNext()
            } catch {
                debugPrint(error)
            }
            return .success
        }
        return self
    }
    
    func previousTrackCommand() -> Self {
        remoteCommandCenter.previousTrackCommand.isEnabled = true
        remoteCommandCenter.previousTrackCommand.addTarget { event in
            // 处理暂停操作的逻辑
            do {
                try wk_player.playLast()
            } catch {
                debugPrint(error)
            }
            return .success
        }
        return self
    }
    
//    func changePlaybackPositionTrackCommand() {
//        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = true
//        remoteCommandCenter.changePlaybackPositionCommand.addTarget { event in
//            let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
//            wk_player.prepareForSeek(to: Float(seconds) / Float(wk_player.totalTime))
//            wk_player.resumePlayer()
//            return .success
//        }
//    }
    
}
