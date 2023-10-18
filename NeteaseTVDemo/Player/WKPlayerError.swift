//
//  WKPlayerError.swift
//  NeteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import Foundation

public enum WKPlayerError: Error {
    case dataSourceError(reason: DataSourceError)
    case networkError(reason: NetworkError)
//    case functionError
    case playerStatusError(reason: PlayerStatusError)
    
    ///数据源错误
    public enum DataSourceError {
        case lackOfDataSource
        case noPermission
        case invalidDataSource
        case noLastDataSource
        case noNextDataSource
        case needBuyAlbum
        case needVip
    }
    
    ///网络错误
    public enum NetworkError {
        ///网络不可用
        case notReachable
        ///网络超时
        case timeout
    }
    
    
    ///播放器状态异常
    public enum PlayerStatusError {
        ///未知异常
        case unknown
        ///播放器状态异常，无法播放
        case failed
    }
    
}

extension WKPlayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataSourceError(let reason):
            return reason.localizedDescription
        case .networkError(let reason):
            return reason.localizedDescription
        case .playerStatusError(let reason):
            return reason.localizedDescription
        }
    }
}

extension WKPlayerError.DataSourceError {
    public var localizedDescription: String {
        switch self {
        case .lackOfDataSource:
            return "缺少数据源"
        case .noPermission:
            return "暂无版权"
        case .invalidDataSource:
            return "无效数据源，没有播放地址的数据源"
        case .noLastDataSource:
            return "没有上一条数据"
        case .noNextDataSource:
            return "没有下一条数据"
        case .needBuyAlbum:
            return "需要到网易云音乐购买专辑"
        case .needVip:
            return "需要网易云音乐 VIP 权限"
        }
    }
}

extension WKPlayerError.NetworkError {
    public var localizedDescription: String {
        switch self {
        case .notReachable:
            return "Network is not reachable."
        case .timeout:
            return "Network is timeout."
        }
    }
}

extension WKPlayerError.PlayerStatusError {
    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "There is an unknown error occurs while playing."
        case .failed:
            return "Player play failed."
        }
    }
}
