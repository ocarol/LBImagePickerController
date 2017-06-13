//
//  LBPhotoSheetAlertView.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/8.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoSheetAlertView.h"
#import "LBImagePickerController.h"

@interface LBPhotoSheetAlertView()
@property (nonatomic,weak) UIImageView *exampleImage;
@property (nonatomic,weak) UIView *bottomView;
@property (nonatomic,copy) NSString *cancelTitle;
@property (nonatomic, strong) NSMutableArray <LBPhotoSheetAlertModel *>*sheets;
@end

@implementation LBPhotoSheetAlertView

- (void)addSheetWithTitle:(NSString *)title titleColor:(UIColor *)titleColor target:(nullable id)target action:(SEL)action {
    LBPhotoSheetAlertModel *model = [[LBPhotoSheetAlertModel alloc] init];
    model.target = target;
    model.action = action;
    model.title = title;
    model.titleColor = titleColor;
    
    [self.sheets addObject:model];
}


- (UIView *)showOnView:(UIView *)view cancelTitle:(NSString *)cancelTitle exampleImage:(UIImage *)exampleImage {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    
    self.frame = CGRectMake(0, 0, LBPHONEWIDTH, LBPHONEHEIGHT);
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.exampleImgName = self.exampleImgName;
    self.cancelTitle = cancelTitle;
    [self setupUI];
    [self showOnView:view];
    
    return self;
}

- (void)setupUI {
    CGFloat imageMarginW = 40;
    CGFloat imageW = LBPHONEWIDTH - imageMarginW * 2;
    
    UIImageView *exampleImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageMarginW, 122, imageW, imageW)];
    exampleImage.backgroundColor = [UIColor clearColor];
    exampleImage.image = [UIImage imageNamed:self.exampleImgName];
    [self addSubview:exampleImage];
    self.exampleImage = exampleImage;
    
    if (exampleImage.image) {
        UIImageView *exampleIcon= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 84)];
        exampleIcon.image = [LBImageManager imageNamed:@"LBPhotoPreview_example@2x.png"];
        [exampleImage addSubview:exampleIcon];
        
    }
    
    CGFloat btnH = 51;
    CGFloat bottomH = (self.sheets.count + 1) * 51 + 11;
    UIView  *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, LBPHONEHEIGHT - bottomH , LBPHONEWIDTH, bottomH)];
    bottomView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    [self addSubview:bottomView];
    self.bottomView = bottomView;
    
    for (int i = 0; i < self.sheets.count; i++) {
        LBPhotoSheetAlertModel *model = self.sheets[i];
        
        UIView *sheetView = [self btnViewWithPiontY:i * btnH target:self action:@selector(didClickSheet:) title:model.title titleColor:model.titleColor showTopLine:NO showBottomLine:YES tag:i];
        [bottomView addSubview:sheetView];
    }
    
    UIColor *cancelTitleColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    UIView * cancelView = [self btnViewWithPiontY:bottomView.lb_height - btnH target:self action:@selector(didClickCancel) title:self.cancelTitle titleColor:cancelTitleColor showTopLine:NO showBottomLine:YES tag:100];
    [bottomView addSubview:cancelView];
}

- (UIView *)lineViewWithPiontY:(CGFloat)pointY {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, LBPHONEWIDTH, 1.0)];
    line.backgroundColor =  [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
    return line;
}

- (UIView *)btnViewWithPiontY:(CGFloat)pointY target:(nullable id)target action:(SEL)action title:(NSString *)title titleColor:(UIColor *)titleColor showTopLine:(BOOL)showTopLine showBottomLine:(BOOL)showBottomLine tag:(NSInteger)tag {
    CGFloat btnH = 51;
    UIColor *fontColor = titleColor ? titleColor : [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, LBPHONEWIDTH, btnH)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:bgView.bounds];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    [bgView addSubview:btn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:bgView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.textColor = fontColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:titleLabel];
    
    if (showTopLine) {
        UIView *line = [self lineViewWithPiontY:0];
        [bgView addSubview:line];
    }
    
    if (showBottomLine) {
        UIView *line = [self lineViewWithPiontY:bgView.lb_bottom - 1];
        [bgView addSubview:line];
    }
    
    
    return bgView;
}

- (NSMutableArray *)sheets {
    if (!_sheets) {
        _sheets = [NSMutableArray array];
    }
    
    return _sheets;
}

- (void)didClickSheet:(UIButton *)sheet {
    if (sheet.tag >= self.sheets.count) {
        [self remove];
        return;
    }
    
    LBPhotoSheetAlertModel *model = self.sheets[sheet.tag];
    if (model.target && [model.target respondsToSelector:model.action]) {
        [model.target performSelectorOnMainThread:model.action withObject:nil waitUntilDone:YES];
        [self remove];
    }    
}

- (void)didClickCancel {
    [self remove];
    [[LBImageManager manager].pickerVc didCancelPicking];
}

- (void)showOnView:(UIView *)onView {
    __weak __typeof(self) weakSelf = self;
    self.bottomView.lb_top = LBPHONEHEIGHT;
    [UIView animateWithDuration:0.25f animations:^{
        weakSelf.bottomView.lb_top = LBPHONEHEIGHT - weakSelf.bottomView.lb_height;
    } completion:^(BOOL finished) {
        
    }];
    
    [onView addSubview:self];
}

- (void)remove {
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.25f animations:^{
        weakSelf.bottomView.lb_top = LBPHONEHEIGHT;
        weakSelf.exampleImage.alpha = 0.1;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}

@end


@implementation LBPhotoSheetAlertModel
@end
