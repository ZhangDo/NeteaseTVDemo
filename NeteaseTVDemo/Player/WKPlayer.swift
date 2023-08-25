//
//  WKPlayer.swift
//  neteaseTVDemo
//
//  Created by fengyn on 2023/8/25.
//

import UIKit
import AVFoundation

public let wk_player = WKPlayer.instance

public enum WKPlayerState: String {
    case idle = "闲置中"
    case isPlaying = "正在播放中"
    case isBuffering = "正在缓冲中"
    case paused = "暂停"
    case stoped = "结束"
    case failed = "失败"
}

// MARK: —————————— 倒计时功能 ——————————
public enum WKPlayerCountdown {
    case none
    /** 播放完N条后停止*/
    case endCount(dataSourceCount: UInt)
    /** N秒后结束播放*/
    case endSecond(seconds: UInt)
}

private enum WKPlayerObserverKey: String {
    case status = "status"
    case loadedTimeRanges = "loadedTimeRanges"
    case playbackBufferEmpty = "playbackBufferEmpty"
    case playbackLikelyToKeepUp = "playbackLikelyToKeepUp"
}
// MARK: —————————— 播放器数据源类型 ——————————
public enum WKPlayerSourceType {
    /** 没有权限*/
    case noPermission
    /** 完整播放*/
    case full
    /** 部分播放，参数为允许播放时长*/
    case partly(length: UInt)
    
}
public enum WkPlayerSeekTime {
    case none
    case seekToTime(to: Float)
}

// MARK: —————————— 播放器数据源协议 ——————————
public protocol WKPlayerDataSource {
    var wk_playURL: String { get }
    ///文件名称
    var wk_sourceName: String? { get }
    var wk_sourceType: WKPlayerSourceType { get }
}

//MARK: —————————— 播放器功能 ——————————
public struct WKPlayerFunction: OptionSet {
    public let rawValue: UInt
    
    ///默认
    public static let `default` = WKPlayerFunction(rawValue: 1<<0)
    ///缓存
    public static let cache = WKPlayerFunction(rawValue: 1<<1)
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
}

// MARK: —————————— 播放协议 ——————————
public protocol WKPlayerDelegate {
    func configePlayer()
    ///
    func dataSourceDidChange(lastOriginal: [WKPlayerDataSource]?, lastAvailable: [WKPlayerDataSource]?, nowOriginal: [WKPlayerDataSource]?, nowAvailable: [WKPlayerDataSource]?)
    ///播放源将要切换
    func playDataSourceWillChange(now: WKPlayerDataSource?, new: WKPlayerDataSource?)
    ///播放源已经切换
    func playDataSourceDidChange(last: WKPlayerDataSource?, now: WKPlayerDataSource?)
    ///已经获取到数据源的时长
    func didReadTotalTime(totalTime: UInt, formatTime: String)
    
}


public class WKPlayer: NSObject {
    static let instance = WKPlayer()
    private override init() {
        super.init()
    }
    
    /** 当前正在播放数据源的状态*/
    private (set) public var currentModelState: WKPlayerStateModel?
    
    public var state = WKPlayerState.idle {
        didSet  {
            if oldValue != state {
                //TODO: 更新状态
            }
        }
    }
    
    public var progress: Float = 0 {
        didSet {
            currentModelState?.progress = progress
//            let current = progress *Float(<#T##value: BinaryInteger##BinaryInteger#>)
        }
    }
    
    
    private (set) public var player: AVPlayer?
    
}
