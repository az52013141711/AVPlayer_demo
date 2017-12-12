//
//  ViewController+Delegate.swift
//  AVAudioPlayer_demo
//
//  Created by Mac on 2017/12/3.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import AVFoundation

extension ViewController {

    // MARK: - MQPlayerManagerDelegate
    func MQPlayerPeriodicTime(_ player: AVPlayer, _ time: CMTime) {
        
        //刷新当前播放时间
        let currentItemTime = CMTimeGetSeconds(time)
        self.currentTimeLabel.text = String(format: "%.2d:%.2d", Int(currentItemTime)/60, Int(currentItemTime)%60)
        
        //刷新进度条
        if let currentItem = player.currentItem {
            self.playSlider.value = Float(currentItemTime / CMTimeGetSeconds(currentItem.duration))
        }
    }
    
    //缓冲不足暂停
    func MQPlayerItemPlaybackBufferEmpty(_ player: AVPlayer) {
        
        JGProgressHUD.showNormalHUDText("缓冲中...")
    }
    
    //缓冲可以跟上播放
    func MQPlayerItemPlaybackLikelyToKeepUp(_ player: AVPlayer) {
        JGProgressHUD.hideNormalHUD()
    }
    
    //播放完成
    func MQPlayerItemDidPlayToEndTime(_ player: AVPlayer) {
        
//        self.endPlayingInitialize()
//        MQPlayerManager.sharedInstance.player.seek(to: kCMTimeZero)
//        JGProgressHUD.showTextHUD("播放完成,点击▶️按钮重新播放,⏮⏭切换.")
        
        //切换下一曲
        self.endPlayingInitialize()
        self.clickNextSong()
    }
    
    //缓冲进度
    func MQPlayerItemLoadedTimeRanges(_ player: AVPlayer) {
        
        if let currentItem = player.currentItem {
            
            let loadedTimeRanges = currentItem.loadedTimeRanges
            
            if loadedTimeRanges.count > 0 {
                let timeRange:CMTimeRange = loadedTimeRanges.first as! CMTimeRange//获取缓冲区域
                
                let startSeconds = CMTimeGetSeconds(timeRange.start)
                let durationSeconds = CMTimeGetSeconds(timeRange.duration)
                let timeInterval = startSeconds + durationSeconds//计算缓冲总进度
                
                let currentInterval = CMTimeGetSeconds(currentItem.currentTime())
                
                let totalDuration = CMTimeGetSeconds(currentItem.duration)//总时间
                
                let progress = timeInterval / totalDuration //缓冲进度
                
                print("\(currentInterval):\(timeInterval),loadedTime:\(progress)")
            }
        }
    }
    
    //AVPlayerItem状态改变
    func MQPlayerItemSwitchOverTheStatus(_ player: AVPlayer, status: AVPlayerItemStatus) {
        switch status {
            
        case .readyToPlay:
            
            //获取总时间
            if let currentItem = player.currentItem {
                
                let totalDuration = Int(CMTimeGetSeconds(currentItem.duration))
                self.totalTimeLabel.text = String(format: "/%.2d:%.2d", totalDuration / 60, totalDuration % 60)
                
                
                let asset = currentItem.asset
                weak var weakSelf = self
                
                //如果是mp4 获取中间一张缩略图
                if self.urlArray.count > self.playIndexes {
                   
                    if let url = URL(string: self.urlArray[self.playIndexes]) {
                        if url.pathExtension == "mp4" {
                            
                            let times = [NSNumber(value: CMTimeGetSeconds(currentItem.duration) / 2.0)]
                            MQPlayerManager.sharedInstance.getCurrenImageGenerator(
                                times: times,
                                handler: { (requestedTime,
                                    image,
                                    actualTime,
                                    result,
                                    error) in
                                    
                                    if image != nil {
                                        DispatchQueue.main.sync {
                                            weakSelf?.artworkImageView.image = UIImage(cgImage: image!)
                                        }
                                    }
                            })
                        }
                    }
                }
                
                //获取歌曲信息
                asset.loadValuesAsynchronously(forKeys: [], completionHandler: {
                    
                    
                    /*
                     <AVMetadataItem: 0x1c401bcd0, identifier=id3/TSSE, keySpace=org.id3, key class = NSTaggedPointerString, key=TSSE, commonKey=(null), extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=__NSCFString, value=Lizhi codec>
                     <AVMetadataItem: 0x1c401db60, identifier=id3/TIT2, keySpace=org.id3, key class = NSTaggedPointerString, key=TIT2, commonKey=title, extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=__NSCFString, value=151 唯一就等于没有（作者 | 张嘉佳）>
                     <AVMetadataItem: 0x1c401db70, identifier=id3/TPE1, keySpace=org.id3, key class = NSTaggedPointerString, key=TPE1, commonKey=artist, extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=__NSCFString, value=背着吉他的蝙蝠女侠>
                     <AVMetadataItem: 0x1c401d9d0, identifier=id3/TALB, keySpace=org.id3, key class = NSTaggedPointerString, key=TALB, commonKey=albumName, extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=__NSCFString, value=昨天的你的现在的未来>
                     <AVMetadataItem: 0x1c0019f90, identifier=id3/TYER, keySpace=org.id3, key class = NSTaggedPointerString, key=TYER, commonKey=(null), extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=NSTaggedPointerString, value=2015>
                     <AVMetadataItem: 0x1c001a030, identifier=id3/TCON, keySpace=org.id3, key class = NSTaggedPointerString, key=TCON, commonKey=type, extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=__NSCFString, value=网络电台>
                     <AVMetadataItem: 0x1c001a050, identifier=id3/TLEN, keySpace=org.id3, key class = NSTaggedPointerString, key=TLEN, commonKey=(null), extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     }, value class=NSTaggedPointerString, value=877623>
                     <AVMetadataItem: 0x1c001a070, identifier=id3/APIC, keySpace=org.id3, key class = NSTaggedPointerString, key=APIC, commonKey=artwork, extendedLanguageTag=(null), dataType=com.apple.metadata.datatype.JPEG, time={INVALID}, duration={INVALID}, startDate=(null), extras={
                     dataType = "image/jpeg";
                     dataTypeNamespace = "org.iana.media-type";
                     info = "";
                     pictureType = Other;
                     }, value class=__NSCFData, value length=50981>
                     */
                    let metadata = asset.metadata(forFormat: AVMetadataFormat.id3Metadata)
                    var infoString = ""
                    
                    var title:String? = nil
                    var artist:String? = nil
                    var artworkImage:UIImage? = nil
                    
                    for itme in metadata {
                        
                        if let key: AVMetadataKey = itme.commonKey {
                            
                            switch key {
                                
                            case .commonKeyArtwork:
                                if itme.dataValue != nil {
                                    artworkImage = UIImage(data: itme.dataValue!)
                                    self.artworkImageView.image = artworkImage
                                }
                                break
                                
                            case .commonKeyTitle:
                                
                                if itme.stringValue != nil {
                                    title = itme.stringValue!
                                    self.navigationItem.title = title!
                                } else {
                                    if self.navigationItem.title == nil &&
                                        self.navigationItem.title != "音乐播放器" {
                                        self.navigationItem.title = "音乐播放器"
                                    }
                                }
                                break
                                
                            case .commonKeyArtist:
                                if itme.stringValue != nil {
                                    artist = itme.stringValue!
                                    infoString += "艺术家：" + itme.stringValue! + "\n"
                                }
                                break
                                
                            case .commonKeyAlbumName:
                                if itme.stringValue != nil {
                                    infoString += "所属专辑：" + itme.stringValue! + "\n"
                                }
                                break
                                
                            default:
                                break
                            }
                        }
                        
                    }
                    
                    self.infoLabel.text = infoString
                    
                    var playbackTime: NSNumber? = nil
                    var duration: NSNumber? = nil
                    
                    if MQPlayerManager.sharedInstance.player.currentItem != nil {
                        playbackTime = NSNumber(value: CMTimeGetSeconds(currentItem.currentTime()))
                        duration = NSNumber(value: CMTimeGetSeconds(currentItem.duration))
                    }
                    
                    //设置锁屏样式
                    weakSelf?.configNowPlayingCenter(title: title, artist: artist, playbackTime: playbackTime, duration: duration, artworkImage: artworkImage)
                })
                
            }
            
            break
            
        case .unknown:
            JGProgressHUD.showTextHUD("播放失败,未知错误!")
            self.startPlayingInitialize()
            break
            
        case .failed:
            
            if let error:NSError = player.currentItem?.error as NSError? {
                JGProgressHUD.showTextHUD("播放失败:\(error.userInfo)")
            } else {
                JGProgressHUD.showTextHUD("播放失败,未知错误!")
            }
            self.startPlayingInitialize()
            break
        }
    }
    
    func MQPlayerItemNewErrorLogEntry(_ player: AVPlayer) {
        
        if let error:NSError = player.currentItem?.error as NSError? {
            JGProgressHUD.showTextHUD("\(error.userInfo)")
        } else {
            JGProgressHUD.showTextHUD("未知错误!")
        }
    }
}
