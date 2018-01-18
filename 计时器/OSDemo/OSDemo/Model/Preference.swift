//
//  Preference.swift
//  OSDemo
//
//  Created by zhanggui on 2018/1/17.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import Foundation

struct Preference {
    var selectedTime: TimeInterval {
        get {
            let saveTime = UserDefaults.standard.double(forKey: "selectedTime")
            if saveTime > 0 {
                return saveTime
            }
            return 360
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        }
    }
}
