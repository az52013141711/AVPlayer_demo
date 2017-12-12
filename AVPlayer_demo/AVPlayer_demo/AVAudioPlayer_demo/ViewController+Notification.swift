//
//  ViewController+Notification.swift
//  AVAudioPlayer_demo
//
//  Created by Mac on 2017/12/3.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import AVFoundation

extension ViewController {
    
    // MARK: - 遥控事件通知
    @objc func remoteControlReceivedNotification(_ notification: Notification) {
        
        guard let event:UIEvent = notification.object as? UIEvent else {
            return
        }
        
        switch event.subtype {
            
        case .none:
            
            break
            
        case .motionShake:
            
            break
            
        case .remoteControlPlay:
            self.clickPlayPause()
            break
            
        case .remoteControlPause:
            self.clickPlayPause()
            break
            
        case .remoteControlStop:
            
            break
            
        case .remoteControlTogglePlayPause:
            self.clickPlayPause()
            break
            
        case .remoteControlNextTrack:
            self.clickNextSong()
            break
            
        case .remoteControlPreviousTrack:
            self.clickPreviousSong()
            break
            
        case .remoteControlBeginSeekingBackward:
            
            break
            
        case .remoteControlEndSeekingBackward:
            
            break
            
        case .remoteControlBeginSeekingForward:
            
            break
            
        case .remoteControlEndSeekingForward:
            
            break
        }
    }
    
    
    //MARK: - 中断通知
    @objc func handleInterruption(_ notification: NSNotification) {
        
        let info = notification.userInfo;
        let type = AVAudioSessionInterruptionType(rawValue: info?[AVAudioSessionInterruptionTypeKey] as! UInt)
        
        //中断开始,被打断
        if type == AVAudioSessionInterruptionType.began {
            
            self.pause()
        } else {//中断结束
            
            let optionType = AVAudioSessionInterruptionOptions(rawValue: info?[AVAudioSessionInterruptionOptionKey] as! UInt)
            if optionType == AVAudioSessionInterruptionOptions.shouldResume {
                //应用获得可以继续播放通知，应该恢复播放
                self.play()
            }
        }
    }
    
    //MARK: - 线路切换通知
    @objc func handleRouteChange(_ notification: NSNotification) {
        
        let info = notification.userInfo;
        let reason = AVAudioSessionRouteChangeReason(rawValue: info?[AVAudioSessionRouteChangeReasonKey] as! UInt)
        
        if reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable {
            //旧设备不可用时
            
            
            //获取上一个输出设备
            let previousRoute = (info?[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription)
            let previousOutput = previousRoute.outputs[0]
            let portType = previousOutput.portType
            
            //如果是断开耳机连接
            if (portType.elementsEqual(AVAudioSessionPortHeadphones)) {
                self.pause()
            }
        }
        
    }
    
    // MARK: - 应用进入后台通知
    @objc func applicationEnterBackground(_ notification: NSNotification) {
        
        //处理视频播放中进入后台自动暂停的问题
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            if weakSelf != nil &&
                weakSelf?.playPauseButton.isSelected == false &&
                MQPlayerManager.sharedInstance.isPlayStatus == false{
                weakSelf?.play()
            }
        }
    }
    
    // MARK: - 应用即将被挂起(设置后台任务ID)
    @objc func applicationWillResignActive(_ notification: NSNotification) {
        
        //设置后台任务ID
        let newTaskId = UIApplication.shared.beginBackgroundTask {
            //
        }
        if newTaskId != UIBackgroundTaskInvalid {
            
            if self.backTaskId != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(self.backTaskId)
            }
            self.backTaskId = newTaskId
        }
    }
    
    //MARK: - 应用即将被终止
    @objc func applicationWillTerminate(_ notification: NSNotification) {
        //移除RemoteControl事件
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
}

