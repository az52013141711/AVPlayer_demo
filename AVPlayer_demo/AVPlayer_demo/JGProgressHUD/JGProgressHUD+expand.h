//
//  JGProgressHUD+expand.h
//  LifeCareProject
//
//  Created by 杨孟强 on 17/3/23.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

#import "JGProgressHUD.h"

@interface JGProgressHUD (expand)

+ (instancetype)showTextHUD:(NSString *)text;
+ (instancetype)showTextHUDInView:(UIView *)inView text:(NSString *)text;

+ (instancetype)showNormalHUD;
+ (instancetype)showNormalHUDCanClick:(BOOL)canClick;
+ (instancetype)showNormalHUDText:(NSString *)text;
+ (instancetype)showNormalHUDText:(NSString *)text canClick:(BOOL)canClick;
+ (instancetype)showNormalHUDInView:(UIView *)inView text:(NSString *)text;
+ (instancetype)showNormalHUDInView:(UIView *)inView text:(NSString *)text canClick:(BOOL)canClick;

+ (void)hideNormalHUD;
+ (void)hideNormalHUDInView:(UIView *)inView;

@end
