//
//  WKPlayerTool.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import UIKit
import AVFoundation
import CryptoKit
import Alamofire

public let wk_playerTool = WKPlayerTool.instance

public enum NetworkStatus {
    case notReachable, wifi, cellular
}

public class WKPlayerTool {
    static let instance = WKPlayerTool()
    
    public var netStatus: NetworkStatus = .wifi
    
    private let netManager = NetworkReachabilityManager.init(host: "https://www.baidu.com")
    
    public func initConfig() {
        startListen()
    }
    /** 开启网络监听*/
    public func startListen() {
        
        netManager?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable:
                self.netStatus = .notReachable
            case .unknown:
                self.netStatus = .notReachable
            case .reachable(.ethernetOrWiFi):
                self.netStatus = .wifi
            case .reachable(.cellular):
                self.netStatus = .cellular
            }
        })
    }
    
    
    public func formatTime(seconds: UInt) -> String {
        if seconds == 0 {
            return "00:00"
        }
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = seconds % 60
        
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
    
    /// 根据数据源地址读取数据源播放时长
    public func readDuration(url urlString: String) async -> UInt {
        if let url = URL(string: urlString) {
            let asset = AVURLAsset(url: url)
            if let duration = try? await asset.load(.duration) {
                let seconds = CMTimeGetSeconds(duration)
                if seconds > 0 {
                    return UInt(ceil(seconds))
                }
            }
        }
        return 0
    }
    
    
    public func download(_ url: URL, downloadProgress: ((Double) -> ())?, completionHandler: ((URL) -> ())?) {
        
        guard let cache = generateCachePath(original: url.absoluteString) else {
            return
        }
        let cacheURL = URL.init(fileURLWithPath: cache)
        AF.download(url, to: { (_, _) -> (destinationURL: URL, options: DownloadRequest.Options) in
            return (cacheURL, [.removePreviousFile, .createIntermediateDirectories])
        })
        .downloadProgress { progress in
            downloadProgress?(progress.fractionCompleted)
        }
        .response { response in
            if let error = response.error {
                debugPrint(error)
            } else {
                completionHandler?(cacheURL)
            }
        }
        
    }
    
    public func checkFileExist(url: String) -> String? {
        guard let cache = generateCachePath(original: url) else {
            return nil
        }
        let result = FileManager.default.fileExists(atPath: cache)
        guard result else {
            return nil
        }
        return cache
    }
    
    public func generateCachePath(original: String) -> String? {
        guard let url = URL.init(string: original) else {
            return nil
        }
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let fileType = url.pathExtension
        guard !fileType.isEmpty else {
            return nil
        }
        let cachePath = cacheDir + "/WKPlayer/" + url.absoluteString.sha256 + ".\(fileType)"
        return cachePath
    }
}


extension String {
    
    var sha256: String {
        get {
            let data = self.data(using: .utf8)!
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }
    }
    
}
