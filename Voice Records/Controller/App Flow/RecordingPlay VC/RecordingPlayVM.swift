//
//  RecordingPlayVM.swift
//  Voice Records
//
//  Created by MAC on 23/03/22.
//

import Foundation

class RecordingPlayVM: BaseViewModel {
    
    //MARK:- Properties
    
    var audioVisualizationTimeInterval: TimeInterval = 0.04
    var currentAudioRecord: SoundRecord?
    private var isPlaying = false
    var audioDidFinish: (() -> ())?
    var audioMeteringLevelUpdate: ((Float) -> ())?
    var audioPassData:HomeModel!
    
    var mediaID = ""
    var title = ""
    var time = ""
    var audio:Data!

    //MARK:- Method
    
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
        do {
            try AudioPlayerManager.shared.pause()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editAudio(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
        parameter.addParameter(key: ParameterRequest.mediaId, value: mediaID)
        parameter.addParameter(key: ParameterRequest.title, value: title)
        parameter.addParameter(key: ParameterRequest.time, value: time)
        
        if audio != nil {
            
            parameter.addParameter(key: ParameterRequest.audio, value: audio)
            
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
        } else {
            apiClient.addEditNameAudio(parameters: parameter.parameters) { (resp, respMsg, respCode, err) in
                
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
}
