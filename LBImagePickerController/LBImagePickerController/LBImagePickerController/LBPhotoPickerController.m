//
//  LBPhotoPickerController.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoPickerController.h"
#import "LBImagePickerController.h"
#import "LBPhotoPickerPreviewController.h"
#import "LBPhotoPickerCell.h"

static NSString *kPhotoPickerCellID = @"kPhotoPickerCellID";
static NSString *kPhotoCameraCellID = @"kPhotoCameraCellID";

@interface LBPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate>
/* 图片列表 **/
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, assign) BOOL showCamera;
@property (nonatomic, assign) BOOL sortAscending;
@end

@implementation LBPhotoPickerController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LBImageManager manager].pickerVc.bottomBar.hidden = NO;
    self.title = self.albumModel.name;
    [self.photoCollectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [LBImageManager manager].pickerVc.selectedAlbumModel = self.albumModel;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [LBImageManager manager].photoVc = self;
    self.showCamera = [LBImageManager manager].pickerVc.isCameraInside && self.albumModel.supportCamera && [LBImageManager manager].pickerVc.isShowCamere;
    self.sortAscending = [LBImageManager manager].pickerVc.sortAscendingByModificationDate;
    
    [self.view addSubview:self.photoCollectionView];

    [self scrollCollectionViewToBottom];
    // Do any additional setup after loading the view.
}


- (void)refreshCollectionViewWithindexPaths:(NSArray *)indexPaths {
    if (!indexPaths.count) {
       [self.photoCollectionView reloadData];
    }else {
        [self.photoCollectionView reloadItemsAtIndexPaths:indexPaths];
    }
    
    [self scrollCollectionViewToBottom];
}


- (UICollectionView *)photoCollectionView {
    
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection  = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 1;
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.itemSize = CGSizeMake((LBPHONEWIDTH - 3)/4, (LBPHONEWIDTH - 3)/4);
        BOOL showFooterView = [LBImageManager manager].pickerVc.maxImagesCount > 1;
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,64, LBPHONEWIDTH, LBPHONEHEIGHT - 64 - 60 * showFooterView) collectionViewLayout:flowLayout];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        [_photoCollectionView registerClass:[LBPhotoPickerCell class] forCellWithReuseIdentifier:kPhotoPickerCellID];
        [_photoCollectionView registerClass:[LBAssetCameraCell class] forCellWithReuseIdentifier:kPhotoCameraCellID];
    }
    return _photoCollectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumModel.models.count + self.showCamera;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCamera = (self.sortAscending && indexPath.row == self.albumModel.models.count) || (!self.sortAscending && indexPath.row == 0);
    if (self.showCamera && isCamera) {
        LBAssetCameraCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCameraCellID forIndexPath:indexPath];
        return cameraCell;
    }
    
    LBPhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoPickerCellID forIndexPath:indexPath];
    cell.model = self.albumModel.models[indexPath.row - (!self.sortAscending && self.showCamera)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCamera = (self.sortAscending && indexPath.row == self.albumModel.models.count) || (!self.sortAscending && indexPath.row == 0);
    if (self.showCamera && isCamera) {
        // 拍照
        [[LBImageManager manager].pickerVc takePhoto];
        return;
    }

    if ([LBImageManager manager].pickerVc.maxImagesCount == 1) { // 单选模式
        [[LBImageManager manager].pickerVc changeAssetModelStatus:self.albumModel.models[indexPath.row - (!self.sortAscending && self.showCamera)]];
    }else {
        LBPhotoPickerPreviewController *previewVC = [[LBPhotoPickerPreviewController alloc] init];
        previewVC.albumModel = self.albumModel;
        previewVC.autoPositionIndex = indexPath.row - (!self.sortAscending && self.showCamera);
        [self.navigationController pushViewController:previewVC animated:YES];
    }
    
}

- (void)scrollCollectionViewToBottom {
    if (self.sortAscending && self.albumModel.models.count > 0) {
        NSInteger item = self.albumModel.models.count - 1 + self.showCamera * 1;
        [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [LBImageManager manager].photoVc = nil;
}


@end
