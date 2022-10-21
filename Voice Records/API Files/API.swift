//
//  API.swift
//  TopSecurityGuard
//
//  Created by iMac on 24/06/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation

struct APIS {
    //Postman link = ""

    // private static var old BASE_URL       = "https://appkiduniya.in/ORO/api/"
    
    // private static var LAst Change BASE_URL       = "http://client.appkiduniya.in/ORO/api/"
    
    private static var BASE_URL              = "http://client.appmania.co.in/ORO/api/"
    
    struct Common {
        
        static let login                    =  BASE_URL + "login"
        static let addEditAudio             =  BASE_URL + "addEditAudio"
        static let deleteAudio              =  BASE_URL + "deleteAudio"
        static let favoriteUnfavoriteAudio  =  BASE_URL + "favoriteUnfavoriteAudio"
        static let audioList                =  BASE_URL + "audioList"
    }
}
