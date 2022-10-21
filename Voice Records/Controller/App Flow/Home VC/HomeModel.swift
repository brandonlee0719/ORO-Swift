//
//  HomeModel.swift
//  Voice Records
//
//  Created by MAC on 22/03/22.
//

import Foundation

class HomeModel {
    
    var mediaId :Int
    var userId = ""
    var title = ""
    var audioLink = ""
    var time = ""
    var datetime = ""
    var key = ""
    var isFavorite = ""
    var date:Int64?
    var audioWaveLevel = ""
    
    init(key: String,dict:[String:Any]) {

        self.key = key
        mediaId = dict["media_id"] as? Int ?? 0
        userId = dict["user_id"] as? String ?? ""
        title = dict["title"] as? String ?? ""
        audioLink = dict["audio_link"] as? String ?? ""
        time = dict["time"] as? String ?? ""
        isFavorite = dict["is_favorite"] as? String ?? ""
        datetime = dict["datetime"] as? String ?? ""
        date = dict["date"] as? Int64 ?? 0
        audioWaveLevel = dict["audio_wave_level"] as? String ?? ""
    }
    
    class func getAudioData(data:[Any]) -> [HomeModel] {
        var temp = [HomeModel]()
        for dict in data {
            temp.append(HomeModel(key: "",dict: dict as? [String : Any] ?? [String:Any]()))
        }
        return temp
    }
}
