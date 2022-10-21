//
//  Global Constants.swift
//  Black Box
//
//  Created by MAC on 17/03/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit
import SoundWave

// Home business

// MARK: -
var isDevelopmentMode = false

// MARK:-
let AppName = Bundle.appName()
var versionCode = Bundle.appVersion()
var keyToken = "RnsLkxS2OPdtEDv50mvzIGy1IECZKOPE1e58p5D7Vp8oLoEYV1w0FH2l1Y4GFyYnk2aWGnupCqmSGskM"

var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

// MARK: -
enum Storyboard : String {
    case Main = "Main"
}

enum ActionType : String {
    case Edit
    case Favourite
    case Delete
    case Share
    case Unfavorite
}

enum AudioRecodingState {
    case ready
    case recording
    case recorded
    case playing
    case paused
    case noRecord
    
    var buttonImage: UIImage {
        switch self {
        case .ready, .recording:
            return #imageLiteral(resourceName: "ic_Stop")
        case .recorded, .paused:
            return #imageLiteral(resourceName: "ic_PlayAudio")
        case .playing:
            return #imageLiteral(resourceName: "ic_Playing")
        case .noRecord:
            return #imageLiteral(resourceName: "ic_StartRecord")
        }
    }

    var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
        switch self {
        case .ready, .recording:
            return .write
        case .paused, .playing, .recorded:
            return .read
        case .noRecord:
            return .read
        }
    }
}

// MARK: -
struct AppFont {
    static let RoobertRegular = "Roobert-Regular"
    static let RoobertSemiBold = "Roobert-SemiBold"
}

// MARK: -
struct AppColor {
    static let Theme = UIColor(named: "Theme")!
    static let Black = UIColor(named: "Black")!
    static let Blue = UIColor(named: "Blue")!
    static let TextBlueGrey = UIColor(named: "TextBlueGrey")!
    static let TextColor2 = UIColor(named: "TextColor2")!
    static let Yellow = UIColor(named: "Yellow")!
}

// MARK: -
struct ResponseStatus {
    static let fail = 0
    static let success = 1
    static let NotConfirmAccount = 2
    static let tokenExpire = 9
}
