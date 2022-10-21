//
//  String+Extension.swift
//  RecycleBucks
//
//  Created by MAC on 25/02/22.
//

import Foundation

func timeString(time:TimeInterval) -> String {
    
    let hours = Int(time) / 3600
    let minutes = Int(time) / 60 % 60
    let seconds = Int(time) % 60
    
    return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
}

extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return "Application"
        }
        if let version : String = dictionary["CFBundleDisplayName"] as? String {
            return version
        } else {
            return "Application"
        }
    }
    
    static func appVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return "1.0"
        }
        if let version : String = dictionary["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "1.0"
        }
    }
}
