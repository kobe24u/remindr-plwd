//
//  PhotoCollectionViewCell.swift
//  Carousel
//
//  Created by Vincent Liu on 26/3/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit
import AVFoundation

protocol CollectionViewScrolling
{
    func disableScrollingFunc()
    func enableScrollingFunc()
}

class PhotoCollectionViewCell: UICollectionViewCell, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var affinityLabel: UIImageView!
    
    var recordButton: UIButton!
    var playButton: UIButton!
    var stopButton: UIButton!
    var rerecordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var delegate: CollectionViewScrolling?
    var audioURL: String?{
        didSet {
            print(audioURL!)
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("executed")
        playButton = UIButton(frame: CGRect(x: 40, y: 270, width: 150, height: 64))
        playButton.isHidden = false
        let playImage = resizeImage(image: UIImage(named: "play")!, newWidth: CGFloat(30))
        playButton.setImage(playImage, for: .normal)
        playButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        stopButton = UIButton(frame: CGRect(x: 40, y: 270, width: 150, height: 64))
        stopButton.isHidden = true
        
        //        rerecordButton = UIButton(frame: CGRect(x: 40, y: 270, width: 150, height: 64))
        //        rerecordButton.isHidden = true
        //        recordingSession = AVAudioSession.sharedInstance()
        //
        //        do {
        //            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        //            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        //            try recordingSession.setActive(true)
        //            recordingSession.requestRecordPermission() { [unowned self] allowed in
        //                DispatchQueue.main.async {
        //                    if allowed {
        //                        self.loadRecordingUI()
        //                    } else {
        //                        // failed to record!
        //                        print("failed to record")
        //                    }
        //                }
        //            }
        //        } catch {
        //            // failed to record!
        //            print("failed to record")
        //        }
    }
    
    var photo: Photo? {
        didSet {
            
            self.updateUI()
            
        }
    }
    var loadingView: UIView = UIView()
    
    private func updateUI()
    {
        if let photo = photo {
            featuredImageView.image = photo.featuredImage
            photoTitleLabel.text = photo.title
            backgroundColorView.backgroundColor = photo.color
            audioURL = photo.audioURL
            //            if photo.affinity == "good"
            //            {
            //                affinityLabel.image = #imageLiteral(resourceName: "smile")
            //            }
            //            else{
            //                affinityLabel.image = #imageLiteral(resourceName: "terrified")
            //            }
            backgroundColorView.addSubview(playButton)
            
            
            loadingView.frame = CGRect(x: 115, y: 260, width: 80, height: 80)
            
        } else {
            featuredImageView.image = nil
            photoTitleLabel.text = nil
            backgroundColorView.backgroundColor = nil
        }
    }
    
    //    func loadRecordingUI() {
    //        recordButton = UIButton(frame: CGRect(x: 40, y: 270, width: 150, height: 64))
    //        let startImage = resizeImage(image: UIImage(named: "record")!, newWidth: CGFloat(30))
    //        recordButton.setImage(startImage, for: .normal)
    //        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    //        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    //        backgroundColorView.addSubview(recordButton)
    //    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //    func startRecording() {
    //
    //        let uuid = UUID().uuidString
    //
    //        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(uuid).m4a")
    //
    //        let settings = [
    //            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    //            AVSampleRateKey: 12000,
    //            AVNumberOfChannelsKey: 1,
    //            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    //        ]
    //
    //        do {
    //            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
    //            audioRecorder.delegate = self
    //            audioRecorder.record()
    //            let stopImage = resizeImage(image: UIImage(named: "stop")!, newWidth: CGFloat(30))
    //            recordButton.setImage(stopImage, for: .normal)
    //            self.audioURL = String(describing: audioRecorder.url)
    //        } catch {
    //            finishRecording(success: false)
    //        }
    //    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //    func finishRecording(success: Bool) {
    //        audioRecorder.stop()
    //
    //        let startImage = resizeImage(image: UIImage(named: "record")!, newWidth: CGFloat(30))
    //        let playImage = resizeImage(image: UIImage(named: "play")!, newWidth: CGFloat(30))
    //
    //        if success {
    //            recordButton.isHidden = true
    //            playButton.isHidden = false
    //            playButton.setImage(playImage, for: .normal)
    //            playButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    //            backgroundColorView.addSubview(playButton)
    //
    //        } else {
    //            recordButton.setImage(startImage, for: .normal)
    //            // recording failed :(
    //        }
    //    }
    
    //    func recordTapped() {
    //        if self.audioURL == nil {
    //            print("audioURL nil")
    //            startRecording()
    //        }
    //        else {
    //            print("audioURL not nil")
    //            finishRecording(success: true)
    //        }
    //    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully
        flag: Bool) {
        print("Finished")
        self.loadingView.removeFromSuperview()
        self.delegate?.enableScrollingFunc()
        let playImage = resizeImage(image: UIImage(named: "play")!, newWidth: CGFloat(30))
        playButton.setImage(playImage, for: .normal)
        //        recordButton.isEnabled = true
        stopButton.isHidden = true
        playButton.isHidden = false
        //        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
    }
    
    
    //    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    //        if !flag {
    //            finishRecording(success: false)
    //        }
    //    }
    
    
    func buttonPressed() {
        print("hello")
        print(audioURL)
        
        loadingView.frame = CGRect(x: 118, y: 250, width: 150, height: 64)
        
        loadingView.addSubview(activityIndicator)
        
        self.backgroundColorView.addSubview(loadingView)
        
        
        activityIndicator.startAnimating()
        
        
        self.delegate?.disableScrollingFunc()
        //        if audioRecorder!.isRecording == false {
        let stopImage = resizeImage(image: UIImage(named: "stop")!, newWidth: CGFloat(30))
        stopButton = UIButton(frame: CGRect(x: 40, y: 270, width: 150, height: 64))
        stopButton.setImage(stopImage, for: .normal)
        playButton.isEnabled = true
        //            playButton.isHidden = true
        stopButton.isHidden = false
        //            recordButton.isEnabled = false
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        backgroundColorView.addSubview(stopButton)
        
        let urlstring = audioURL
        let url = URL(string: urlstring!)
        
        
        weak var weakSelf = self
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url! as URL, completionHandler: { (URL, response, error) -> Void in
            
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: URL!)
                self.audioPlayer!.delegate = self
                self.audioPlayer!.prepareToPlay()
                self.audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
            
            
        })
        
        downloadTask.resume()
        
        
        //        }
    }
    
    //    func showActivityIndicatory(uiView: UIView) {
    //        var container: UIView = UIView()
    //        container.frame = uiView.frame
    //        container.center = uiView.center
    //        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
    //
    //        var loadingView: UIView = UIView()
    //        loadingView.frame = CGRectMake(0, 0, 80, 80)
    //        loadingView.center = uiView.center
    //        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
    //        loadingView.clipsToBounds = true
    //        loadingView.layer.cornerRadius = 10
    //
    //        var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    //        actInd.frame = CGRect(0.0, 0.0, 40.0, 40.0);
    //        actInd.activityIndicatorViewStyle =
    //            UIActivityIndicatorViewStyle.whiteLarge
    //        actInd.center = CGPoint(loadingView.frame.size.width / 2,
    //                                    loadingView.frame.size.height / 2);
    //        loadingView.addSubview(actInd)
    //        container.addSubview(loadingView)
    //        uiView.addSubview(container)
    //        actInd.startAnimating()
    //    }
    //
    //    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    //        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    //        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    //        let blue = CGFloat(rgbValue & 0xFF)/256.0
    //
    //        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    //    }
    
    
    
    func stopTapped(){
        print("Stopped")
        self.loadingView.removeFromSuperview()
        self.delegate?.enableScrollingFunc()
        if (audioPlayer != nil)
        {
            audioPlayer!.stop()
            stopButton.isEnabled = false
            stopButton.isHidden = true
            playButton.isEnabled = true
            playButton.isHidden = false
        }
        //        recordButton.isEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
    
}
