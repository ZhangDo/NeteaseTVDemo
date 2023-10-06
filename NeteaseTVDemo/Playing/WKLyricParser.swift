
import UIKit

class WKLyricParser: NSObject {

}

func parserLyric(lyric: String) -> (times: [String], words: [String]) {
    var lineLyrics: [String] = []
    var words: [String] = []
    var times: [String] = []
    let seps = lyric.components(separatedBy: "[")
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
