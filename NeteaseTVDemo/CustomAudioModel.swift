//
//  CustomAudioModel.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit

class CustomAudioModel: WKPlayerDataSource {
    /** 需要具体描述音频数据源的播放类型，共有3种类型，
     /** 没有权限*/
     case noPermission
     /** 完整播放*/
     case full
     /** 部分播放，参数为允许播放时长*/
     case partly(length: UInt)
     */
    var wk_sourceType: WKPlayerSourceType {
        get {
            if isFree == 1 {
                return .full
            } else if let length = freeTime {
                return .partly(length: length)
            } else {
                return .noPermission
            }
        }
    }
    
    var wk_playURL: String? {
        get {
            return audioUrl
        }
    }
    
    var wk_sourceName: String? {
        get {
            return audioTitle
        }
    }
    
    /** 音频地址*/
    var audioUrl: String?
    /** 音频标题*/
    var audioTitle: String?
    /** 是否可以完整播放*/
    var isFree: Int?
    /** 不可以完整播放时能播放的秒数*/
    var freeTime: UInt?
}
