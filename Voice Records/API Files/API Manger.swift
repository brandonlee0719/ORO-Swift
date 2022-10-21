//
//  API Manger.swift
//  TopSecurityGuard
//
//  Created by iMac on 24/06/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

let NetworkError = "We're having trouble reaching the network. Check your connection or try again in a few minutes."

public typealias APICallback = ( _ response: Any?, _ responsemessage: String?,_ resCode: Int?, _ errorStr: String?) -> Void

protocol Mappable {
    init(_ dictionary: [String: Any])
}

extension Mappable {
    func getIdStr() -> String { return ""}
}

class APIManager {
    
    public static let apiSessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 300
        return Session(configuration: configuration)
    }()
    
    class func postRequest(url: String, parameters: [String: Any], isShowHud: Bool = true, completion: @escaping APICallback) {
        
        guard isNetworkReachable() else {
            completion(nil, nil,nil,NetworkError)
            return
        }
        
        var headers = [String:String]()
        
        if AppPrefsManager.shared.isUserLogin() || AppPrefsManager.shared.isUserSignUp() {
            headers["key"] = keyToken
            headers["token"] = AppPrefsManager.shared.getAuthToken()
           
        } else {
            headers["key"] = keyToken
        }
        headers["versioncode"] = versionCode
        headers["device_type"] = StringConstant.deviceType
        
        var newHeaders = HTTPHeaders()
        for h in headers {
            newHeaders.add(name: h.key, value: h.value)
        }
        
        if isShowHud {
            IndicatorManager.showLoader()
        }

        apiSessionManager.request(url, method: .post, parameters: parameters, headers: newHeaders).responseJSON { (response) in
            if isShowHud {
                IndicatorManager.hideLoader()
            }
            guard response.error == nil else {
                completion(nil, nil,response.response?.statusCode,response.error?.localizedDescription)
                return
            }
            
            DLog("Response Error: ", response.error)
            DLog("Response JSON: ", response.value)
            DLog("response.request: ", response.request?.allHTTPHeaderFields)
            DLog("Response Status Code: ", response.response?.statusCode)
            if let res = response.value as? [String:Any] {
                
                let msg = res["ResponseMsg"] as? String ?? ""
                let code = res["ResponseCode"] as? Int ?? -1
                if code != 0 {
                    
                    completion(res,msg,code,nil)
                    return
                }
                else {
                    completion(nil, nil,code,msg)
                }
            }
        }
    }
    
    class func postRequest(url: String, parameters: [String: Any],files: [[Data]], fileNames:[[String]], fileKeys: [String], isShowHud: Bool = true, completion: @escaping APICallback) {
        
        guard isNetworkReachable() else {
            completion(nil, nil,nil,NetworkError)
            return
        }
        var headers = [String:String]()
        
        if AppPrefsManager.shared.isUserLogin() || AppPrefsManager.shared.isUserSignUp() {
            headers["key"] = keyToken
            headers["token"] = AppPrefsManager.shared.getAuthToken()
        } else {
            headers["key"] = keyToken
        }
        headers["versioncode"] = versionCode
        headers["device_type"] = StringConstant.deviceType
        
        var newHeaders = HTTPHeaders()
        for h in headers { 
            newHeaders.add(name: h.key, value: h.value)
        }
        
        if isShowHud {
            IndicatorManager.showLoader()
        }
        apiSessionManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                if let strData = "\(value)".data(using: String.Encoding.utf8){
                    multipartFormData.append(strData, withName: key)
                    
                }
            }
            if files.count == fileKeys.count {
                for (keyInd, key) in fileKeys.enumerated() {
                    for (fileInd,file) in files[keyInd].enumerated() {
                        let name = fileNames[keyInd][fileInd]
                        let mimetype = mimeTypeFor(name)
                        multipartFormData.append(file, withName: key, fileName: name, mimeType: mimetype)
                    }
                }
            }
        }, to: url, method: .post, headers: newHeaders)
            .responseString { response in
                DLog("Response String: \(String(describing: response.value))")
        }
        .responseJSON { response in
            print("Succesfully uploaded")
            DLog("Response Error: ", response.error)
            DLog("Response JSON: ", response.value)
            DLog("response.request: ", response.request?.allHTTPHeaderFields)
            DLog("Response Status Code: ", response.response?.statusCode)
            print(response)
            if isShowHud {
                IndicatorManager.hideLoader()
            }
            guard response.error == nil else {
                completion(nil, nil,response.response?.statusCode,response.error?.localizedDescription)
                return
            }
            if let res = response.value as? [String:Any] {
                
                let msg = res["ResponseMsg"] as? String ?? ""
                let code = res["ResponseCode"] as? Int ?? -1
                if code != 0 {
                    
                    completion(res,msg,code,nil)
                    return
                }
                else {
                    completion(nil, nil,code,msg)
                }
            }
        }
    }
    
    class func getRequest(url: String, isShowHud: Bool = true, completion: @escaping APICallback) {
        guard isNetworkReachable() else {
            completion(nil, nil,nil,NetworkError)
            return
        }
        var headers = [String:String]()
        
        if AppPrefsManager.shared.isUserLogin() || AppPrefsManager.shared.isUserSignUp() {
            headers["key"] = keyToken
            headers["token"] = AppPrefsManager.shared.getAuthToken()
        } else {
            headers["key"] = keyToken
        }
        headers["versioncode"] = versionCode
        
        var newHeaders = HTTPHeaders()
        for h in headers {
            newHeaders.add(name: h.key, value: h.value)
        }
        if isShowHud {
            IndicatorManager.showLoader()
        }
        apiSessionManager.request(url, method: .get, headers: newHeaders).responseJSON { (response) in
            if isShowHud {
                IndicatorManager.hideLoader()
            }
            guard response.error == nil else {
                completion(nil, nil,response.response?.statusCode,response.error?.localizedDescription)
                return
            }
                DLog("Response Error: ", response.error)
                DLog("Response JSON: ", response.value)
                DLog("response.request: ", response.request?.allHTTPHeaderFields)
                DLog("Response Status Code: ", response.response?.statusCode)
            
            if let res = response.value as? [String:Any] {
                print(res)
                let msg = res["ResponseMsg"] as? String ?? ""
                let code = res["ResponseCode"] as? Int ?? -1
                if code != 0 {
                    
                    completion(res,msg,code,nil)
                    return
                }
                else {
                    completion(nil, nil,code,msg)
                }
            }
        }
    }
    
    class func handleAlamofireHttpFailureError(statusCode: Int) -> String? {
        switch statusCode {
        case NSURLErrorNotConnectedToInternet:
            return "The Internet connection appears to be offline."
        case NSURLErrorCannotFindHost:
            return "An unexpected network error occurred."
        case NSURLErrorCannotParseResponse:
            return "An unexpected network error occurred."
        case NSURLErrorUnknown:
            return "Ooops!! Something went wrong, please try after some time!"
        case NSURLErrorCancelled:
            break
        case NSURLErrorTimedOut:
            return "The request timed out, please verify your internet connection and try again"
        case NSURLErrorNetworkConnectionLost:
            return "No connection"
        default:
            return "An unexpected network error occurred."
        }
        return nil
    }
    
    class func isNetworkReachable() -> Bool {
        return NetworkReachabilityManager(host: "www.apple.com")?.isReachable ?? false
    }
    
    private class func mimeTypeFor(_ path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

func DLog(_ items: Any?..., function: String = #function, file: String = #file, line: Int = #line) {
    DispatchQueue.main.async {
        if isDevelopmentMode {
            print("-----------START-------------")
            let url = NSURL(fileURLWithPath: file)
            print("Message = ", items, "\n\n(File: ", url.lastPathComponent ?? "nil", ", Function: ", function, ", Line: ", line, ")")
            print("-----------END-------------\n")
        }
    }
}
