//
//  NowPlayingInfo.swift
//  NeteaseTVDemo
//
//  Created by DLancerC on 2023/12/16.
//

import MediaPlayer


class WKNowPlayingInfo {
    // Avoid multi-thread accessing crashs.
    private(set) var existed: LockDictionary = LockDictionary.init(value: [MPMediaItemPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue])

    private lazy var _queue: DispatchQueue = {
        .init(label: "com.wk.Vibefy.nowplayinginfo", qos: .userInitiated)
    }()
}

extension WKNowPlayingInfo {

    func update(work: @escaping (WKNowPlayingInfo) -> Void) {
        work(self)
        existed.read { [weak self] in self?.set(info: $0) }
    }

    func set(info: [String: Any]?) {
        _queue.async { MPNowPlayingInfoCenter.default().nowPlayingInfo = info }
    }

    func reset() {
        existed.write { $0 = [:] }
        _queue.async { MPNowPlayingInfoCenter.default().nowPlayingInfo = nil }
    }

    @discardableResult
    func title(_ title: String?) -> Self {
        existed.write { $0[MPMediaItemPropertyTitle] = title }
        return self
    }

    @discardableResult
    func artist(_ artist: String?) -> Self {
        existed.write { $0[MPMediaItemPropertyArtist] = artist }
        return self
    }

    @discardableResult
    func artwork(_ artwork: UIImage) -> Self {
        existed.write {
            $0[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        return self
    }

    @discardableResult
    func rate(_ rate: Float) -> Self {
        existed.write { $0[MPNowPlayingInfoPropertyPlaybackRate] = rate }
        return self
    }

    @discardableResult
    func duration(_ duration: TimeInterval) -> Self {
        existed.write { $0[MPMediaItemPropertyPlaybackDuration] = duration }
        return self
    }

    @discardableResult
    func time(_ time: TimeInterval) -> Self {
        existed.write { $0[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time }
        return self
    }
    
    @discardableResult
    func id(_ id: Int) -> Self {
        let idKey = "audioId"
        if let audioId = existed.read({ $0[idKey]}) {
            if audioId as! Int != id {
                reset()
            }
        }
        existed.write { $0[idKey] = id }
        return self
    }

    @discardableResult
    func extra(_ extra: [String: Any]?) -> Self {
        guard let extra else { return self }
        existed.write { $0.merge(extra) { $1 } }
        return self
    }
}

final class LockDictionary {
    private let lock = NSLock()
    private var value: [String: Any]
    init(value: [String: Any]) {
        self.value = value
    }

    var wrappedValue: [String: Any] {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }

    var projectedValue: LockDictionary { self }

    init(wrappedValue: [String: Any]) {
        value = wrappedValue
    }

    func read<U>(_ closure: ([String: Any]) -> U) -> U {
        lock.around { closure(value) }
    }

    func write<U>(_ closure: (inout [String: Any]) -> U) -> U {
        lock.around { closure(&value) }
    }
}

protocol Lockable {
    func lock()
    func unlock()
}

extension Lockable {
    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
}

extension NSLock: Lockable {}
