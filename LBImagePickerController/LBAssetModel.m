//
//  LBAssetModel.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBAssetModel.h"

@implementation LBAssetModel
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset {
    LBAssetModel *model = [[self alloc] init];
    model.asset = asset;
    return model;
}
@end

@implementation LBAssetPickerModel
+ (instancetype)modelWithTitle:(NSString *)title atIndex:(NSInteger)titleIndex {
    LBAssetPickerModel *model = [[self alloc] init];
    model.title = title;
    model.index = titleIndex;
    return model;
}
@end
