//
//  LBImagPickerHUD.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/11.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBImagPickerHUD : UIButton
/** 最多15秒会消失 */
+ (instancetype)show;
+ (instancetype)showWithTitle:(NSString *)title;

- (void)hidden;
@end
