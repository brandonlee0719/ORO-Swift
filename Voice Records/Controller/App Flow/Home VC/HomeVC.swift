//
//  HomeVC.swift
//  Voice Records
//
//  Created by MAC on 21/03/22.
//

import UIKit
import FittedSheets
import Speech
import SoundWave

class HomeVC: BaseViewController, SFSpeechRecognizerDelegate, UIGestureRecognizerDelegate {

    //MARK:- Outlets

    @IBOutlet weak var lblRecordingsTotal:UILabel!
    @IBOutlet weak var lblRecordingsAlert:UILabel!
    @IBOutlet weak var lblRecordingTime:UILabel!
    
    @IBOutlet weak var alertView:UIView!
    @IBOutlet weak var searchView:UIView!
    @IBOutlet weak var tabarView:UIView!
    @IBOutlet weak var mainTabarView:UIView!
    @IBOutlet weak var bgView:UIView!
    
    @IBOutlet weak var txtRecordingName:UITextField!
    @IBOutlet weak var txtSearch:UITextField!
    
    @IBOutlet weak var btnStartRecord:UIButton!
    @IBOutlet weak var btnMicrophone:UIButton!
    @IBOutlet private weak var btnSave:UIButton!

    @IBOutlet weak var tblRecordings:UITableView!
    
    @IBOutlet weak var tblRecordingsHeight:NSLayoutConstraint!
    @IBOutlet weak var btnRecorndingWidth:NSLayoutConstraint!
    @IBOutlet weak var waveBottom:NSLayoutConstraint!
    
    @IBOutlet private var audioVisualizationView: AudioVisualizationView!
    
    //MARK:- Properties
    
    let viewModel = HomeVM()
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var currentState: AudioRecodingState = .ready {
        didSet {
            btnStartRecord.setImage(currentState.buttonImage, for: .normal)
            audioVisualizationView.audioVisualizationMode = currentState.audioVisualizationMode
        }
    }
    private var chronometer: Chronometer? 
    
    //MARK:-
    override func viewDidLoad() {

        super.viewDidLoad()
        waveBottom.constant = btnRecorndingWidth.constant + 90
        viewModel.askAudioRecordingPermission()
        setUpUI()
        setupWaveView()
        setNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callApiLogin()
        self.currentState = .noRecord
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self

        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { [self] authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("")
                case .denied:
                    alertWith(message: StringConstant.allowSpeechRecorization)
                case .restricted:
                    print("")
                case .notDetermined:
                    print("")
                default:
                    print("")
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tblRecordingsHeight.constant = tblRecordings.contentSize.height
    }
    
    //MARK:- Method
    
    func setUpUI() {
        
    txtSearch.delegate = self
    bgView.setShadowView(color: AppColor.Black, opacity: 0.5, offset: CGSize(width: 1, height: 1.0), radius: 5)
    bgView.cornerRadius = 20
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveAudio),
                                               name: .audioRecorderSave, object: nil)
        searchView.cornerRadius = 8
        
        setAfter { [self] in
            searchView.setShadowView(color: AppColor.Black, opacity: 0.2, offset: CGSize(width: 1, height: 0.0), radius: 2)
            tabarView.setShadowView(color: AppColor.Blue, opacity: 0.3, offset: CGSize(width: 1, height: 1), radius: 4)
        }
        
        tblRecordings.registerNib(RecordingsTVCell.self)
        tblRecordings.registerNib(RecordingsDateTVCell.self)
        tblRecordings.delegate = self
        tblRecordings.dataSource = self
    }
    
    private func setNoData(isSearch:Bool) {
        removeNewNoDataViewFrom(containerView: tblRecordings)
        if isSearch {
            if viewModel.searchAudioData.count == 0 {
                setNoDataFoundView(containerView: tblRecordings, text: "No Audio Found!")
            } else {
                
            }
            lblRecordingsTotal.text = "Recordings (\(viewModel.searchAudioData.count))"
        } else {
            
            if viewModel.audioData.count == 0 {
                setNoDataFoundView(containerView: tblRecordings, text: "No Audio Found!")
            } else {
                
            }
            lblRecordingsTotal.text = "Recordings (\(viewModel.audioData.count))"
        }
    }
    
    func dayDifference(from interval : TimeInterval) -> String {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInToday(date) {
            return "Today"
        } else {
            viewModel.dateFormatter.dateFormat = "MMM dd, yyyy"
            let msgTime = Date(timeIntervalSince1970: interval)
            return viewModel.dateFormatter.string(from: msgTime)
        }
    }
    
    func setData() {
        viewModel.audioDateTimeData.removeAll()
        viewModel.checkDf.dateFormat = "yyyy-MM-dd"
        
        for (_,dict) in viewModel.audioData.enumerated() {
            
            if viewModel.audioDateTimeData.count == 0 {
                viewModel.audioDateTimeData.append(HomeModel(key: "datetime", dict: ["datetime": dict.datetime]))
                
            } else {
                
                let prevData = viewModel.audioDateTimeData[viewModel.audioDateTimeData.count - 1]
                let miliSecond = Int(prevData.datetime) ?? 0
                let prev_msgTime = Date(timeIntervalSince1970: TimeInterval(miliSecond))
                let prevDate = viewModel.checkDf.string(from: prev_msgTime)
                
                let miliSecond1 = Int(dict.datetime) ?? 0
                let cr_msgTime = Date(timeIntervalSince1970: TimeInterval(miliSecond1))
                let crDate = viewModel.checkDf.string(from: cr_msgTime)
                
                if prevDate != crDate {
                    viewModel.audioDateTimeData.append(HomeModel(key: "datetime", dict:["datetime": dict.datetime]))
                }
            }
            viewModel.audioDateTimeData.append(dict)
        }
        
        tblRecordings.reloadData()
        tblRecordings.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func selectVC() {
        PresentController.shared.presentVC(controller: EditRecordingNameVC.self, vc: self, marginTop: 160)
        self.showToast(message: StringConstant.startRecord, font: UIFont(name: AppFont.RoobertRegular, size: setCustomFont(18))!)
    }
    
    //MARK:- Api Calling
    
    func callApiLogin() {
        if AppPrefsManager.shared.isUserLogin() {
            callAudioApi()
        } else {
            viewModel.loginUser { [self] (isSuccess) in
               if isSuccess {
                callAudioApi()
               } else {
                alertWith(message: viewModel.errorSuccessMessage)
               }
            }
        }
    }
    
    func callAudioApi() {
        viewModel.getAudioList { [self] (isSuccess) in
            setNoData(isSearch: false)
            if isSuccess {
                setData()
            } else {
                alertWith(message: viewModel.errorSuccessMessage)
            }
        }
    }
    
    func callFavoriteApi(mediaID:Int) {
        
        viewModel.mediaID = String(mediaID)
        viewModel.favoriteUnfavoriteAudio { [self] (isSuccess) in
            if isSuccess {
                showToast(message: viewModel.errorSuccessMessage, font: UIFont(name: AppFont.RoobertRegular, size: setCustomFont(18)) ?? UIFont())
            } else {
                alertWith(message: viewModel.errorSuccessMessage)
            }
        }
    }
    
    func callAddAudioApi() {
       
        viewModel.title = txtRecordingName.text!
        
            viewModel.addAudio { [self] (isSuccess) in
               if isSuccess {
               
                callAudioApi()
                showToast(message: viewModel.errorSuccessMessage, font: UIFont(name: AppFont.RoobertRegular, size: setCustomFont(18))!)
               } else {
                alertWith(message: viewModel.errorSuccessMessage)
               }
            }
    }
    
    //MARK:- AudioWave Method
    
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

    @objc private func saveAudio(_ notification: Notification) {

        alertView.backgroundColor = viewModel.isPlay ? AppColor.Yellow : AppColor.Blue
        lblRecordingsAlert.text = viewModel.isPlay ? StringConstant.noEdit : lblRecordingsAlert.text
        alertView.alpha = 1.0
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            self.alertView.alpha = 0.0
        }, completion: { (isCompleted) in
            self.alertView.alpha = 0.0
        })
    }
    
    private func startSpeak() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [self] result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.txtSearch.text = result.bestTranscription.formattedString
                viewModel.searchAudioData.removeAll()
                
//                let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                viewModel.searchText = txtSearch.text!
            
                applySearch()
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {

                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.alertWith(message: error?.localizedDescription)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            } else {
                
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        // Let the user know to start talking.
        txtSearch.placeholder = StringConstant.startTalking
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
    
    private func applySearch() {
        if !viewModel.searchText.isEmptyOrWhiteSpace {
            viewModel.searchAudioData = viewModel.audioDateTimeData.filter { $0.title.range(of: viewModel.searchText, options: .caseInsensitive) != nil }
            setNoData(isSearch:true)
            tblRecordings.reloadData()
        } else {
            setNoData(isSearch:false)
            tblRecordings.reloadData()
            
        }
    }

    private func resetRecord() {
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .noRecord
            closeXIB(XIB: bgView)
        } catch {
            alertWith(message: StringConstant.stopRecord)
            return
        }
    }
    
    @objc private func didFinishRecordOrPlayAudio(_ notification: Notification) {
        viewModel.audioDidFinish?()
    }
    
    @objc private func didReceiveMeteringLevelUpdate(_ notification: Notification) {
        let percentage = notification.userInfo![audioPercentageUserInfoKey] as! Float
        viewModel.audioMeteringLevelUpdate?(percentage)
        if currentState == .recording {
            lblRecordingTime.text = timeString(time: AudioRecorderManager.shared.recorder?.currentTime ?? TimeInterval())
            viewModel.time = lblRecordingTime.text!
            viewModel.audioWaveLevel = String(percentage)
        } else if currentState == .playing {
            lblRecordingTime.text = timeString(time: AudioPlayerManager.shared.audioPlayer?.currentTime ?? TimeInterval())
        }
    }
    
    //MARK:- IBAction
    
    @IBAction func btnClose(_ sender:UIButton) {
        resetRecord()
    }
    
    @IBAction func btnSaveAction(_ sender:UIButton) {
        
        guard let audioFilePath = viewModel.currentAudioRecord?.audioFilePathLocal else {
            alertWith(message: "\(AudioErrorType.audioFileWrongPath)")
//            fatalError("tried to unwrap audio file path that is nil")
            return
        }
        
       let data = FileManager.default.contents(atPath: audioFilePath.absoluteString)
        viewModel.audio = data
        callAddAudioApi()
        resetRecord()
    }
    
    @IBAction func btnMicrophone(_ sender:UIButton) {
        btnMicrophone.isSelected.toggle()
        if btnMicrophone.isSelected {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
            } else {
                do {
                    try startSpeak()
                } catch {
                    
                }
            }
            
        } else {
            viewModel.searchText = txtSearch.text!
        
            applySearch()
            txtSearch.text = ""
            txtSearch.placeholder = "Search"
        }
    }
    
    @IBAction private func recordButtonDidTouchUpInside(_ sender: AnyObject) {
     
        switch self.currentState {
            
        case .ready, .noRecord :
            openXIB(XIB: bgView)
           viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.alertWith(message: error.localizedDescription)
                    return
                }

                self?.currentState = .recording
            self?.btnSave.titleLabel?.textColor = AppColor.Black
            self?.btnSave.isUserInteractionEnabled = false
                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
            
        case .recording:
            chronometer?.stop()
            chronometer = nil
            
            viewModel.currentAudioRecord!.meteringLevels = audioVisualizationView.scaleSoundDataToFitScreen()
            audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try viewModel.stopRecording()
                self.currentState = .recorded
                btnSave.titleLabel?.textColor = AppColor.Blue
                btnSave.isUserInteractionEnabled = true
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
        }
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool){
        available ? print("Start Recording") : print("Recognition Not Available")
    }
}

//MARK:- Tableview

extension HomeVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.audioDateTimeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if viewModel.audioDateTimeData[indexPath.row].key == "datetime" {
            let cell = tableView.dequeCell(RecordingsDateTVCell.self, indexPath: indexPath)
            cell.setData(date:viewModel.audioDateTimeData[indexPath.row].datetime)
            return cell
        } else {
        
            let cell = tableView.dequeCell(RecordingsTVCell.self, indexPath: indexPath)
            cell.delegate = self
            cell.btnPlay.addTarget(self, action: #selector(clickBtnPlay(_:)), for: .touchUpInside)
            cell.btnMenu.addTarget(self, action: #selector(clickBtnMenu(_:)), for: .touchUpInside)
            cell.setData(data: viewModel.audioDateTimeData[indexPath.row])
            if let ipath = viewModel.PlayAudioIndexPath {
                ipath == indexPath ? cell.setPlayAudio(isPlay: viewModel.isPlay) : cell.setPlayAudio(isPlay: false)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.indexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.audioDateTimeData[indexPath.row].key == "datetime" ? UITableView.automaticDimension : 150
    }
    
    @objc func clickBtnPlay(_ sender:UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblRecordings)
        
        viewModel.isPlay = viewModel.PlayAudioIndexPath == tblRecordings.indexPathForRow(at:buttonPosition) && viewModel.isPlay ? false : true
       
        viewModel.PlayAudioIndexPath = tblRecordings.indexPathForRow(at:buttonPosition)
        viewModel.isPlay ? AudioPlayer.shared.playMp4Audio(videoURL: viewModel.audioDateTimeData[viewModel.PlayAudioIndexPath.row].audioLink) : AudioPlayer.shared.pauseMp4Audio()
        tblRecordings.reloadData()
    }

    @objc func clickBtnMenu(_ sender:UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tblRecordings)
        viewModel.indexPath = tblRecordings.indexPathForRow(at:buttonPosition)
    }
}

//MARK:- Delegate

extension HomeVC : RecordingsTVCellDelegate {
    
    func btnClick(action: ActionType, cell: RecordingsTVCell) {
                     
        switch action {
        
        case .Edit:
            if viewModel.isPlay {
                NotificationCenter.default.post(name: .audioRecorderSave, object: self)
            } else {
                let nextVC = UIStoryboard.instantiateVC(RecordingsPlayVC.self)
                nextVC.viewModel.audioPassData = viewModel.audioDateTimeData[viewModel.indexPath.row]
                show(nextVC, sender: self)
            }
            break
            
        case .Favourite, .Unfavorite:
            if let cell = self.tblRecordings.cellForRow(at: viewModel.indexPath) as? RecordingsTVCell {
                
                cell.setFavorite(data: viewModel.audioDateTimeData[viewModel.indexPath.row])
            }
            callFavoriteApi(mediaID:viewModel.audioDateTimeData[viewModel.indexPath.row].mediaId)
            break
            
        case .Delete:
            
            let vc = UIStoryboard.instantiateVC(DeleteVC.self)
            vc.viewModel.deleteData = viewModel.audioDateTimeData[viewModel.indexPath.row]
            show(vc, sender: self)
            break
            
        case .Share:
            let share = UIActivityViewController(activityItems: ["\(AppName) are recording"], applicationActivities: nil)
            present(share, animated: true, completion: nil)
            break
        }
    }
}

//MARK: -   UITextFieldDelegate

extension HomeVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            return false
        }
        
        viewModel.searchAudioData.removeAll()
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        viewModel.searchText = text
        applySearch()
        
        return true
    }
}
