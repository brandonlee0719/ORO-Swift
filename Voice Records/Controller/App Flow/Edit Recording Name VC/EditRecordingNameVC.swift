//
//  EditRecordingNameVC.swift
//  Voice Records
//
//  Created by MAC on 22/03/22.
//

import UIKit
import SoundWave

protocol editRecordNameDelegate {
    func btnClick(recordName:String)
}

class EditRecordingNameVC: BaseViewController {
    
    //MARK:- IBOutlet
    
    @IBOutlet private weak var txtRecordingsName:UITextField!
    
    @IBOutlet private weak var lblRecordingTime:UILabel!
    
    @IBOutlet private weak var bgView:UIView!
    
    @IBOutlet private weak var audioVisualizationView: AudioVisualizationView!
    
    //MARK:- Properties
    
    let viewModel = EditRecordingVM()
    var delegate:editRecordNameDelegate!
    
    private var chronometer: Chronometer?
    private var currentState: AudioRecodingState = .ready {
        didSet {
            
            audioVisualizationView.audioVisualizationMode = currentState.audioVisualizationMode
//            btnClose.isHidden = currentState == .ready || currentState == .playing || currentState == .recording
        }
    }

    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if currentState == .recording {
            self.chronometer?.stop()
            self.chronometer = nil
            
            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                alertWith(message: error.localizedDescription)
            }
        }
    }
    
    //MARK:- Method
    
    func setData() {
        lblRecordingTime.text = viewModel.passtime
        txtRecordingsName.text = viewModel.name
        setWaveData()
    }
    
    func setUpUI() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardOpen),
                                               name: .editKeyBoardOpen, object: nil)
        
        viewModel.audioDidFinish = { [weak self] in
            self?.currentState = .recorded
            self?.audioVisualizationView.stop()
        }
        
        viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        
        audioVisualizationView.gradientStartColor = AppColor.Black
        audioVisualizationView.gradientEndColor = AppColor.Blue
        audioVisualizationView.meteringLevelBarWidth = 1.5
        audioVisualizationView.meteringLevelBarInterItem = 2.2
    }
    
    @objc private func keyBoardOpen(_ notification: Notification) {
        txtRecordingsName.becomeFirstResponder()
    }
    
    //MARK:- Wave Method
    
    func setWaveData() {
        viewModel.currentAudioRecord = SoundRecord(audioFilePathLocal: URL(string: viewModel.audioUrl), meteringLevels: [])
        
        self.currentState = .recording
        self.chronometer = Chronometer()
        self.chronometer?.start()
        viewModel.audioMeteringLevelUpdate?(Float(viewModel.audioWaveLevel) ?? 0)
        chronometer?.stop()
        chronometer = nil
        self.currentState = .recorded
        audioVisualizationView.audioVisualizationMode = .read
      viewModel.currentAudioRecord!.meteringLevels = audioVisualizationView.scaleSoundDataToFitScreen()
    }
    
    func setNotification() {       
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMeteringLevelUpdate),
                                               name: .audioPlayerManagerMeteringLevelDidUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMeteringLevelUpdate),
                                               name: .audioRecorderManagerMeteringLevelDidUpdateNotification, object: nil)
        
        // notifications audio finished
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishRecordOrPlayAudio),
                                               name: .audioPlayerManagerMeteringLevelDidFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishRecordOrPlayAudio),
                                               name: .audioRecorderManagerMeteringLevelDidFinishNotification, object: nil)
    }
    
    @objc private func didFinishRecordOrPlayAudio(_ notification: Notification) {
        viewModel.audioDidFinish?()
    }
    
    @objc private func didReceiveMeteringLevelUpdate(_ notification: Notification) {
        let percentage = notification.userInfo![audioPercentageUserInfoKey] as! Float
        viewModel.audioMeteringLevelUpdate?(percentage)
    }
    
    //MARK:- IBAction
    
    @IBAction func recordButtonDidTouchDown(_ sender:UIButton) {
        if self.currentState == .ready {
            self.viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.alertWith(message: error.localizedDescription)
                    return
                }
                
                self?.currentState = .recording
                
                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
        }
    }
    
    @IBAction func btnClose(_ sender:UIButton) {
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            alertWith(message: error.localizedDescription)
        }
    }
    
    @IBAction func btnSave(_ sender:UIButton) {
        delegate.btnClick(recordName: txtRecordingsName.text!)
        NotificationCenter.default.post(name: .audioRecorderSave, object: self)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func recordButtonDidTouchUpInside(_ sender: AnyObject) {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil
            
            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                alertWith(message: error.localizedDescription)
            }
        
        case .recorded, .paused:
            do {
                let duration = try viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                alertWith(message: error.localizedDescription)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                alertWith(message: error.localizedDescription)
            }
        default:
            print("no selected")
        }
    }
}
