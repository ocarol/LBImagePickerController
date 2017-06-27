//
//  LBPhotoPreviewController.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/8.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoPreviewController.h"
#import "LBPhotoSheetAlertView.h"
#import "LBImagPickerHUD.h"

static  NSString *kLBPhotoPreviewController = @"kLBPhotoPreviewController";
@interface LBPhotoPreviewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>


@property (nonatomic, strong) UICollectionView *photoDetailCollectionView;
/** 选中点击按钮 */
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *imageModels;

@end

@implementation LBPhotoPreviewController

- (instancetype)initWithImages:(NSArray <UIImage *> *)images {
    
    self = [super init];
    if (self) {
        self.imageModels = [NSMutableArray array];
        for (int i = 0; i < images.count; i++) {
            LBPhotoPreviewModel *model = [[LBPhotoPreviewModel alloc] init];
            model.image = images[i];
            model.index = i;
            [self.imageModels addObject:model];
        }
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.imageModels.count) {
        [self goBack];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpView];
    
}

- (void)setUpView {
    [self setupNav];
    
    [self.view addSubview:self.photoDetailCollectionView];
    if (self.autoPositionIndex < self.imageModels.count) {
        [self.photoDetailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.autoPositionIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    
}

- (void)setupNav {
    self.navigationController.navigationBar.hidden = YES;
    UIView *customNav = [[UIView alloc] initWithFrame:CGRectMake(0, 20, LBPHONEWIDTH, 44)];
    customNav.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customNav];
    
    // 返回
    UIImageView *backImgView = [[UIImageView alloc] init];
    backImgView.frame = CGRectMake(20, (customNav.lb_height - 17) * 0.5, 9, 17);
    backImgView.image = [LBImageManager imageNamed:@"LBPhotoPreview_back@2x.png"];
    [customNav addSubview:backImgView];
    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 50, customNav.lb_height)];
    [backControl addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [customNav addSubview:backControl];
    
    if (!self.readonly) {
        // 删除
        UIImageView *delateImgView = [[UIImageView alloc] init];
        delateImgView.frame = CGRectMake(LBPHONEWIDTH - 18 - 20, (customNav.lb_height - 18) * 0.5, 18, 18);
        delateImgView.image = [LBImageManager imageNamed:@"LBPhotoPreview_deleted@2x.png"];
        [customNav addSubview:delateImgView];
        UIControl *deleteControl = [[UIControl alloc] initWithFrame:CGRectMake(LBPHONEWIDTH - 58, 0, 58, customNav.lb_height)];
        [customNav addSubview:deleteControl];
        [deleteControl addTarget:self action:@selector(deletedPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(backImgView.lb_right, 0, LBPHONEWIDTH - 38 - backImgView.lb_right, customNav.lb_height);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [customNav addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [self refreshInfos];
}


- (void)refreshInfos {
    self.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex + 1, self.imageModels.count];
}


#pragma mark -btClick
- (void)deletedPhotoClick:(UIButton *)button {
    LBPhotoSheetAlertView *sheetView = [[LBPhotoSheetAlertView alloc] init];
    UIColor *tipColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [sheetView addSheetWithTitle:@"要删除这张照片吗？" titleColor:tipColor target:nil action:nil];
    UIColor *deleteColor =  [UIColor colorWithRed:254/255.0 green:94/255.0 blue:94/255.0 alpha:1/1.0];
    [sheetView addSheetWithTitle:@"删除" titleColor:deleteColor target:self action:@selector(didDeleted)];
    [sheetView showOnView:self.view cancelTitle:@"取消" exampleImage:nil];
}

- (void)showDeletedSuccess {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 98)];
    imageView.layer.cornerRadius = 4.0f;
    imageView.clipsToBounds = YES;
    imageView.image = [LBImageManager imageNamed:@"LBPhotoSuccess@2x.png"];
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 98, 20)];
    tip.text = @"已删除";
    tip.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:tip];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:1.5 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

- (void)didDeleted {
    // 删除操作
    LBPhotoPreviewModel *model = self.imageModels[self.currentIndex];
    [self.imageModels removeObject:model];
    
    [self showDeletedSuccess];
    
    if (self.didDeletedBlock) {
        self.didDeletedBlock(self.currentIndex,model.image);
    }
    
    
    if (self.imageModels.count) {
        [self.photoDetailCollectionView reloadData];
        [self refreshInfos];
        
    }else {
        [self goBack];
    }
}

- (void)goBack {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -UICollectionViewDataSource and UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LBPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLBPhotoPreviewController forIndexPath:indexPath];
    cell.model = self.imageModels[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    NSInteger index = (offSetWidth + LBPHONEWIDTH * 0.5) / LBPHONEWIDTH;
    if (self.currentIndex != index) {
        self.currentIndex = index;
        [self refreshInfos];
    }
    
}


- (UICollectionView *)photoDetailCollectionView {
    
    if (!_photoDetailCollectionView) {
        CGFloat collectionViewHeight = LBPHONEHEIGHT - 64 * (self.navigationController && !self.navigationController.navigationBarHidden);
        
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
        [_photoDetailCollectionView registerClass:[LBPhotoPreviewCell class] forCellWithReuseIdentifier:kLBPhotoPreviewController];
    }
    return _photoDetailCollectionView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
