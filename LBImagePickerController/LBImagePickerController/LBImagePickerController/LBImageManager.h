//
//  LBImageManager.h
//  TZImagePickerController
//
//  Created by 谭真 on 16/1/4.
//  Copyright © 2016年 谭真. All rights reserved.
//  图片资源获取管理类
/**
 借鉴了优秀开源项目：TZImagePickerController
 github链接：https://github.com/banchichen/TZImagePickerController
 相册的数据加载直接搬自该优秀项目，为防止命名冲突，对类名进行了重命名；
 */

#import "LBImagePickerController.h"
#import "LBPhotoPickerController.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


#define LBIOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define LBIOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define LBIOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define LBPHONEWIDTH [[UIScreen mainScreen] bounds].size.width
#define LBPHONEHEIGHT [[UIScreen mainScreen] bounds].size.height

@class LBAlbumModel,LBAssetModel,LBImagePickerController,LBPhotoPickerController;
@interface LBImageManager : NSObject

+ (instancetype)manager;

@property (nonatomic, weak) LBImagePickerController *pickerVc;
@property (nonatomic, weak) LBPhotoPickerController *photoVc;

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, assign) BOOL shouldFixOrientation;

/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;
+ (NSInteger)authorizationStatus;
- (void)requestAuthorizationWithCompletion:(void (^)())completion;

/// Get Album 获得相册/相册数组
- (void)getCameraRollAlbumWithCompletion:(void (^)(LBAlbumModel *))completion;
- (void)getAllAlbumsWithCompletion:(void (^)(NSArray<LBAlbumModel *> *))completion;

/// Get Assets 获得Asset数组
- (void)getAssetsFromFetchResult:(id)result completion:(void (^)(NSArray<LBAssetModel *> *models))completion;
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index completion:(void (^)(LBAssetModel *))completion;

/// Get photo 获取封面图
- (void)getPostImageWithAlbumModel:(LBAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

/// 获得照片本身
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/// Get full Image 获取原图
/// 该方法会先返回缩略图，再返回原图，如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;

/// Save photo 保存照片
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

- (NSString *)getAssetIdentifier:(id)asset;
- (BOOL)isCameraRollAlbum:(NSString *)albumName;

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(id)asset;
- (CGSize)photoSizeWithAsset:(id)asset;


/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;

/// 从bundle资源包中获取icon
+ (UIImage *)imageNamed:(NSString *)aImageName;

//  颜色转换为背景图片
+ (UIImage *)imageWithColor:(UIColor *)color;

@end

