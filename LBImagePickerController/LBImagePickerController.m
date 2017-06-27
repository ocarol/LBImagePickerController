//
//  LBImagePickerController.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBImagePickerController.h"
#import "LBAlbumPickerController.h"
#import "LBPhotoPickerController.h"
#import "LBPhotoPickerPreviewController.h"
#import "LBPhotoSheetAlertView.h"
#import "LBImagPickerHUD.h"

@interface LBImagePickerController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate> {
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UIButton *settingBtn;
@property (nonatomic, weak) UILabel *settingTipLbel;

// 待选中的图片
@property (nonatomic, strong) NSMutableArray *shouldSelectedModels;
//// 已选中的图片
@property (nonatomic, strong) NSMutableArray *selectedModels;

/** 下一步按钮 */
@property (nonatomic, weak) UIButton *nextTipBtn;
/** 提示label */
@property (nonatomic, weak) UILabel *nextTipLabel;

@property (nonatomic, assign) NSInteger nextIndex;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, weak) LBImagPickerHUD *hud;

@end

@implementation LBImagePickerController

#pragma mark - 生命周期

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isCameraInside) {
        [self pushPhotoPickerVc];
    }else {
        [self showCamerraOutSideView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}


#pragma mark - init
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<LBImagePickerControllerDelegate>)delegate cameraInside:(BOOL)cameraInside {
    return [self initWithMaxImagesCount:maxImagesCount photoTitles:nil delegate:delegate pushPhotoPickerVc:YES cameraInside:cameraInside];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount cameraInside:(BOOL)cameraInside {
    return [self initWithMaxImagesCount:maxImagesCount delegate:nil cameraInside:cameraInside];
}

- (instancetype)initWithPhotoTitles:(NSArray <NSString *>*)photoTitles delegate:(id<LBImagePickerControllerDelegate>)delegate cameraInside:(BOOL)cameraInside {
    return [self initWithMaxImagesCount:photoTitles.count photoTitles:photoTitles delegate:delegate pushPhotoPickerVc:YES cameraInside:cameraInside];
}

- (instancetype)initWithPhotoTitles:(NSArray <NSString *>*)photoTitles cameraInside:(BOOL)cameraInside {
    return [self initWithPhotoTitles:photoTitles delegate:nil cameraInside:cameraInside];
}

/// maxImagesCount 优先以photoTitles为参考对象
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount photoTitles:(NSArray <NSString *>*)photoTitles delegate:(id<LBImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc cameraInside:(BOOL)cameraInside {
    self= [super init];
    if (self) {
        // 支持透明效果
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self configDefaultSetting];
        _maxImagesCount = maxImagesCount;
        self.aDelegate = delegate;
        _cameraInside = cameraInside;

        if (photoTitles.count > 0) {
            _isOrderly = YES;
            _maxImagesCount = photoTitles.count;
            for (int i = 1; i <= self.maxImagesCount; i++) {
                LBAssetPickerModel *model = [LBAssetPickerModel modelWithTitle:photoTitles[i-1] atIndex:i];
                [self.shouldSelectedModels addObject:model];
            }
        }
    }
    
    return self;
}


#pragma mark - 相册
// 点击相册
- (void)pushPhotoPickerVc {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.hidden = NO;
    LBAlbumPickerController *albumPickerVc = [[LBAlbumPickerController alloc] init];
    albumPickerVc.title = @"相册列表";
    [self pushViewController:albumPickerVc animated:NO];
    
    if (![[LBImageManager manager] authorizationStatusAuthorized]) {
        [self setupSettingTipView];
        
        return;
    }
    
    [albumPickerVc configTableView];
    
    if (self.maxImagesCount > 1) {
        [self setupFooterView];
    }
    
    // 1.6.8 判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    LBPhotoPickerController *photoPickerVc = [[LBPhotoPickerController alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    // 获取相机胶卷
    [[LBImageManager manager] getCameraRollAlbumWithCompletion:^(LBAlbumModel *model) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        photoPickerVc.albumModel = model;
        [strongSelf pushViewController:photoPickerVc animated:NO];
        
    }];
    
}

#pragma mark - 相机拍照
// 点击拍照
- (void)takePhoto {
    NSLog(@"%@",@"takePhoto");
    __weak __typeof(self) weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && LBIOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (LBIOS7Later) {
            // 让拍照授权后，更快的调用拍照界面
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf userDidAuthorizationCompletion:granted];
                    });
                }];
            });
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([LBImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([LBImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[LBImageManager manager] requestAuthorizationWithCompletion:^{
            [weakSelf userDidAuthorizationCompletion:([LBImageManager authorizationStatus] == 3)];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 用户授权结果
- (void)userDidAuthorizationCompletion:(BOOL)granted {
    __weak __typeof(self) weakSelf = self;
    NSLog(@"%@",@"takePhoto2");
    if (granted) { // 允许授权
        [weakSelf takePhoto];
    }else {
        if (!self.isCameraInside) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                [weakSelf callDelegateMethodCancel];
            }];
        }
    }
}

// 调用相机
- (void)pushImagePickerController {
    NSLog(@"%@",@"pushImagePickerController");
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(LBIOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        
        UIViewController *vc = [LBImageManager manager].photoVc ?: self;
        NSLog(@"%@",@"presentViewController");
        [vc presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

// 拍照后更新数据源
- (void)reloadPhotoArrayAfterCamera {
    
    __weak __typeof(self) weakSelf = self;
    
    [[LBImageManager manager] getCameraRollAlbumWithCompletion:^(LBAlbumModel *model) {
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.hud hidden];
        LBAssetModel *assetModel;
        // 现有的数据源
        NSMutableArray *assects = [[NSMutableArray alloc] initWithArray:self.selectedAlbumModel.models];
        
        if (strongSelf.sortAscendingByModificationDate) {
            assetModel = [model.models lastObject];
            [assects addObject:assetModel];
        } else {
            assetModel = [model.models firstObject];
            [assects insertObject:assetModel atIndex:0];
        }
        
        if (!strongSelf.isCameraInside) {
            [strongSelf.selectedModels addObject:assetModel];
            [strongSelf didFinishPicking];
        }else {
            [strongSelf changeAssetModelStatus:assetModel];
            // 多选模式需要刷新界面
            strongSelf.selectedAlbumModel.models = assects.copy;
            [[LBImageManager manager].photoVc refreshCollectionViewWithindexPaths:nil];
        }
        
    }];
}

#pragma mark - 数据处理
// 清空选项
- (void)clearAllSelectedModels {
    self.nextIndex = 0;
    for (LBAssetPickerModel *pickerModel in self.shouldSelectedModels) {
        pickerModel.assetModel = nil;
    }
    for (LBAssetModel *model in self.selectedModels) {
        model.selctedIndex = 0;
        model.selected = NO;
    }
    
    [self.selectedModels removeAllObjects];
    [self refreshBottomStatus];
}

- (void)configDefaultSetting {
    self.sortAscendingByModificationDate = NO;
    self.autoDismiss = YES;
    self.showCamera = YES;
    [LBImageManager manager].pickerVc = self;
}

#pragma mark change status
// 改变图片选择状态
- (void)changeAssetModelStatus:(LBAssetModel *)assetModel {
    if (!assetModel) {
        return;
    }
    
    // 已完成最大可选数量
    if (self.selectedModels.count >= self.maxImagesCount && !assetModel.selected) {
        [self showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",self.maxImagesCount]];
        return;
    }
    
    assetModel.selected = !assetModel.selected;
    // 选中获取大图
    if (assetModel.isSelected) {
        [self.selectedModels addObject:assetModel];
        if (!assetModel.PreviewImage) {
            [[LBImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:LBPHONEWIDTH completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    assetModel.PreviewImage = photo;
                }
            }];
        }
        
    }else {
        [self.selectedModels removeObject:assetModel];
    }
    
    if (self.maxImagesCount == 1) { // 单选模式
        [self didFinishPicking];
        return;
    }
    
    
    if (self.isOrderly) {
        if (assetModel.isSelected) {
            LBAssetPickerModel *pickerModel = self.shouldSelectedModels[self.nextIndex];
            assetModel.selctedIndex = self.nextIndex;
            pickerModel.assetModel = assetModel;
        }else {
            LBAssetPickerModel *pickerModel = self.shouldSelectedModels[assetModel.selctedIndex];
            assetModel.selctedIndex = 0;
            pickerModel.assetModel = nil;
        }
        
        for (int i = 0; i < self.shouldSelectedModels.count; i++) {
            LBAssetPickerModel *pickerModel = self.shouldSelectedModels[i];
            if (!pickerModel.assetModel) {
                self.nextIndex = i;
                break;
            }
        }
    }else {
        // 无序的时候，只有取消操作需要刷新列表
        if (!assetModel.isSelected) {
            assetModel.selctedIndex = 0;
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0; i < self.selectedModels.count; i++) {
                LBAssetModel *model = self.selectedModels[i];
                model.selctedIndex = i;
                NSInteger cellIndex = [self.selectedAlbumModel.models indexOfObject:model] + (self.selectedAlbumModel.supportCamera && self.isShowCamere && !self.sortAscendingByModificationDate);
                [indexPaths addObject:[NSIndexPath indexPathForRow:cellIndex inSection:0]];
            }
            [[LBImageManager manager].photoVc refreshCollectionViewWithindexPaths:indexPaths.copy];
        }else {
            assetModel.selctedIndex = self.nextIndex;
        }
        
        self.nextIndex = self.selectedModels.count;
        
    }
    
    [self refreshBottomStatus];
}

// 改变底部提示状态
- (void)refreshBottomStatus {
    [self.nextTipBtn setTitle:[NSString stringWithFormat:@"下一步(%ld/%ld)",(long)self.selectedModels.count,(long)self.maxImagesCount] forState:UIControlStateNormal];
    
    self.nextTipBtn.enabled = self.selectedModels.count;
    
    if (!self.isOrderly) {
        return;
    }
    
    if (self.selectedModels.count == self.maxImagesCount) {
        self.nextTipLabel.text = @"已全部选完！";
    }else {
        LBAssetPickerModel *pickerModel = self.shouldSelectedModels[self.nextIndex];
        self.nextTipLabel.text = [NSString stringWithFormat:@"请选择%@",pickerModel.title];
    }
}



#pragma mark - end event
- (void)didCancelPicking {
    if (self.autoDismiss) {
        __weak __typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakSelf callDelegateMethodCancel];
        }];
    } else {
        [self callDelegateMethodCancel];
    }
}

// 完成选择
- (void)didFinishPicking {
    self.hud = [LBImagPickerHUD show];
    // 获取选中的数组
    NSArray *selectedArray;
    if (self.isOrderly) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"selctedIndex" ascending:YES];//NO：逆序   YES：正序
        NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
        
        selectedArray = [self.selectedModels.copy sortedArrayUsingDescriptors:sortDescriptors];
    }else {
        selectedArray = self.selectedModels.copy;
    }
    
    NSMutableArray *imagesArray = [NSMutableArray array];
    __block int finishCount = 0;
    for (LBAssetModel *model in selectedArray) {
        if (model.PreviewImage) {
            [imagesArray addObject:model.PreviewImage];
            finishCount++;
            continue;
        }
        
        __weak __typeof(self) weakSelf = self;
        [[LBImageManager manager] getPhotoWithAsset:model.asset photoWidth:LBPHONEWIDTH completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!isDegraded) {
                model.PreviewImage = photo;
                [imagesArray addObject:model.PreviewImage];
                finishCount ++;
                
                if (finishCount == selectedArray.count) {
                    [strongSelf.hud hidden];
                    [strongSelf callDelegateMethodFinish:selectedArray images:imagesArray.copy];
                    if (strongSelf.autoDismiss) {
                        [strongSelf dismissViewControllerAnimated:YES completion:^{
                        }];
                    }
                }
            }
        }];
    }
    
    if (finishCount == selectedArray.count) {
        [self.hud hidden];
        [self callDelegateMethodFinish:selectedArray images:imagesArray.copy];
        if (self.autoDismiss) {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }
}

#pragma mark - UI
- (void)setupFooterView {
    
    CGFloat tipViewH = 36 * self.isOrderly;
    CGFloat nextViewH = 60;
    CGFloat marginH = 5 * self.isOrderly;
    CGFloat bottomH = tipViewH + marginH + nextViewH;
    
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.frame = CGRectMake(0, self.view.lb_height - bottomH, LBPHONEWIDTH, bottomH);
    bottomBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomBar];
    self.bottomBar = bottomBar;
    
    if (self.isOrderly) {
        // tip
        UIView *tipBottomView = [[UIView alloc] init];
        tipBottomView.frame = CGRectMake(0, 0, LBPHONEWIDTH, tipViewH);
        tipBottomView.backgroundColor = [UIColor colorWithRed:42/255.0 green:43/255.0 blue:50/255.0 alpha:0.9];
        [bottomBar addSubview:tipBottomView];
        
        UIImageView *tipIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, (tipViewH - 22) * 0.5, 13, 22)];
        tipIcon.image = [LBImageManager imageNamed:@"LBImagePicker_nextTipIcon@2x.png"];
        [tipBottomView addSubview:tipIcon];
        
        UILabel *nextTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, LBPHONEWIDTH, tipViewH)];
        nextTipLabel.numberOfLines = 1;
        nextTipLabel.font = [UIFont systemFontOfSize:14];
        nextTipLabel.textColor = [UIColor whiteColor];
        [tipBottomView addSubview:nextTipLabel];
        self.nextTipLabel = nextTipLabel;
    }
    
    
    // next btn
    UIView *backgroudView = [[UIView alloc] init];
    backgroudView.frame = CGRectMake(0, bottomH - nextViewH, LBPHONEWIDTH, nextViewH);
    backgroudView.backgroundColor = [UIColor whiteColor];
    [bottomBar addSubview:backgroudView];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (nextViewH - 40) * 0.5, LBPHONEWIDTH - 20, 40)];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:16];
    nextButton.layer.cornerRadius = 4;
    nextButton.layer.masksToBounds = YES;
    
    
    [nextButton setBackgroundImage:[LBImageManager imageWithColor:[UIColor colorWithRed:254/255.0 green:94/255.0 blue:94/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[LBImageManager imageWithColor:[UIColor colorWithRed:234/255.0 green:80/255.0 blue:80/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    [nextButton setBackgroundImage:[LBImageManager imageWithColor:[UIColor colorWithRed:252/255.0 green:159/255.0 blue:160/255.0 alpha:1.0]] forState:UIControlStateDisabled];
    [nextButton addTarget:self action:@selector(didFinishPicking) forControlEvents:UIControlEventTouchUpInside];
    
    [backgroudView addSubview:nextButton];
    self.nextTipBtn = nextButton;
    [self refreshBottomStatus];
}

// 显示外部拍照按钮
- (void)showCamerraOutSideView {
     self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.hidden = YES;
    LBPhotoSheetAlertView *sheetView = [[LBPhotoSheetAlertView alloc] init];
    if (self.isShowCamere) {
        [sheetView addSheetWithTitle:@"拍照" titleColor:nil target:self action:@selector(takePhoto)];
    }
    [sheetView addSheetWithTitle:@"从相册中选取" titleColor:nil target:self action:@selector(pushPhotoPickerVc)];
    [sheetView showOnView:self.view cancelTitle:@"关闭" exampleImage:nil];
}

// 构建设置提示内容
- (void)setupSettingTipView {
    UILabel *settingTipLbel = [[UILabel alloc] init];
    settingTipLbel.frame = CGRectMake(8, 120, self.view.lb_width - 16, 60);
    settingTipLbel.textAlignment = NSTextAlignmentCenter;
    settingTipLbel.numberOfLines = 0;
    settingTipLbel.font = [UIFont systemFontOfSize:16];
    settingTipLbel.textColor = [UIColor blackColor];
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    NSString *tipText = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册",appName];
    settingTipLbel.text = tipText;
    [self.view addSubview:settingTipLbel];
    self.settingTipLbel = settingTipLbel;
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    settingBtn.frame = CGRectMake(0, 180, self.view.lb_width, 44);
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    self.settingBtn = settingBtn;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
}

- (void)observeAuthrizationStatusChange {
    if ([[LBImageManager manager] authorizationStatusAuthorized]) {
        [self.settingTipLbel removeFromSuperview];
        [self.settingBtn removeFromSuperview];
        [self.timer invalidate];
        self.timer = nil;
        [self pushPhotoPickerVc];
    }
}

// 跳转手机设置界面
- (void)settingBtnClick {
    if (LBIOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
            [[UIApplication sharedApplication] openURL:privacyUrl];
        } else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark - 显示提示
#pragma mark alert
- (void)showAlertWithTitle:(NSString *)title {
    if (LBIOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - callBack LBImagePickerControllerDelegate method
- (void)callDelegateMethodCancel {
    if ([self.aDelegate respondsToSelector:@selector(LBImagePickerControllerDidCancel:)]) {
        [self.aDelegate LBImagePickerControllerDidCancel:self];
    }
    
    if (self.LBImagePickerControllerDidCancelBlock) {
        self.LBImagePickerControllerDidCancelBlock();
    }
}

- (void)callDelegateMethodFinish:(NSArray *)selectedArray images:images{
    if ([self.aDelegate respondsToSelector:@selector(LBImagePickerController:didFinishPickingPhotos:images:)]) {
        [self.aDelegate LBImagePickerController:self didFinishPickingPhotos:selectedArray images:images];
    }
    
    if (self.LBImagePickerDidFinishPickingPhotosBlock) {
        self.LBImagePickerDidFinishPickingPhotosBlock(selectedArray,images);
    }
}


#pragma mark - deledate
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![viewController isKindOfClass:[LBPhotoPickerPreviewController class]]) {
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelPicking)];
    }
    
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        self.hud = [LBImagPickerHUD show];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            __weak __typeof(self) weakSelf = self;
            [[LBImageManager manager] savePhotoWithImage:photo completion:^(NSError *error){
                if (!error) {
                    [weakSelf reloadPhotoArrayAfterCamera];
                }
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (!self.isCameraInside) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self callDelegateMethodCancel];
        }];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.isCameraInside) {
        __weak __typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:NO completion:^{
            [weakSelf callDelegateMethodCancel];
        }];
    }
    
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (LBIOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}


#pragma mark - set method
- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [LBImageManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}


#pragma mark - lazy method
- (NSMutableArray *)shouldSelectedModels {
    if (!_shouldSelectedModels) {
        _shouldSelectedModels = [NSMutableArray array];
    }
    return _shouldSelectedModels;
}

- (NSMutableArray *)selectedModels {
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (LBIOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[LBImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[LBImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dealloc
- (void)dealloc {
    _timer = nil;
    _bottomBar = nil;
    _imagePickerVc = nil;
    [LBImageManager manager].pickerVc = nil;
}
@end
