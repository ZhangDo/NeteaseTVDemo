
import UIKit
public let wk_countdown = WKCountdown.instance

// MARK: —————————— 定时器功能 ——————————
public struct WKCountdownFunction: OptionSet {
    
    public let rawValue: Int
    /** 默认*/
    public static let `default` = WKCountdownFunction(rawValue: 1 << 0)
    /** 定时器暂停，只在本类内可使用*/
    fileprivate static let pause = WKCountdownFunction(rawValue: 1 << 1)
    /** 定时器运行，只在本类内可使用*/
    fileprivate static let timing = WKCountdownFunction(rawValue: 1 << 2)
    /** 持久化，是否需要杀死程序后仍然开启计时*/
    public static let cache = WKCountdownFunction(rawValue: 1 << 3)
    /** 持久化时是否需要保持计时*/
    public static let remainTiming = WKCountdownFunction(rawValue: 1 << 4)
    
    @discardableResult
    public mutating func add(_ function: WKCountdownFunction) -> WKCountdownFunction {
        if function.contains(.pause) {
            self.xor(.timing)
        } else if function.contains(.timing) {
            self.xor(.pause)
        }
        self = WKCountdownFunction.init(rawValue: self.rawValue | function.rawValue)
        return self
    }
    
    @discardableResult
    /** 异或操作*/
    public mutating func xor(_ function: WKCountdownFunction) -> WKCountdownFunction {
        if self.contains(function) {
            self = WKCountdownFunction.init(rawValue: self.rawValue ^ function.rawValue)
        }
        return self
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/** 计时器详细信息*/
public class CountdownDetailInfo {
    /** 功能状态值*/
    var state: Int = 0
    /** 已经运行时长*/
    var run: UInt = 0
    /** 剩余时长*/
    var left: UInt = 0
    /** 总计时长*/
    var total: UInt = 0
    /** 定时器对象*/
    var timer: Timer = Timer()
    /** 节点时间戳*/
    var checkpointStamp: Double = 0
    /** 结束时间戳*/
    var endStamp: Double = 0
    /** 唯一标识符*/
    var key: String = ""
    /** 本次运行时长*/
    var runThisTime: UInt = 0
    
    func start() {
        wk_countdown.pauseOrResumeCountdown(key: key, forcePause: false)
    }
    
    func pause() {
        wk_countdown.pauseOrResumeCountdown(key: key, forcePause: true)
    }
    
    func drop() {
        wk_countdown.removeCountdown(key: key)
    }
}


extension Array where Element == WKCountdownFunction {
    
    @discardableResult
    mutating func add(_ function: WKCountdownFunction) -> [WKCountdownFunction] {
        self.append(function)
        return self
    }
    
    @discardableResult
    /** 异或操作*/
    mutating func xor(_ function: WKCountdownFunction) -> [WKCountdownFunction] {
        self.enumerated().forEach { (offset, element) in
            guard element == function else {
                return
            }
            self.remove(at: offset)
        }
        return self
    }
}

public class WKCountdown: NSObject {
    
    static let instance = WKCountdown()
   
    private override init() {
        super.init()
    }
    // MARK: —————————— 公开属性 ——————————

    /** 未完成的倒计时字典，key为倒计时识别码，value中为详细信息字典，其键值对应如下
     state: Int 功能状态值
     run: Double 已经运行时长
     runThisTime: Double 从本次开始到暂停时运行时长
     left: Double 剩余时长
     total: Double 总计时长
     timer: Timer 定时器对象
     */
    public var allAvailableCountdown = [String: CountdownDetailInfo]()
    /** 定时器根标记*/
    public var countdownMark = "XTCountdown"
    
    // MARK: —————————— 私有属性 ——————————
    private var enterBackground = false
    /** 定时器内部标记*/
    private var innerMark = "XTCountdown"
    /** 后台任务标记*/
    private var backgroundTaskID: UIBackgroundTaskIdentifier! = nil
    
    /** 全部未完成的闭包, key对应计时器识别码，value中键值属性同allAvailableCountdown*/
    private var allProgressHandler = [String: (inout CountdownDetailInfo) -> ()]()
    
    // MARK: —————————— 公开方法 ——————————
    /** 初始化配置*/
    public func initConfig() {

        readAllCountdown()
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    /// 根据指定识别码读取计时器
    ///
    /// - Parameters:
    ///   - key: 指定计时器识别码
    ///   - progressHandler: 监听进度的闭包
    /// - Returns: 第一个元素代表是否存在以该识别码存储的未完成的倒计时, 第二个元素代表该计时器是否在计时中
    public func checkCountdown(key: String, progressHandler: ((inout CountdownDetailInfo) -> ())? = nil) -> (Bool, Bool) {
        
        guard var countdown = allAvailableCountdown[key] else {
            return (false, false)
        }
        let left = countdown.left
        let state = countdown.state
        
        guard left > 0 else {
            allAvailableCountdown.removeValue(forKey: key)
            return (false, false)
        }
        if let progress = progressHandler {
            allProgressHandler[key] = progress
            DispatchQueue.main.async {
                progress(&countdown)
            }
        }
        let stateFunction = WKCountdownFunction.init(rawValue: state)
        if stateFunction.contains(.timing) {
//            debugPrint("read：计时器在计时中")
            return (true, true)
        } else {
//            debugPrint("read：计时器在暂停中")
            return (true, false)
        }
    }
    
    /// 根据计时器识别码删除计时器
    ///
    /// - Parameter key: 计时器识别码
    public func removeCountdown(key: String) {

        if let countdown = allAvailableCountdown[key] {
            let timer = countdown.timer
            timer.invalidate()
            allAvailableCountdown.removeValue(forKey: key)
        }
        if let _ = allProgressHandler[key] {
            allProgressHandler.removeValue(forKey: key)
        }
        
        if var dict = UserDefaults.standard.dictionary(forKey: innerMark + countdownMark) {
            for savedCountdownDict in dict {
                let savedKey = savedCountdownDict.key
                if key == savedKey {
                    dict.removeValue(forKey: key)
                }
            }
            UserDefaults.standard.setValue(dict, forKey: innerMark + countdownMark)
            UserDefaults.standard.synchronize()
        }
    }

    /// 暂停倒计时
    ///
    /// - Parameter key: 倒计时的识别码
    /// - Returns: 计时器详细数组
    @discardableResult
    public func pauseOrResumeCountdown(key: String, forcePause: Bool? = nil) -> CountdownDetailInfo? {
        let result = checkCountdown(key: key)
        // 没有
        guard result.0 else { return nil }
        guard let countdown = allAvailableCountdown[key] else {
            return nil
        }
        var state = countdown.state
        let timer = countdown.timer

        let function = WKCountdownFunction.init(rawValue: state)
        var newFunction = function
        if let force = forcePause {
            // 正在运行计时器
            if force {
                newFunction.add(.pause)
            } else {
                newFunction.add(.timing)
            }
        } else {
            // 正在运行计时器
            if result.1 {
                newFunction.add(.pause)
            } else {
                newFunction.add(.timing)
            }
        }
        let temp = countdown
        if newFunction.contains(.pause) {
//            debugPrint("write：计时器状态为暂停")
        } else if newFunction.contains(.timing) {
//            debugPrint("write：计时器状态为计时中")
            temp.runThisTime = 0
        }
        state = newFunction.rawValue
        
        temp.state = state
        temp.checkpointStamp = Date().timeIntervalSince1970
        allAvailableCountdown[key] = temp
        if newFunction.contains(.pause) {
            timer.fireDate = .distantFuture
        } else if newFunction.contains(.timing) {
            timer.fireDate = .distantPast
        }
        return temp
    }
    
    
    
    /// 开启倒计时
    ///
    /// - Parameters:
    ///   - key: 计时器识别码
    ///   - seconds: 结束时间秒数
    ///   - function: 要对计时器设置的功能
    ///   - onlyStart: 只是开启，并不暂停
    ///   - progress: 监听进度的闭包，闭包中第一个元素为剩余秒数，第二个元素为是否完成标记
    /// - Returns: 计时器元组
    @discardableResult
    public func startCountdown(key: String, seconds: UInt, function: WKCountdownFunction = .default, onlyStart: Bool = false, progressHandler progress: ((inout CountdownDetailInfo) -> ())? = nil) -> CountdownDetailInfo? {

        enum OperateType {
            /** 开启*/
            case start
            /** 暂停或恢复*/
            case pauseOrResume
        }
        
        var left = seconds
        var total: UInt = 0
        var state: Int = 0
        var timer = Timer()
        let checkpointStamp = Date().timeIntervalSince1970
        let endStamp = Date().addingTimeInterval(TimeInterval(seconds)).timeIntervalSince1970

        var operate = OperateType.start
        
        let result = checkCountdown(key: key)
        // 如果有存储的计时器
        if result.0, let countdown = allAvailableCountdown[key] {
            
            left = countdown.left
            total = countdown.total
            // 如果总时长一致
            if total == seconds, !onlyStart {
                operate = .pauseOrResume
            }
        }
        
        // 如果需要监听进度，就保存到内存中
        if let progressHandler = progress {
            allProgressHandler[key] = progressHandler
        }
        switch operate {
        case .start:
            timer.invalidate()
            var newfunction = function
            newfunction.add(.timing)
            state = newfunction.rawValue
            timer = Timer.init(timeInterval: 1, target: self, selector: #selector(beginCountdown(timer:)), userInfo: key, repeats: true)
            
            let temp = CountdownDetailInfo()
            temp.key = key
            temp.left = left
            temp.state = state
            temp.total = seconds
            temp.timer = timer
            temp.checkpointStamp = checkpointStamp
            temp.endStamp = endStamp
            allAvailableCountdown[key] = temp
            performSelector(inBackground: #selector(startTimer), with: nil)
            return temp
            
        case .pauseOrResume:
           return pauseOrResumeCountdown(key: key)
        }
        
    }
    
    /// 清除所有计时器
    public func clearUp() {
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix(innerMark) {
                UserDefaults.standard.removeObject(forKey: key)
                UserDefaults.standard.synchronize()
            }
        }
        
        allAvailableCountdown.enumerated().forEach { (offset, element) in
            let timer = element.value.timer
            let key = element.key
            timer.invalidate()
            removeCountdown(key: key)
        }

    }
    
    
    /// 根据前缀清除计时器
    ///
    /// - Parameter forPrefix: 前缀
    public func removeCountdown(forPrefix prefix: String) {
        allAvailableCountdown.enumerated().forEach { (offset, element) in
            let timer = element.value.timer
            let key = element.key
            if key.hasPrefix(prefix) {
                timer.invalidate()
                removeCountdown(key: key)
            }
        }
        
    }
    
    // MARK: —————————— 私有方法 ——————————
    @objc private func startTimer() {
        if !Thread.isMainThread {
            for countdownDict in allAvailableCountdown {
                let countdown = countdownDict.value
                let timer = countdown.timer
                let state = countdown.state
                let function = WKCountdownFunction.init(rawValue: state)
                if function.contains(.timing) {
                    timer.fireDate = Date.distantPast
                } else {
                    timer.fireDate = Date.distantFuture
                }
                RunLoop.current.add(timer, forMode: .common)
            }
            RunLoop.current.run()
        }
    }
    
    @objc private func beginCountdown(timer: Timer) {
        guard let key = timer.userInfo as? String else { return }
        guard let countdown = allAvailableCountdown[key] else { return }
        
        let timer = countdown.timer
        var left = countdown.left
        let total = countdown.total
        var runThisTime = countdown.runThisTime
        left -= 1
        runThisTime += 1
        var temp = countdown
        temp.run = total - left
        temp.left = left
        temp.runThisTime = runThisTime
//        debugPrint("key = \(key), 剩余时间 = \(left), run = \(temp.run), runThisTime = \(runThisTime)")
        
        allAvailableCountdown[key] = temp
        
        if let progressHandler = allProgressHandler[key] {
            DispatchQueue.main.async {
                progressHandler(&temp)
            }
        }
        
        if left <= 0 {
            timer.invalidate()
            removeCountdown(key: key)
            recordAllUnfinishedCountdown(justRecord: true)
        }
    }
    
    /** 程序即将关闭*/
    @objc private func applicationWillTerminate() {
        recordAllUnfinishedCountdown()
    }
    
    /** 程序即将失去响应身份*/
    @objc private func applicationWillResignActive() {
        recordAllUnfinishedCountdown(justRecord: true)
    }
    
    /** 程序已经进入后台*/
    @objc private func applicationDidEnterBackground() {
        
        let application = UIApplication.shared
        
        // 延迟程序静止的时间
        DispatchQueue.main.async() {
            //如果已存在后台任务，先将其设为完成
            if self.backgroundTaskID != nil {
                application.endBackgroundTask(self.backgroundTaskID)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
        }
        
        //如果要后台运行
        backgroundTaskID = application.beginBackgroundTask(expirationHandler: {
            () -> Void in
            //如果没有调用endBackgroundTask，时间耗尽时应用程序将被终止
            application.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        })
    }
    
    
    /// 记录所有未完成的计时
    ///
    /// - Parameter justRecord: 仅仅是做缓存记录，并不停止计时器
    private func recordAllUnfinishedCountdown(justRecord: Bool = false) {
        var dict = [String: Any]()
        
        allAvailableCountdown.enumerated().forEach { (offset, element) in
            let key = element.key
            
            let countdown = element.value
            let timer = countdown.timer
            let state = countdown.state
            let left = countdown.left
            let total = countdown.total
            let run = countdown.run
            let checkpointStamp = countdown.checkpointStamp
            let endStamp = countdown.endStamp
            let function = WKCountdownFunction.init(rawValue: state)
            let runThisTime = countdown.runThisTime
            
            debugPrint("记录key = \(key), 已经运行时长 = \(run), 本次运行时长 = \(runThisTime), 剩余时长 = \(left), 状态 = \(state)")
            
            if !justRecord {
                timer.invalidate()
            }
            // 如果还有剩余时间
            if left > 0 {
                // 如果该计时需要持久化
                if function.contains(.cache) || function.contains(.remainTiming) {
                    var temp = [String: Any]()
                    temp["key"] = key
                    temp["state"] = state
                    temp["left"] = left
                    temp["total"] = total
                    temp["run"] = run
                    temp["checkpointStamp"] = checkpointStamp
                    temp["endStamp"] = endStamp
                    dict[key] = temp
                }
            } else {
                removeCountdown(key: key)
            }
        }
        
        guard dict.keys.count > 0 else {
            UserDefaults.standard.removeObject(forKey: innerMark + countdownMark)
            UserDefaults.standard.synchronize()
            return
        }
        
        UserDefaults.standard.set(dict, forKey: innerMark + countdownMark)
        UserDefaults.standard.synchronize()
        
    }
    
    /** 读取全部完成计时*/
    private func readAllCountdown() {
        
        var temp = [String: CountdownDetailInfo]()
        allAvailableCountdown.enumerated().forEach { (offset, element) in
            let key = element.key
            let left = element.value.left
            if left <= 0 {
                removeCountdown(key: key)
            }
        }
        temp = allAvailableCountdown
        
        if let dict = UserDefaults.standard.dictionary(forKey: innerMark + countdownMark) {
            for savedCountdownDict in dict {
                guard let savedCountdownInfo = savedCountdownDict.value as? [String: Any] else {
                    continue
                }
                let key = savedCountdownDict.key
                let info = CountdownDetailInfo()
                let state = savedCountdownInfo["state"] as? Int ?? 0
                var left = savedCountdownInfo["left"] as? UInt ?? 0
                let total = savedCountdownInfo["total"] as? UInt ?? 0
                var run = savedCountdownInfo["run"] as? UInt ?? 0
                var checkpointStamp = savedCountdownInfo["checkpointStamp"] as? Double ?? 0
                let endStamp = savedCountdownInfo["endStamp"] as? Double ?? 0
                
                let function = WKCountdownFunction.init(rawValue: state)
                if function.contains(.remainTiming), function.contains(.timing) {
                    checkpointStamp = Date().timeIntervalSince1970
                    let deltaInterval = endStamp - checkpointStamp
                    if deltaInterval > 0 {
                        left = UInt(deltaInterval)
                        run = total - left
                    } else {
                        continue
                    }
                }
                debugPrint("读取key = \(key), 已经运行时长 = \(run), 剩余时长 = \(left), 状态 = \(state)")
                info.key = key
                info.state = state
                info.left = left
                info.total = total
                info.run = run
                info.checkpointStamp = checkpointStamp
                info.endStamp = endStamp
                info.timer = Timer.init(timeInterval: 1, target: self, selector: #selector(beginCountdown(timer:)), userInfo: key, repeats: true)
                temp[key] = info
            }
        }
        guard temp.keys.count > 0 else {
            return
        }
        allAvailableCountdown = temp
        
        performSelector(inBackground: #selector(startTimer), with: nil)
    }
    
}
