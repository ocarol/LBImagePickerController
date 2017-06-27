//
//  LBPhotoPickerPreviewController.h
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBAlbumModel.h"

@interface LBPhotoPickerPreviewController : UIViewController
@property (nonatomic, strong) LBAlbumModel *albumModel;
@property (nonatomic, assign) NSInteger autoPositionIndex; // 自动定位的图片索引
@end
