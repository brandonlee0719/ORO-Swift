//  RecordingsPlayVC.swift
//  Voice Records
//
//  Created by MAC on 22/03/22.
//

import UIKit
import SoundWave
import AVKit
import FittedSheets

class RecordingsPlayVC: BaseViewController {
    
    //MARK:- Outlets
    
    @IBOutlet private weak var btnCancel:UIButton!
    @IBOutlet private weak var btnEdit:UIButton!
    @IBOutlet private weak var btnSave:UIButton!
    @IBOutlet private weak var btnPlay:UIButton!
    @IBOutlet private weak var btnLeft:UIButton!
    @IBOutlet private weak var btnRight:UIButton!
    
    @IBOutlet private weak var lblRecordingName:UILabel!
    @IBOutlet private weak var lblRecordingTime:UILabel!
    @IBOutlet private weak var lblFolderName:UILabel!
    
    @IBOutlet private weak var playView:UIView!
    @IBOutlet private weak var editView:UIView!
    @IBOutlet private weak var txtStartTime:UITextField!
    @IBOutlet private weak var txtEndTime:UITextField!
    
    @IBOutlet private weak var audioVisualizationView: AudioVisualizationView!
    
    //MARK:- Properties
    
    let viewModel = RecordingPlayVM()
    
    private var chronometer: Chronometer?
    var sheetController : SheetViewController!
    var options = SheetOptions()
    
    private var currentState: AudioRecodingState = .ready {
        didSet {
            btnPlay.setImage(currentState.buttonImage, for: .normal)
            audioVisualizationView.audioVisualizationMode = currentState.audioVisualizationMode
        }
    }
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        options.presentingViewCornerRadius = 20
        options.useFullScreenMode = true
        
        setupUI()
        
        setupWaveView()
        setNotification()
        setData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .noRecord
        } catch {
            alertWith(message: StringConstant.stopRecord)
            return
        }
        
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.audioVisualizationView.pause()
            } catch {
                alertWith(message: error.localizedDescription)
            }
        }
    }
    
    //MARK:- Api Calling
    
    func callAddAudioApi() {
       
        viewModel.title = lblRecordingName.text!
        viewModel.mediaID = String(viewModel.audioPassData.mediaId)
        
            viewModel.editAudio { [self] (isSuccess) in
               if isSuccess {
                
                showToast(message: viewModel.errorSuccessMessage, font: UIFont(name: AppFont.RoobertRegular, size: setCustomFont(18))!)
                NotificationCenter.default.post(name: .audioRecorderSave, object: self)
                backVC()
               } else {
                alertWith(message: viewModel.errorSuccessMessage)
               }
            }
    }
    
    //MARK:- Method
    
    func setupWaveView() {
        
        viewModel.audioDidFinish = { [self] in
            currentState = .recorded
            audioVisualizationView.stop()
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
    
    func setupUI() {
        editView.setShadowView(color: AppColor.Black, opacity: 0.4, offset: CGSize(width: 1, height: 1.0), radius: 3)
        editView.cornerRadius = 10
        txtStartTime.borderColor = AppColor.Black
        txtEndTime.borderColor = AppColor.Black
        
        audioVisualizationView.gradientStartColor = AppColor.Black
        audioVisualizationView.gradientEndColor = AppColor.Blue
        audioVisualizationView.meteringLevelBarWidth = 1.5
        audioVisualizationView.meteringLevelBarInterItem = 2.2
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
    
    func setData() {
    
        lblRecordingTime.text = viewModel.audioPassData.time
        lblRecordingName.text = viewModel.audioPassData.title
        
        if let audioUrl = URL(string: viewModel.audioPassData.audioLink) {
               
            AudioPlayer.shared.downLoadAudio(audioUrl: audioUrl) { [self] (Url) in
                viewModel.currentAudioRecord = SoundRecord(audioFilePathLocal: Url, meteringLevels: [])
                DispatchQueue.main.async {
                    setWaveData()
                }
            }
//            let documentsDirectoryURL =  getDocumentDirectory()
//
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//
//            if FileManager.default.fileExists(atPath: destinationUrl.path) {
//                        print("The file already exists at path")
//                viewModel.currentAudioRecord = SoundRecord(audioFilePathLocal: destinationUrl, meteringLevels: [])
//                setWaveData()
//                        // if the file doesn't exist
//                    } else {
//                        IndicatorManager.showLoader()
//                        // you can use NSURLSession.sharedSession to download the data asynchronously
//                        URLSession.shared.downloadTask(with: audioUrl, completionHandler: { [self] (location, response, error) -> Void in
//                            guard let location = location, error == nil else { return }
//                            do {
//                                try FileManager.default.moveItem(at: location, to: destinationUrl)
//
//                                // after downloading your file you need to move it to your destination url
//
//                                print("File moved to documents folder")
//                                viewModel.currentAudioRecord = SoundRecord(audioFilePathLocal: destinationUrl, meteringLevels: [])
//                                DispatchQueue.main.async {
//                                    setWaveData()
//                                }
//
//                                IndicatorManager.hideLoader()
//                            } catch let error as NSError {
//                                print(error.localizedDescription)
//                            }
//                        }).resume()
//                    }
        }
    }
    
    
    func setWaveData() {
        self.currentState = .recording
        self.chronometer = Chronometer()
        self.chronometer?.start()
        viewModel.audioMeteringLevelUpdate?(Float(viewModel.audioPassData.audioWaveLevel) ?? 0)
        chronometer?.stop()
        chronometer = nil
        self.currentState = .recorded
        audioVisualizationView.audioVisualizationMode = .read
      viewModel.currentAudioRecord!.meteringLevels = audioVisualizationView.scaleSoundDataToFitScreen()
    }
    
    @objc private func didFinishRecordOrPlayAudio(_ notification: Notification) {
        viewModel.audioDidFinish?()
    }
    
    @objc private func didReceiveMeteringLevelUpdate(_ notification: Notification) {
        let percentage = notification.userInfo![audioPercentageUserInfoKey] as! Float
        viewModel.audioMeteringLevelUpdate?(percentage)
        if currentState == .recording {
            lblRecordingTime.text = timeString(time: AudioRecorderManager.shared.recorder?.currentTime ?? TimeInterval())
           
        } else if currentState == .playing {
            lblRecordingTime.text = timeString(time: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
        }
    }
    
    //MARK:- IBAction
    
    @IBAction func btnCancel(_ Sender:UIButton) {
        backVC()
    }
    
    @IBAction func btnEdit(_ Sender:UIButton) {
        editView.isHidden.toggle()
        if editView.isHidden {
            btnSave.titleLabel?.textColor = AppColor.Black
            btnSave.isUserInteractionEnabled = false
        } else {
            btnSave.titleLabel?.textColor = AppColor.Blue
            btnSave.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func btnSave(_ Sender:UIButton) {
        
        guard txtStartTime.text != "" && txtEndTime.text != "" else {
            alertWith(message: StringConstant.enterTime)
            return
        }
        
        if Float(txtStartTime.text!)! < 1 {
            alertWith(message: StringConstant.wrongStartTime)
            return
        } else if TimeInterval(Float(txtStartTime.text!)!) > AudioPlayerManager.shared.audioPlayer?.duration ?? TimeInterval() {
            alertWith(message: StringConstant.validTime)
            return
        } else if Float(txtEndTime.text!)! < 1 {
            alertWith(message: StringConstant.wrongEndTime)
            return
        } else if TimeInterval(Float(txtEndTime.text!)!) > AudioPlayerManager.shared.audioPlayer?.duration ?? TimeInterval() {
            alertWith(message: StringConstant.validTime)
            return
        }
        
      do {
            guard let currentAudioRecord = viewModel.currentAudioRecord else {
                throw AudioErrorType.audioFileWrongPath
            }
            guard let audioFilePath = currentAudioRecord.audioFilePathLocal else {
                fatalError("tried to unwrap audio file path that is nil")
            }
        AudioRecorderManager.shared.cropAudio(sourceURL1: audioFilePath, startTime: Float(txtStartTime.text!)!, endTime: Float(txtEndTime.text!)!, completion: { [self] (url) in
            let data = FileManager.default.contents(atPath: url.path)
             viewModel.audio = data
            
            DispatchQueue.main.async {
                
                viewModel.time = timeString(time: TimeInterval(Float(txtStartTime.text!)!) + TimeInterval(Float(txtEndTime.text!)!) - 2)
                callAddAudioApi()
             }
            })
        } catch {
        }
    }
    
    @IBAction func btnBackward(_ Sender:UIButton) {
        
        AudioPlayerManager.shared.audioPlayer?.currentTime -= 15
        
        if AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval() < AudioPlayerManager.shared.audioPlayer?.duration ?? TimeInterval() {
            AudioPlayerManager.shared.audioPlayer?.currentTime = 0
        }
        
        if currentState == .playing {
            AudioPlayerManager.shared.audioPlayer?.play(atTime: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
            
        } else {
           
        }
        
        lblRecordingTime.text = timeString(time: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
            
    }
    
    @IBAction func btnForward(_ Sender:UIButton) {
        AudioPlayerManager.shared.audioPlayer?.currentTime += 15
        
        if AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval() > AudioPlayerManager.shared.audioPlayer?.duration ?? TimeInterval() {
            AudioPlayerManager.shared.audioPlayer?.currentTime = AudioPlayerManager.shared.audioPlayer?.duration ?? TimeInterval()
        }
        
        if currentState == .playing {
            AudioPlayerManager.shared.audioPlayer?.play(atTime: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
        } else {
           
        }
        
        lblRecordingTime.text = timeString(time: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
    }
    
    @IBAction private func btnPlay(_ sender: AnyObject) {
            switch self.currentState {
            
            case .ready, .noRecord :
               print("fgdfg")
                
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
    
    @IBAction func btnEditRecordingName(_ Sender:UIButton) {
        
        let PresentVc = UIStoryboard.instantiateVC(EditRecordingNameVC.self, .Main)
         sheetController = SheetViewController(controller: PresentVc,sizes: [.marginFromTop(70)],options: options)
        PresentVc.delegate = self
        PresentVc.viewModel.passtime = lblRecordingTime.text!
        PresentVc.viewModel.name = lblRecordingName.text!
        PresentVc.viewModel.audioWaveLevel = viewModel.audioPassData.audioWaveLevel
        PresentVc.setData()
        self.present(sheetController, animated: false, completion: nil)
        NotificationCenter.default.post(name: .editKeyBoardOpen, object: self)
    }
}

extension RecordingsPlayVC: editRecordNameDelegate {
    func btnClick(recordName: String) {
        
        if recordName != lblRecordingName.text {
            lblRecordingName.text = recordName
            callAddAudioApi()
            btnSave.titleLabel?.textColor = AppColor.Blue
            btnSave.isUserInteractionEnabled = true
        }
    }
}
