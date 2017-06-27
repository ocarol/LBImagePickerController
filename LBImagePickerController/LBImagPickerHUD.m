//
//  LBImagPickerHUD.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/11.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBImagPickerHUD.h"
#import "UIView+LBLayout.h"
#import "LBImageManager.h"

@implementation LBImagPickerHUD

+ (instancetype)show {
    return [self showWithTitle:@"处理中..."];
}


+ (instancetype)showWithTitle:(NSString *)title {
    LBImagPickerHUD *hud = [self buttonWithType:UIButtonTypeCustom];
    

    [hud setBackgroundColor:[UIColor clearColor]];
    
    UIView *HUDContainer = [[UIView alloc] init];
    HUDContainer.frame = CGRectMake((LBPHONEWIDTH - 120) / 2, (LBPHONEHEIGHT - 90) / 2, 120, 90);
    HUDContainer.layer.cornerRadius = 8;
    HUDContainer.clipsToBounds = YES;
    HUDContainer.backgroundColor = [UIColor darkGrayColor];
    HUDContainer.alpha = 0.7;
    
    UIActivityIndicatorView *HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    
    UILabel *HUDLabel = [[UILabel alloc] init];
    HUDLabel.frame = CGRectMake(0,40, 120, 50);
    HUDLabel.textAlignment = NSTextAlignmentCenter;
    HUDLabel.text = title;
    HUDLabel.font = [UIFont systemFontOfSize:15];
    HUDLabel.textColor = [UIColor whiteColor];
    
    [HUDContainer addSubview:HUDLabel];
    [HUDContainer addSubview:HUDIndicatorView];
    [hud addSubview:HUDContainer];
    
    [HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    
    // 超时时间，默认为15秒,如果超时,会自动dismiss HUD
    __weak typeof(hud) weakHud = hud;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakHud hidden];
    });

    return hud;
}

- (void)hidden {
    [self removeFromSuperview];
}
@end
