//
//  MQPlayerManager.swift
//  AVAudioPlayer_demo
//
//  Created by Mac on 2017/11/30.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import AVFoundation

///播放器控制器
class MQPlayerManager: NSObject {
    
    weak var delegate: MQPlayerManagerDelegate?
    
    ///是否在播放状态
    var isPlayStatus:Bool {
        get {
            return (self.player.rate > 0.0)
        }
    }
    
    private var imageGenerator: AVAssetImageGenerator? = nil
    private var privatePlayer: AVPlayer? = nil
    ///播放器
    var player: AVPlayer! {
        get {
            if self.privatePlayer == nil {
                
                self.privatePlayer = AVPlayer()
                
                //添加周期时间观测器
                let interval = CMTime(value: 1, timescale: 1)
                self.privatePlayer?.addPeriodicTimeObserver(forInterval: interval,
                                                    queue: nil)
                { (time) in
                    
                    //调用代理
                    if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerPeriodicTime(_:_:))) == true {
                        self.delegate?.MQPlayerPeriodicTime!(self.player, time)
                    }
                }
                
                //AVPlayerItem播放到结束通知
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
                //AVPlayerItem媒体没有及时到达制定播放位置
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlaybackStalled(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
                
                //AVPlayerItem添加了一个新的错误日志条目
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemNewErrorLogEntry(_:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
                
                /*
                 // notifications                                                                                description
                 AVF_EXPORT NSString *const AVPlayerItemTimeJumpedNotification             NS_AVAILABLE(10_7, 5_0);    // the item's current time has changed discontinuously 该项目的当前时间改变了不连续
                 AVF_EXPORT NSString *const AVPlayerItemDidPlayToEndTimeNotification      NS_AVAILABLE(10_7, 4_0);   // item has played to its end time 项目已发挥到其结束时间
                 AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeNotification NS_AVAILABLE(10_7, 4_3);   // item has failed to play to its end time 项目未能发挥其结束时间。
                 AVF_EXPORT NSString *const AVPlayerItemPlaybackStalledNotification       NS_AVAILABLE(10_9, 6_0);    // media did not arrive in time to continue playback 媒体没有及时到达继续播放。
                 AVF_EXPORT NSString *const AVPlayerItemNewAccessLogEntryNotification     NS_AVAILABLE(10_9, 6_0);    // a new access log entry has been added 添加了一个新的访问日志条目。
                 AVF_EXPORT NSString *const AVPlayerItemNewErrorLogEntryNotification         NS_AVAILABLE(10_9, 6_0);    // a new error log entry has been added 添加了一个新的错误日志条目。
                 
                 // notification userInfo key                                                                    type
                 AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeErrorKey     NS_AVAILABLE(10_7, 4_3);   // NSError
                 */
            }
            
            return self.privatePlayer
        }
    }
    
    // MARK: - 释放
    deinit {
    
        if let currentItem = self.player.currentItem {
            self.removeObserver(AVPlayerItem: currentItem)
        }
        self.player.removeTimeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 初始化
    ///单例
    static let sharedInstance = MQPlayerManager()
    private override init() {
        
    }
    
    // MARK: - 暂停/播放
    func pause() -> Bool {
        if self.player.currentItem != nil {
            self.player.pause()
            return true
        }
        return false
    }
    
    func play() -> Bool {
        if self.player.currentItem != nil {
            self.player.play()
            return true
        }
        return false
    }
    
    func playMedia(urlString: String!) {
        if let url = URL(string: urlString) {
            self.playMedia(playerItem: AVPlayerItem(url: url))
        }
    }
    
    func playMedia(url: URL!) {
        self.playMedia(playerItem: AVPlayerItem(url: url))
    }
    
    func playMedia(asset: AVAsset!) {
        self.playMedia(playerItem: AVPlayerItem(asset: asset))
    }
    
    func playMedia(playerItem: AVPlayerItem!) {
        
        if let currentItem = self.player.currentItem {
            self.removeObserver(AVPlayerItem: currentItem)
        }
        self.addObserver(AVPlayerItem: playerItem)
        self.player.replaceCurrentItem(with: playerItem)
    }
    
    // MARK: - 获取缩略图
    ///获取缩略图.获取多张时handler多次调用,handler第一个CMTime为请求的时间和传入的times中对应
    func getCurrenImageGenerator(times: [NSValue]?, handler: @escaping AVFoundation.AVAssetImageGeneratorCompletionHandler) {
        
        if times != nil && times!.count > 0 {
            
            if let currentItem = self.player.currentItem {
                
                self.imageGenerator = AVAssetImageGenerator(asset: currentItem.asset)
                //设置缩略图大小  高设置0表示根据宽等比例显示缩略图
                self.imageGenerator?.maximumSize = CGSize(width: 320, height: 0)
                self.imageGenerator?.generateCGImagesAsynchronously(forTimes: times!, completionHandler: handler)
            }
        }
    }
    
    // MARK: - AVPlayerItem Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            
            //状态监听
            let status: AVPlayerItemStatus
            
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemSwitchOverTheStatus(_:status:))) == true {
                self.delegate?.MQPlayerItemSwitchOverTheStatus!(self.player, status: status)
            }
            
            // Switch over the status
            switch status {
                
            case .readyToPlay:
                // Player item is ready to play.
                
                self.player.play()
                break
                
            case .failed:
                // Player item failed. See error.
                print("error:\(String(describing: self.player.error))")
                break
                
            case .unknown:
                // Player item is not yet ready.
                break
            }
        } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            
            //缓冲时间监听
            if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemLoadedTimeRanges(_:))) == true {
                self.delegate?.MQPlayerItemLoadedTimeRanges!(self.player)
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            
            //缓冲不足暂停
            if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemPlaybackBufferEmpty(_:))) == true {
                self.delegate?.MQPlayerItemPlaybackBufferEmpty!(self.player)
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            
            //缓冲可以跟上播放
            if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemPlaybackLikelyToKeepUp(_:))) == true {
                self.delegate?.MQPlayerItemPlaybackLikelyToKeepUp!(self.player)
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferFull) {
            
            //缓冲完成
            if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemPlaybackBufferEmpty(_:))) == true {
                self.delegate?.MQPlayerItemPlaybackBufferEmpty!(self.player)
            }
        }
    }
    private func addObserver(AVPlayerItem playerItem: AVPlayerItem) {
        //状态监听
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.new],
                               context: nil)
        //缓冲时间监听
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                               options: [.new],
                               context: nil)
        
        //缓冲不足暂停
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
                               options: [.new],
                               context: nil)
        
        //缓冲可以跟上播放
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
                               options: [.new],
                               context: nil)
        
        //缓冲完成
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull),
                               options: [.new],
                               context: nil)
    }
    
    private func removeObserver(AVPlayerItem playerItem: AVPlayerItem) {
        
        playerItem.removeObserver(self,
                                  forKeyPath: #keyPath(AVPlayerItem.status))
        playerItem.removeObserver(self,
                                  forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem.removeObserver(self,
                                  forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        playerItem.removeObserver(self,
                                  forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
        playerItem.removeObserver(self,
                                  forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull))
    }
    
    // MARK: - AVPlayerItem 通知
    ///当前item播放完成
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        
        if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemDidPlayToEndTime(_:))) == true {
            self.delegate?.MQPlayerItemDidPlayToEndTime!(self.player)
        }
    }
    
    ///当前item没有及时到达制定播放位置
    @objc private func playerItemPlaybackStalled(_ notification: Notification) {
        
        if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemPlaybackStalled(_:))) == true {
            self.delegate?.MQPlayerItemPlaybackStalled!(self.player)
        }
    }
    
    ///AVPlayerItem添加了一个新的错误日志条目
    @objc private func playerItemNewErrorLogEntry(_ notification: Notification) {
        
        if self.delegate?.responds(to: #selector(MQPlayerManagerDelegate.MQPlayerItemNewErrorLogEntry(_:))) == true {
            self.delegate?.MQPlayerItemNewErrorLogEntry!(self.player)
        }
    }
}
