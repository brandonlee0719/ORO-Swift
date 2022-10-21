//
//  AppPrefsManager.swift
//
//
//  Created by MAC on 28/03/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import Foundation

class AppPrefsManager {
    static let shared = AppPrefsManager()
    
    private let GET_AUTH_TOKEN          = "GET_AUTH_TOKEN"
    private let USER_DATA               = "USER_DATA"
    private let IS_USER_LOGIN           = "IS_USER_LOGIN"
    private let IS_USER_SIGNUP          = "IS_USER_SIGNUP"
    private let SAVE_USER_TYPE          = "SAVE_USER_TYPE"
    private let SAVE_USER_ID            = "SAVE_USER_ID"
    
    init() {}
    
    private func setDataToPreference(data: AnyObject, forKey key: String) {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(archivedData, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func getDataFromPreference(key: String) -> AnyObject? {
        let archivedData = UserDefaults.standard.object(forKey: key)
        
        if archivedData != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: archivedData! as! Data) as AnyObject?
        }
        return nil
    }
    
    // MARK: - Set & Get Data
    private func setData<T: Codable>(data: T, forKey key: String) {
        do {
            let jsonData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(jsonData, forKey: key)
            UserDefaults.standard.synchronize()
        } catch let error {
            print(error)
        }
    }
    
    private func getData<T: Codable>(objectType: T.Type, forKey key: String) -> T? {
        guard let result = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(objectType, from: result)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func removeDataFromPreference(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func isKeyExistInPreference(key: String) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            return false
        }
        return true
    }
    
    // MARK: - Device token
    func saveAuthToken(Token: String) {
        setDataToPreference(data: Token as AnyObject, forKey: GET_AUTH_TOKEN)
    }
    
    func getAuthToken() -> String {
        return getDataFromPreference(key: GET_AUTH_TOKEN) as? String ?? ""
    }
    
    func removeAuthToken() {
        removeDataFromPreference(key: GET_AUTH_TOKEN)
    }
    
    // MARK: - User Login
    func setIsUserLogin(isUserLogin: Bool) {
        setDataToPreference(data: isUserLogin as AnyObject, forKey: IS_USER_LOGIN)
    }
    
    func isUserLogin() -> Bool {
        let isUserLogin = getDataFromPreference(key: IS_USER_LOGIN)
        return isUserLogin == nil ? false: (isUserLogin as! Bool)
    }
    
    // MARK: - User signup
    func setIsUserSignUp(isUserLogin: Bool) {
        setDataToPreference(data: isUserLogin as AnyObject, forKey: IS_USER_SIGNUP)
    }
    
    func isUserSignUp() -> Bool {
        let isUserLogin = getDataFromPreference(key: IS_USER_SIGNUP)
        return isUserLogin == nil ? false: (isUserLogin as! Bool)
    }
    
    //MARK:- UserID
    
    func saveUserId(Id: String) {
        setDataToPreference(data: Id as AnyObject, forKey: SAVE_USER_ID)
    }
    
    func getUserID() -> String {
        return getDataFromPreference(key: SAVE_USER_ID) as? String ?? ""
    }
    
    func removeUserId() {
        removeDataFromPreference(key: SAVE_USER_ID)
    }
    // MARK: - User Data
    
    func setUserData(model: LoginModel?) {
        setData(data: model, forKey: USER_DATA)
    }

    func getUserData() -> LoginModel? {
        return getData(objectType: LoginModel.self, forKey: USER_DATA)
    }

    func removeUserData() {
        removeDataFromPreference(key: USER_DATA)
    }
}
