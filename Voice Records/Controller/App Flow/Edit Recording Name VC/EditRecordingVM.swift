//
//  EditRecordingVM.swift
//  Voice Records
//
//  Created by MAC on 25/03/22.
//

import Foundation

class EditRecordingVM : BaseViewModel {
    
    //MARK:- Properties
    
    var audioVisualizationTimeInterval: TimeInterval = 0.04
    var currentAudioRecord: SoundRecord?
    private var isPlaying = false
    var audioDidFinish: (() -> ())?
    var audioMeteringLevelUpdate: ((Float) -> ())?
    var passtime = ""
    var name = ""
    var audioWaveLevel = ""
    var audioUrl = ""
        
    var audio:Data!
    var mediaID = ""
    var title = ""
    var time = ""
    
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
    
    //MARK:- Api calling
    
//    func editNameAudio(completion:@escaping (_ isSuccess:Bool) -> Void) {
//        
//        let parameter = ParameterRequest()
//        
//        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
//        parameter.addParameter(key: ParameterRequest.mediaId, value: mediaID)
//        parameter.addParameter(key: ParameterRequest.title, value: title)
//        
//        
//    }
}
