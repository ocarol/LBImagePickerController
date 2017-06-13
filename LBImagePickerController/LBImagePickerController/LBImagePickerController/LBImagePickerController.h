//
//  LBImagePickerController.h
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.


#import <UIKit/UIKit.h>
#import "LBAlbumModel.h"
#import "LBAssetModel.h"
#import "UIView+LBLayout.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


@class LBImagePickerController,LBAssetModel,LBAlbumModel;
@protocol LBImagePickerControllerDelegate <NSObject>
@optional
- (void)LBImagePickerController:(LBImagePickerController *)picker didFinishPickingPhotos:(NSArray <LBAssetModel *> *)assetModels;
- (void)LBImagePickerControllerDidCancel:(LBImagePickerController *)picker;
@end


@interface LBImagePickerController : UINavigationController
#pragma mark - public 外界可以改变的属性
/** LBImagePickerControllerDelegate */
@property (nonatomic, weak) id<LBImagePickerControllerDelegate> aDelegate;
/** 结果回调 */
@property (nonatomic, copy) void (^LBImagePickerDidFinishPickingPhotosBlock)(NSArray <LBAssetModel *> *assetModels);
@property (nonatomic, copy) void (^LBImagePickerControllerDidCancelBlock)();

/** 默认为YES，如果设置为NO, 选择器将不会自己dismiss */
@property (nonatomic, assign) BOOL autoDismiss;
/** 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
/** 是否显示相机 默认为YES*/
@property (nonatomic, assign, getter=isShowCamere)  BOOL showCamera;
/** 实例图片名字 cameraInside = NO时有效 */
@property (nonatomic,copy) NSString *exampleImgName;

#pragma mark - privete 内部使用的属性
/** 当前选中的相册分类 */
@property (nonatomic, strong)LBAlbumModel *selectedAlbumModel;
/** 只读 最大可选数量 default is 0，0表示无限大 根据初始化发放来 */
@property (readonly, nonatomic, assign) NSInteger maxImagesCount;
/** 只读 是否是有序的；默认无序，根据初始化方法判断(指定最大可选数量，无序；指定需要选中的图片，有序) */
@property (readonly ,nonatomic, assign) BOOL isOrderly;
/** 只读 相机是否在内部 根据初始化方法来 */
@property (readonly, nonatomic, assign, getter=isCameraInside) BOOL cameraInside;
/** 底部bar */
@property (nonatomic, weak) UIView *bottomBar;


#pragma mark - public method
/**
 用这个初始化方法 指定最大可选数量，图片选择无序

 @param maxImagesCount 指定最大可选数量
 @param delegate delegate
 @param cameraInside 相机功能置于相册内部
 @return 无序的图片选择器
 */
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<LBImagePickerControllerDelegate>)delegate cameraInside:(BOOL)cameraInside;

/**
 用这个初始化方法 指定需要选中的图片，图片选择有序

 @param photoTitles 指定需要选中的图片
 @param delegate delegate
 @param cameraInside 相机功能置于相册内部
 @return 有序的图片选择器
 */
- (instancetype)initWithPhotoTitles:(NSArray <NSString *>*)photoTitles delegate:(id<LBImagePickerControllerDelegate>)delegate cameraInside:(BOOL)cameraInside;

// 拍照
- (void)takePhoto;
// 相册选择
- (void)pushPhotoPickerVc;

#pragma mark - LBImagePickerController 私有方法，外界不要调用
#pragma mark 数据处理
// 清空选项
- (void)clearAllSelectedModels;
// 操作图片选择
- (void)changeAssetModelStatus:(LBAssetModel *)assetModel;

#pragma mark end event
- (void)didCancelPicking;

#pragma mark 提示
- (void)showAlertWithTitle:(NSString *)title;

@end



