import Foundation
import NeteaseRequest


enum Settings {
    @UserDefaultCodable("Settings.audioQuality", defaultValue: NRSongLevel.lossless)
    static var audioQuality: NRSongLevel
    
    @UserDefaultCodable("Settings.hotComment", defaultValue: true)
    static var hotComment: Bool

    @UserDefaultCodable("Settings.service", defaultValue: "http://127.0.0.1:\(ApiService.port)")
    static var service: String
    
    @UserDefaultCodable("Settings.fluidBg", defaultValue: true)
    static var fluidBg: Bool
    
}

extension NRSongLevel {
    var desp: String {
        switch self {
        case .standard:
            return "标准"
        case .higher:
            return "较高"
        case .exhigh:
            return "极高"
        case .lossless:
            return "无损"
        case .hires:
            return "Hi-Res"
        case .jyeffect:
            return "高清环绕声"
        case .sky:
            return "沉浸环绕声"
        case .jymaster:
            return "超清母带"
        }
    }
}
