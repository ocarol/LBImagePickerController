//
//  LBPhotoPreviewModel.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/8.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPhotoPreviewModel : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id asset;
@property (nonatomic, assign) NSInteger index;

@end
