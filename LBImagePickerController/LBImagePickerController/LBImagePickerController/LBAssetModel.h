//
//  LBAssetModel.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBImageManager.h"

@interface LBAssetModel : NSObject
@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
/** 小图 */
@property (nonatomic, strong) UIImage *pickerImage;
/** 大图 */
@property (nonatomic, strong) UIImage *PreviewImage;
@property (nonatomic, assign, getter=isSelected) BOOL selected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) NSInteger selctedIndex;
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset;
@end


@interface LBAssetPickerModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger index; /// 无序的时候为0，有序的时候为1、2、3...
@property (nonatomic, strong) LBAssetModel *assetModel;      ///< The select status of a photo, default is No
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithTitle:(NSString *)title atIndex:(NSInteger)index;
@end
