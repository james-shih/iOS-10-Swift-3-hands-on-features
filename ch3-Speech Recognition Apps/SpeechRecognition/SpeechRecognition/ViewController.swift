//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by jamesshih on 2017/4/6.
//  Copyright © 2017年 i-link. All rights reserved.
//


import UIKit
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    let audioFileName = "live-audio.m4a"
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var outputTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputTextView.text = "Hello, World"
        
        recognizeSpeech()
        
        audioSetup()
    }

    func recognizeSpeech() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                
                if let path = Bundle.main.url(forResource: "live-audio", withExtension: "m4a") {
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: path)
                    recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                        if let error = error {
                            print("JAMES: can't recognize file. error: \(error)")
                        } else {
                            self.outputTextView.text = result?.bestTranscription.formattedString
                        }
                    })
                }
                
            }
        }
    }
    
    func audioSetup() {
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({ [unowned self](allowed: Bool) -> Void in
                if allowed {
                    self.startRecording()
                } else {
                    print("need permissions to user microphone")
                }
            })
        } catch {
            print("error setting up audio")
        }
    }
    
    func directoryURL() -> URL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL

        return documentDirectory.appendingPathComponent(audioFileName)
        
/*
        do {
            let url = try documentDirectory.appendingPathComponent(audioFileName)
            return url
        } catch {
            print("error getting url")
        }
        return nil
*/
        
    }
    
    func startRecording() {
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000.0, AVNumberOfChannelsKey: 1 as NSNumber, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: directoryURL()!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
        } catch {
            print("something went trying to start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(recognizeSpeech), userInfo: nil, repeats: false)
    }
    
    
}



















