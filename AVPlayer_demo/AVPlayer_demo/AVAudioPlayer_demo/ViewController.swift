//
//  ViewController.swift
//  AVAudioPlayer_demo
//
//  Created by touring on 2017/11/27.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, MQPlayerManagerDelegate {
    
    var urlArray:[String] = []
    var playIndexes:Int = 0
    
    ///播放总时间
    @IBOutlet weak var totalTimeLabel: UILabel!
    ///当前播放时间
    @IBOutlet weak var currentTimeLabel: UILabel!
    ///播放进度滑块
    @IBOutlet weak var playSlider: UISlider!
    ///封面图
    @IBOutlet weak var artworkImageView: UIImageView!
    ///歌曲信息
    @IBOutlet weak var infoLabel: UILabel!
    ///暂停/播放按钮
    @IBOutlet weak var playPauseButton: UIButton!
    
    ///后台任务ID
    var backTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    deinit {
        
        if self.backTaskId != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(self.backTaskId)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //设置后台播放
        do {
            let session = AVAudioSession.sharedInstance()
            //设置后台播放
            try session.setCategory(AVAudioSessionCategoryPlayback)
            //设置活跃(true静音状态下有声音)
            try session.setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        //声明接收RemoteControl事件
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //移除RemoteControl事件
//        UIApplication.shared.endReceivingRemoteControlEvents()
        
        
        //注册接收遥控(耳机线控和锁屏控制)通知(通知在AppDelegate->remoteControlReceived(:)方法中post)
        let notificationName = Notification.Name(rawValue: "remoteControlReceived")
        NotificationCenter.default.addObserver(self, selector: #selector(remoteControlReceivedNotification(_:)), name: notificationName, object: nil)
        
        
        //添加中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object:nil)
        
        //添加线路改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        //应用进入后台通知(处理视频播放中进入后台自动暂停的问题)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        //应用即将被挂起(设置后台任务ID)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        //应用即将被终止(移除RemoteControl事件)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        
        //添加播放地址
        self.urlArray.append("http://mvvideo1.meitudata.com/58193623c84cd6720.mp4")
        self.urlArray.append("http://cdn5.lizhi.fm/audio/2015/10/22/23767157492533638_hd.mp3")
        self.urlArray.append("http://cdn5.lizhi.fm/audio/2014/07/12/12931321096220934_hd.mp3")
        
        //初始化UI数据
        self.startPlayingInitialize()
        
        //设置代理
        MQPlayerManager.sharedInstance.delegate = self
        
        //添加视频Layer层(不是必须添加)用于显示视频图像
        let playerLayer = AVPlayerLayer(player: MQPlayerManager.sharedInstance.player)
        playerLayer.frame = self.artworkImageView.bounds
        self.artworkImageView.layer.addSublayer(playerLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIAlertView(title: "注意", message: "默认添加的都为在线播放地址\n请注意自己流量！！！\n点击▶️键播放\n点击⏮切换上一首\n点击⏭切换下一首\n默认当前歌曲播放完成后自动播放下一曲", delegate: nil, cancelButtonTitle: "确定").show()
    }
    
    // MARK: - 开始/播放初始化UI数据
    func startPlayingInitialize() {
        
        self.navigationItem.title = "音乐播放器"
        self.totalTimeLabel.text = "/00:00"
        self.currentTimeLabel.text = "00:00"
        self.playSlider.value = 0
        self.infoLabel.text = nil
        self.artworkImageView.image = UIImage(named: "1")
        self.playPauseButton.isSelected = true
    }
    
    func endPlayingInitialize() {
        self.playPauseButton.isSelected = true
    }
    
    
    // MARK: - 刷新MPNowPlayingInfoCenter(锁屏封面)
    func configNowPlayingCenter(title: String?, artist: String?, playbackTime: NSNumber?, duration: NSNumber?, artworkImage: UIImage?) {
        
        var info: [String:Any] = [:]
        
        info[MPMediaItemPropertyTitle] = title ?? "音乐播放器"
        info[MPMediaItemPropertyArtist] = artist ?? "艺术家"
        //音乐的播放时间
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackTime ?? NSNumber(value: 0)
        //音乐的播放速度
        info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1)
        //音乐的总时间
        info[MPMediaItemPropertyPlaybackDuration] = duration ?? NSNumber(value: 0)
        //音乐的封面
        let artwork = MPMediaItemArtwork(image: artworkImage ?? UIImage(named: "1")!)
        info[MPMediaItemPropertyArtwork] = artwork
        
        //完成设置
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    //MARK: - 播放/暂停
    func play() {
        //没有歌曲播放时
        let playerManager = MQPlayerManager.sharedInstance
        if playerManager.player.currentItem == nil &&
            self.urlArray.count > self.playIndexes {
            
            self.startPlayingInitialize()
            playerManager.playMedia(urlString: self.urlArray[self.playIndexes])
            self.playPauseButton.isSelected = false
        } else {
            if MQPlayerManager.sharedInstance.play() {
                self.playPauseButton.isSelected = false
            }
        }
    }
    
    func pause(){
        if MQPlayerManager.sharedInstance.pause() {
            self.playPauseButton.isSelected = true
        }
    }
    
    // MARK: - 点击上一曲
    @IBAction func clickPreviousSong() {
        
        if self.urlArray.count > 0 && self.playIndexes > 0 {
            
            self.startPlayingInitialize()
            self.playIndexes -= 1
            MQPlayerManager.sharedInstance.playMedia(urlString: self.urlArray[self.playIndexes])
            self.playPauseButton.isSelected = false
        } else {
            JGProgressHUD.showTextHUD("没有上一曲")
        }
    }
    
    // MARK: - 点击播放/暂停
    @IBAction func clickPlayPause() {
        //
        if self.playPauseButton.isSelected {
            self.play()
        } else {
            self.pause()
        }
    }
    
    // MARK: - 点击下一曲
    @IBAction func clickNextSong() {
        
        if self.urlArray.count > self.playIndexes+1 {
            
            self.startPlayingInitialize()
            self.playIndexes += 1
            MQPlayerManager.sharedInstance.playMedia(urlString: self.urlArray[self.playIndexes])
            self.playPauseButton.isSelected = false
        } else {
            JGProgressHUD.showTextHUD("没有下一曲")
        }
    }
    
    // MARK: - 滑动跳转指定播放位置
    @IBAction func playSliderChanged(_ sender: UISlider) {
        
        let player = MQPlayerManager.sharedInstance.player
        if let currentItem = player?.currentItem {
            
            var duration = currentItem.duration
            duration.value = CMTimeValue(Float(duration.value) * sender.value)
            player?.seek(to: duration)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

