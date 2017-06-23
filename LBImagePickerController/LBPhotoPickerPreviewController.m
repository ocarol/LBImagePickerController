//
//  LBPhotoPickerPreviewController.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoPickerPreviewController.h"
#import "LBPhotoPickerPreviewCell.h"

static  NSString *kLBPhotoPickerPreviewController = @"kLBPhotoPickerPreviewController";
@interface LBPhotoPickerPreviewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>


@property (nonatomic, strong) UICollectionView *photoDetailCollectionView;
/** 选中点击按钮 */
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation LBPhotoPickerPreviewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.navigationController.navigationBar.hidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpView];
}

- (void)setAlbumModel:(LBAlbumModel *)albumModel {
    _albumModel = albumModel;
    self.title = albumModel.name;
}

- (void)setUpNav {
    
    //自定义UIView
    UIButton *btn=[[UIButton alloc]init];
    //设置按钮的背景图片（默认/高亮）
    [btn setBackgroundImage:[LBImageManager imageNamed:@"LBPhotoPickerPreviewCell_photo_selected@2x.png"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[LBImageManager imageNamed:@"LBPhotoPickerPreviewCell_photo_default@2x.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 26, 26);
    [btn addTarget:self action:@selector(selectPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = btn;
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setUpView {
    
    [self setUpNav];
    [self.view addSubview:self.photoDetailCollectionView];
    
    [self changeSelectedStatusAtIndex:self.autoPositionIndex];
//    self.photoDetailCollectionView.contentOffset = CGPointMake(self.autoPositionIndex * [[UIScreen mainScreen] bounds].size.width, 0);
    [self.photoDetailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.autoPositionIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark - btClick
- (void)selectPhotoClick:(UIButton *)button {
    LBAssetModel *model = self.albumModel.models[self.currentIndex];
    [[LBImageManager manager].pickerVc changeAssetModelStatus:model];
    self.rightBtn.selected = model.isSelected;
}

#pragma mark -UICollectionViewDataSource and UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumModel.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LBPhotoPickerPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLBPhotoPickerPreviewController forIndexPath:indexPath];
    cell.model = self.albumModel.models[indexPath.row];
    return cell;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    NSInteger index = (offSetWidth + LBPHONEWIDTH * 0.5) / LBPHONEWIDTH;
    if (self.currentIndex != index) {
        self.currentIndex = index;
        [self changeSelectedStatusAtIndex:index];
    }
}

- (void)changeSelectedStatusAtIndex:(NSInteger)index {
    LBAssetModel *model = self.albumModel.models[index];
    self.rightBtn.selected = model.isSelected;
}


- (UICollectionView *)photoDetailCollectionView {
    
    if (!_photoDetailCollectionView) {
        CGFloat collectionViewHeight = LBPHONEHEIGHT - 64 - 60;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection  = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(LBPHONEWIDTH, collectionViewHeight);
        _photoDetailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,64, LBPHONEWIDTH, collectionViewHeight) collectionViewLayout:flowLayout];
        _photoDetailCollectionView.pagingEnabled = YES;
        _photoDetailCollectionView.delegate = self;
        _photoDetailCollectionView.dataSource = self;
        _photoDetailCollectionView.backgroundColor = [UIColor whiteColor];
        [_photoDetailCollectionView registerClass:[LBPhotoPickerPreviewCell class] forCellWithReuseIdentifier:kLBPhotoPickerPreviewController];
    }
    return _photoDetailCollectionView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
