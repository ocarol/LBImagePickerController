//
//  LBPhotoPreviewController.h
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/8.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBImageManager.h"
#import "LBPhotoPreviewCell.h"
#import "LBPhotoPreviewModel.h"

@interface LBPhotoPreviewController : UIViewController
@property (nonatomic, assign) NSInteger autoPositionIndex; // 自动定位的图片索引
// 是否只读的 默认为NO，为YES的时候可以进行删除操作
@property (readonly ,nonatomic, assign) BOOL readonly;
@property (nonatomic, copy) void (^didDeletedBlock)(NSInteger index,UIImage *image);

- (instancetype)initWithImages:(NSArray <UIImage *> *)images;
@end
