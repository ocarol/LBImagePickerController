//
//  LBAlbumModel.h
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBImageManager.h"

@interface LBAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, assign) BOOL supportCamera; // 支持拍照

@property (nonatomic, strong) NSArray *models;
@end
