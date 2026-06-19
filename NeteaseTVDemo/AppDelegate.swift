
import UIKit
import NeteaseRequest
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //MARK: 设置屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        //播放器设置
        initConfig()
        UserDefaults.standard.set(1, forKey: "searchIndex")
        NR_BASEURL = Settings.service
        
        // TODO: LOADING UI 后台启动需要几秒钟 在这里等一下 也可以用循环检测
        sleep(3)
        
        guard let loginCookie = UserDefaults.standard.string(forKey: "cookie") else {
            window = UIWindow()
            Task {
                do {
                    let anonimousLogin: NRAnonimousModel = try await anonimousLogin()
                    UserDefaults.standard.setValue(anonimousLogin.cookie, forKey: "cookie")
                    cookie = anonimousLogin.cookie
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "login"), object: nil, userInfo: nil)
                } catch {
                    print(error)
                }
            }
            window?.rootViewController = WKTabBarViewController.creat()
            
            window?.makeKeyAndVisible()
            return true
        }
        cookie = loginCookie
        window = UIWindow()
        
        window?.rootViewController = WKTabBarViewController.creat()
        
        window?.makeKeyAndVisible()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        WKRemoteCommandManager.init(player: wk_player)
            .playTrackCommand()
            .pauseTrackCommand()
            .nextTrackCommand()
            .previousTrackCommand()
        
        return true
    }
    
    
    func reloadApplication() {
        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve) {
            UIView.setAnimationsEnabled(false)
            self.window?.rootViewController = WKTabBarViewController.creat()
            UIView.setAnimationsEnabled(UIView.areAnimationsEnabled)
        }
    }
    
    /** 初始化配置*/
    func initConfig() {
        
        
        /** 激活播放器*/
        wk_player.active()
        /** 计时器初始化配置*/
        wk_countdown.initConfig()
        
    }
    
    func showTabBar() {
        window?.rootViewController = WKTabBarViewController.creat()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        wk_player.active()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let activeAudioId = url.host()
        if let currentAudioId = wk_player.currentModel?.wk_audioId {
            if String(currentAudioId) == activeAudioId && wk_player.isPlaying {
                if let tabBarViewController = window?.rootViewController as? WKTabBarViewController {
                    tabBarViewController.selectedIndex = 4
                }
                return true
            }
        }
        if let playList : [CustomAudioModel] = UserDefaults.standard.shareListValue(forKey: "playList"){
            wk_player.allOriginalModels = playList
            for (index, audio) in playList.enumerated() {
                if let audioId = audio.wk_audioId {
                    if String(audioId) == activeAudioId {
                        if (try? wk_player.play(index: index)) != nil {
                            //刷新缓存播放列表顺序
                            if ( playList.count - 1 > index){
                                let newplayList = Array(playList[index+1...playList.count-1] + playList[0...index])
                                UserDefaults.standard.setShareValue(codable: newplayList, forKey: "playList")
                            }
                            //TODO 回触发播放UI不更新的bug，暂时注释
//                            if let tabBarViewController = window?.rootViewController as? WKTabBarViewController {
//                                tabBarViewController.selectedIndex = 4
//                            }
                        }
                        
                        return true
                    }
                }
            }
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

