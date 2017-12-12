//
//  JGProgressHUD+expand.m
//  LifeCareProject
//
//  Created by 杨孟强 on 17/3/23.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

#import "JGProgressHUD+expand.h"

#define HUD_TAG (NSInteger)3696369

@implementation JGProgressHUD (expand)

+ (instancetype)showTextHUD:(NSString *)text
{
    return [JGProgressHUD showTextHUDInView:[[UIApplication sharedApplication].delegate window] text:text];
}

+ (instancetype)showTextHUDInView:(UIView *)inView text:(NSString *)text
{
    if (!inView || !text || text.length == 0) {
        return nil;
    }
    
    JGProgressHUD *HUD = [[JGProgressHUD alloc] init];
    HUD.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    HUD.indicatorView = nil;
    HUD.position = JGProgressHUDPositionBottomCenter;
    HUD.marginInsets = UIEdgeInsetsMake(0.0f, 0.0f, 100.0f, 0.0f);
    HUD.textLabel.text = text;
    [HUD showInView:inView];
    [inView bringSubviewToFront:HUD];
    
    [HUD dismissAfterDelay:2.0];
    
    return HUD;
}

+ (instancetype)showNormalHUD
{
    return [JGProgressHUD showNormalHUDInView:[[UIApplication sharedApplication].delegate window] text:nil canClick:NO];
}
+ (instancetype)showNormalHUDCanClick:(BOOL)canClick
{
    return [JGProgressHUD showNormalHUDInView:[[UIApplication sharedApplication].delegate window] text:nil canClick:canClick];
}

+ (instancetype)showNormalHUDText:(NSString *)text
{
    return [JGProgressHUD showNormalHUDInView:[[UIApplication sharedApplication].delegate window] text:text canClick:NO];
}
+ (instancetype)showNormalHUDText:(NSString *)text canClick:(BOOL)canClick
{
    return [JGProgressHUD showNormalHUDInView:[[UIApplication sharedApplication].delegate window] text:text canClick:canClick];
}

+ (instancetype)showNormalHUDInView:(UIView *)inView text:(NSString *)text
{
    return [JGProgressHUD showNormalHUDInView:inView text:text canClick:NO];
}
+ (instancetype)showNormalHUDInView:(UIView *)inView text:(NSString *)text canClick:(BOOL)canClick
{
    if (!inView) {
        return nil;
    }
    JGProgressHUD *HUD = [inView viewWithTag:HUD_TAG];
    if (HUD == nil) {
        
        HUD = [[JGProgressHUD alloc] init];
        HUD.tag = HUD_TAG;
        HUD.textLabel.text = text;
        HUD.marginInsets = UIEdgeInsetsMake(0.0f, 0.0f, 10.0f, 0.0f);
        [HUD showInView:inView];
    } else {
        
        HUD.textLabel.text = text;
    }
    if (canClick) {
        
        HUD.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
        HUD.backgroundColor = [UIColor clearColor];
    } else {
        
        HUD.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
        HUD.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    }
    
    [inView bringSubviewToFront:HUD];
    
    return HUD;
}

+ (void)hideNormalHUDInView:(UIView *)inView
{
    JGProgressHUD *HUD = [inView viewWithTag:HUD_TAG];
    if (HUD && [HUD isKindOfClass:[JGProgressHUD class]]) {
        [HUD dismiss]; HUD = nil;
    }
}

+ (void)hideNormalHUD
{
    JGProgressHUD *HUD = [[[UIApplication sharedApplication].delegate window] viewWithTag:HUD_TAG];
    if (HUD && [HUD isKindOfClass:[JGProgressHUD class]]) {
        [HUD dismiss]; HUD = nil;
    }
}

@end
