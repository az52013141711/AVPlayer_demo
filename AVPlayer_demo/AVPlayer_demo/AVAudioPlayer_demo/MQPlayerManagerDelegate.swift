//
//  MQPlayerManagerDelegate.swift
//  AVAudioPlayer_demo
//
//  Created by touring on 2017/11/30.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import AVFoundation

@objc protocol MQPlayerManagerDelegate: NSObjectProtocol {
    
    ///播放时间监听
    @objc optional func MQPlayerPeriodicTime(_ player: AVPlayer, _ time: CMTime)
    ///AVPlayerItem状态改变
    @objc optional func MQPlayerItemSwitchOverTheStatus(_ player: AVPlayer, status: AVPlayerItemStatus)
    ///AVPlayerItem进度
    @objc optional func MQPlayerItemLoadedTimeRanges(_ player: AVPlayer)
    ///缓冲不足暂停
    @objc optional func MQPlayerItemPlaybackBufferEmpty(_ player: AVPlayer)
    ///缓冲可以跟上播放
    @objc optional func MQPlayerItemPlaybackLikelyToKeepUp(_ player: AVPlayer)
    ///缓冲完成
    @objc optional func MQPlayerItemPlaybackBufferFull(_ player: AVPlayer)
    
    ///当前item播放完成
    @objc optional func MQPlayerItemDidPlayToEndTime(_ player: AVPlayer)
    ///当前item没有及时到达制定播放位置
    @objc optional func MQPlayerItemPlaybackStalled(_ player: AVPlayer)
    ///AVPlayerItem添加了一个新的错误日志条目
    @objc optional func MQPlayerItemNewErrorLogEntry(_ player: AVPlayer)
}

