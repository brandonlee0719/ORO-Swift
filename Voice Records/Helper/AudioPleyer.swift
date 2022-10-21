//
//  AudioPlayer.Swift
//  PlugSpace
//
//  Created by MAC on 04/02/22.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class AudioPlayer: NSObject {
    
    //MARK:- Properties
    
    static let shared = AudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    private var myPlayerItem:AVPlayerItem?
    private var player: AVPlayer!
    let avPlayerController = AVPlayerViewController()
    
    //MARK:- Method
    
    func getAudioDuration(url:URL) -> TimeInterval {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            if let player = self.audioPlayer {
                player.isMeteringEnabled = true
            }
            
        } catch {
            print(error.localizedDescription,"Cannot play the file")
        }
        return audioPlayer?.currentTime ?? TimeInterval()
    }
    
    func playAudioWithUrl(alertSound:String) {
        
        let aSound = NSURL(string: alertSound)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:aSound! as URL)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print(error.localizedDescription,"Cannot play the file")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.myPlayerItem)
    }
    
    func playMp4Audio(videoURL:String) {
        
        let playUrl = NSURL(string: videoURL)

            player =  AVPlayer(url: playUrl! as URL)
            
            avPlayerController.player = player
            
            avPlayerController.player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
     @objc func playerDidFinishPlaying(_ noti: Notification) {
        if let playerItem = noti.object as? AVPlayerItem {
               playerItem.seek(to: CMTime.zero, completionHandler: nil)
            playMp4Audio()
           }
    }
    
    func playMp4Audio() {
        player.play()
    }
    
    func pauseMp4Audio() {
        
        guard player != nil else {
            return
        }
        
        player.pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playAudio() {
        audioPlayer?.play()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func downLoadAudio(audioUrl:URL,completion:@escaping (_ downloadUrl: URL) -> Void) {
        
        let documentsDirectoryURL =  getDocumentDirectory()
        
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("The file already exists at path")
                    completion(destinationUrl)
                    // if the file doesn't exist
                } else {
                    IndicatorManager.showLoader()
                    // you can use NSURLSession.sharedSession to download the data asynchronously
                    URLSession.shared.downloadTask(with: audioUrl, completionHandler: {  (location, response, error) -> Void in
                        guard let location = location, error == nil else { return }
                        do {
                            try FileManager.default.moveItem(at: location, to: destinationUrl)
                            
                            // after downloading your file you need to move it to your destination url
                           
                            print("File moved to documents folder")
                            completion(destinationUrl)
                            IndicatorManager.hideLoader()
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }).resume()
                }
    }
}
