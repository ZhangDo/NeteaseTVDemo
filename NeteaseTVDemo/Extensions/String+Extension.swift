
import Foundation


extension String {
    ///歌词解析
    func parserLyric() -> (times: [String], words: [String]) {
        var lineLyrics: [String] = []
        var words: [String] = []
        var times: [String] = []
        let seps = self.components(separatedBy: "[")
        for lineLyric in seps {
            if seps.count > 0 {
                lineLyrics = lineLyric.components(separatedBy: "]")
                if  lineLyric != "\n" {
                    times.append(lineLyrics.first ?? "0")
                    words.append(lineLyrics.count > 1 ? lineLyrics[1] : "")
                }
            }
        }
        return (times, words)
    }
    
    ///播放时间条转换成秒的格式
    func convertToSeconds() -> UInt {
        let components = self.split(separator: ":")
        guard components.count == 2 else { return 0 }
        
        let minuteSeconds = Double(components[0])! * 60
        let seconds = Double(components[1])!
        
        return UInt(round(minuteSeconds + seconds))
    }
    
}
