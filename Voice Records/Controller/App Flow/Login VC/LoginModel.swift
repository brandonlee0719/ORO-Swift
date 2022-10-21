//
//  LoginModel.swift
//  Voice Records
//
//  Created by MAC on 25/04/22.
//

import Foundation

class LoginModel :Codable {
    
    var userId :String!
    var deviceId :String!
    var token :String!
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        deviceId = try values.decodeIfPresent(String.self, forKey: .deviceId)
    }
    
    init(dict:[String:Any]) {
        userId = dict["user_id"] as? String ?? ""
        deviceId = dict["device_id"] as? String ?? ""
        token = dict["token"] as? String ?? ""
    }
}
