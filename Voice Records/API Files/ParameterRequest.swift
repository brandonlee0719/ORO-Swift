//
//  ApiParameter.swift
//
//
//  Created by MAC on 28/03/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import Foundation

class ParameterRequest {
    init() {}
    
    var parameters = [String: Any]()

    static let deviceId = "device_id"
    static let userId = "user_id"
    static let mediaId = "media_id"
    
    static let title = "title"
    static let audio = "audio"
    static let time = "time"
    static let audioWaveLevel = "audio_wave_level"

    func addParameter(key: String, value: Any?) {
        parameters[key] = value
    }
}
