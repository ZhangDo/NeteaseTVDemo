
import UIKit
import NeteaseRequest
public class CustomAudioModel: WKPlayerDataSource {
    
    /** 需要具体描述音频数据源的播放类型，共有3种类型，
     /** 没有权限*/
     case noPermission
     /** 完整播放*/
     case full
     /** 部分播放，参数为允许播放时长*/
     case partly(length: UInt)
     */
    public var wk_sourceType: WKPlayerSourceType {
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
    
    public var wk_playURL: String? {
        get {
            return audioUrl
        }
    }
    
    public var wk_audioId: Int? {
        get {
            return audioId
        }
    }
    
    public var wk_audioPic: String? {
        get {
            return audioPicUrl
        }
    }
    
    
    public var wk_sourceName: String? {
        get {
            return audioTitle
        }
    }
    
    public var wk_singerName: String? {
        get {
            return singer
        }
    }
    /** 歌手*/
    var singer: String?
    /** 音频id*/
    var audioId: Int?
    /** 音频地址*/
    var audioUrl: String?
    /** 音频标题*/
    var audioTitle: String?
    var albumTitle: String?
    var transTitle: String?
    var fee: NRFee?
    
    /** 音频质量*/
    var audioQuality: String?
    
    /** 音频时长*/
    var audioTime: String?
    
    /** 音频封面*/
    var audioPicUrl: String?
    
    /** 是否可以完整播放*/
    var isFree: Int?
    /** 不可以完整播放时能播放的秒数*/
    var freeTime: UInt?
}
