//
//  HomeVM.swift
//  Voice Records
//
//  Created by MAC on 22/03/22.
//

import Foundation
import UIKit

struct SoundRecord {
    var audioFilePathLocal: URL?
    var meteringLevels: [Float]?
}

class HomeVM: BaseViewModel {
    
    //MARK:- Properties
    
    var loginData : LoginModel!
    var audioData = [HomeModel]()
    
    var audioDateTimeData = [HomeModel]()
    
    var searchText = ""
    var searchAudioData = [HomeModel]()
    var checkDf = DateFormatter()
    var dateFormatter = DateFormatter()
    
    var indexPath : IndexPath!
    var PlayAudioIndexPath : IndexPath!
    
    var isPlay = false
    var audioVisualizationTimeInterval: TimeInterval = 0.04
    var currentAudioRecord: SoundRecord?
    
    private var isPlaying = false
    var audioDidFinish: (() -> ())?
    var audioMeteringLevelUpdate: ((Float) -> ())?
    
    var mediaID = ""
    var title = ""
    var time = ""
    var audio:Data!
    var audioWaveLevel = ""
    
    //MARK:- Method
    func askAudioRecordingPermission(completion: ((Bool) -> Void)? = nil) {
        return AudioRecorderManager.shared.askPermission(completion: completion)
    }
    
    //MARK:- Recording
    
    func resetRecording() throws {
        try AudioRecorderManager.shared.reset()
        self.isPlaying = false
        self.currentAudioRecord = nil
    }
    
    func stopRecording() throws {
        try AudioRecorderManager.shared.stopRecording()
    }
    
    func startRecording(completion: @escaping (SoundRecord?, Error?) -> Void) {
        AudioRecorderManager.shared.startRecording(with: self.audioVisualizationTimeInterval, completion: { [weak self] url, error in
            guard let url = url else {
                completion(nil, error!)
                return
            }

            self?.currentAudioRecord = SoundRecord(audioFilePathLocal: url, meteringLevels: [])
            print("sound record created at url \(url.absoluteString))")
            completion(self?.currentAudioRecord, nil)
        })
    }
    
    func startPlaying() throws -> TimeInterval {
        guard let currentAudioRecord = self.currentAudioRecord else {
            throw AudioErrorType.audioFileWrongPath
        }

        if self.isPlaying {
            return try AudioPlayerManager.shared.resume()
        } else {
            guard let audioFilePath = currentAudioRecord.audioFilePathLocal else {
                fatalError("tried to unwrap audio file path that is nil")
            }

            self.isPlaying = true
            return try AudioPlayerManager.shared.play(at: audioFilePath, with: self.audioVisualizationTimeInterval)
        }
    }
    
    func pausePlaying() throws {
        try AudioPlayerManager.shared.pause()
    }
    
    //MARK:- CallApi
    
    func getAudioList(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
        apiClient.audioList(parameters: parameter.parameters) { (resp, respMsg, respCode, err) in
            
            guard err == nil else {
                self.errorSuccessMessage = err!
                completion(false)
                return
            }
            
            if respCode ==  ResponseStatus.success {
                if let respDict = resp as? [String:Any],let data = respDict["date"] as? [Any] {
                    self.audioData = HomeModel.getAudioData(data: data)
                }
                self.errorSuccessMessage = respMsg!
                completion(true)
            } else {
                
                self.errorSuccessMessage = respMsg!
                completion(false)
            }
        }
    }
    
    func loginUser(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.deviceId, value: AppDelegate.shared.getUUID())
        apiClient.login(parameters: parameter.parameters) { (resp, respMsg, respCode, err) in
            
            guard err == nil else {
                self.errorSuccessMessage = err!
                completion(false)
                return
            }
            
            if respCode ==  ResponseStatus.success {
                if let respDict = resp as? [String:Any],let data = respDict["data"] as? [String:Any] {
                    self.loginData = LoginModel(dict: data)
                    
                    AppPrefsManager.shared.setIsUserSignUp(isUserLogin: false)
                    AppPrefsManager.shared.setIsUserLogin(isUserLogin: true)
                    AppPrefsManager.shared.setUserData(model: self.loginData)
                    
                    AppPrefsManager.shared.saveAuthToken(Token: self.loginData.token)
                    AppPrefsManager.shared.saveUserId(Id: self.loginData.userId)
                }
                self.errorSuccessMessage = respMsg!
                completion(true)
            } else {
                
                self.errorSuccessMessage = respMsg!
                completion(false)
            }
        }
    }
    
    func favoriteUnfavoriteAudio(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
        parameter.addParameter(key: ParameterRequest.mediaId, value: mediaID)
        apiClient.favoriteUnfavoriteAudio(parameters: parameter.parameters) { (resp, respMsg, respCode, err) in
            
            guard err == nil else {
                self.errorSuccessMessage = err!
                completion(false)
                return
            }
            
            if respCode ==  ResponseStatus.success {
                self.errorSuccessMessage = respMsg!
                completion(true)
            } else {
                
                self.errorSuccessMessage = respMsg!
                completion(false)
            }
        }
    }
    
    func addAudio(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
        parameter.addParameter(key: ParameterRequest.title, value: title)
        parameter.addParameter(key: ParameterRequest.time, value: time)
        parameter.addParameter(key: ParameterRequest.audio, value: audio)
        parameter.addParameter(key: ParameterRequest.audioWaveLevel, value: audioWaveLevel)
        
        var files : [[Data]] = [[]]
        var fileNames : [[String]] = [[]]
        var fileKeys : [String] = [""]
        
        files.append([audio])
        fileNames.append(["record.m4a"])
        fileKeys.append(ParameterRequest.audio)
        
        apiClient.addEditAudio(parameters: parameter.parameters, files: files, fileNames: fileNames, fileKeys: fileKeys) { (resp, respMsg, respCode, err) in
            
            guard err == nil else {
                self.errorSuccessMessage = err!
                completion(false)
                return
            }
            
            if respCode ==  ResponseStatus.success {
                self.errorSuccessMessage = respMsg!
                completion(true)
            } else {
                
                self.errorSuccessMessage = respMsg!
                completion(false)
            }
        }
    }
}
