//
//  LBPhotoPickerController.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBAlbumModel.h"

@class LBAlbumModel;
@interface LBPhotoPickerController : UIViewController
@property (nonatomic, strong) LBAlbumModel *albumModel;

- (void)refreshCollectionViewWithindexPaths:(NSArray *)indexPaths;
@end
