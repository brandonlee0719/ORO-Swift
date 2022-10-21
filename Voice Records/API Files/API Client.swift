//
//  API Client.swift
//  TopSecurityGuard
//
//  Created by iMac on 24/06/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation

class APIClient {
    
    // MARK:- App Flow
    
    func login(parameters: [String: Any], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.login, parameters: parameters,completion: completion)
    }
    
    func audioList(parameters: [String: Any], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.audioList, parameters: parameters,completion: completion)
    }
    
    func deleteAudio(parameters: [String: Any], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.deleteAudio, parameters: parameters,completion: completion)
    }
    
    func favoriteUnfavoriteAudio(parameters: [String: Any], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.favoriteUnfavoriteAudio, parameters: parameters, isShowHud: false,completion: completion)
    }
        
    func addEditAudio(parameters: [String: Any] ,files: [[Data]] ,fileNames: [[String]],fileKeys : [String], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.addEditAudio, parameters: parameters, files: files, fileNames: fileNames, fileKeys: fileKeys, completion: completion)
    }
    
    func addEditNameAudio(parameters: [String: Any], completion: @escaping APICallback) {
        return APIManager.postRequest(url: APIS.Common.addEditAudio, parameters: parameters, completion: completion)
    }
}
