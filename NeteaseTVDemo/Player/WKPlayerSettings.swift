//
//  WKPlayerSettings.swift
//  neteaseTVDemo
//
//  Created by ZhangDong on 2023/8/25.
//

import Foundation


public class WKPlayerSettings {
    public var `default`: [String: Any] {
        set {
            _default = newValue
        }
        get {
            if let temp = _default {
                return temp
            } else {
                if let dict = UserDefaults.standard.value(forKey: kSettings) as? [String: Any] {
                    _default = dict
                    return dict
                } else {
                    let dict = [kRate: Float(1)]
                    UserDefaults.standard.setValue(dict, forKey: kSettings)
                    UserDefaults.standard.synchronize()
                    _default = dict
                    return dict
                }
            }
            
        }
    }
    
    public var rate: Float {
        get {
            if let temp = _rate {
                return temp
            } else {
                _rate = self.default[kRate] as? Float
            }
            return _rate ?? 1
        }
        
        set {
            _rate = newValue
            wk_player.player?.rate = newValue
            self.default[kRate] = newValue
            update()
        }
    }
    
    private var _default: [String: Any]?
    private var _rate: Float?
    private let kRate = "WKPlayerRate"
    private let kSettings = "WKPlayerSettings"
    
    private func update() {
        UserDefaults.standard.setValue(self.default, forKey: kSettings)
        UserDefaults.standard.synchronize()
    }
}
 
