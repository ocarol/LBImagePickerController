//
//  LBPhotoSheetAlertView.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/8.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPhotoSheetAlertView : UIView
@property (nonatomic,copy) NSString *exampleImgName;

- (void)addSheetWithTitle:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action;
- (UIView *)showOnView:(UIView *)view cancelTitle:(NSString *)cancelTitle exampleImage:(UIImage *)exampleImage;


@end

@interface LBPhotoSheetAlertModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (nonatomic, strong) UIColor *titleColor;

@end
