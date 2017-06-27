//
//  LBPhotoPickerCell.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoPickerCell.h"

@interface LBPhotoPickerCell()

/** 相册图片 */
@property (nonatomic, weak) UIImageView *photoImageView;

/** 选中按钮 */
@property (nonatomic, weak) UIButton *selectButton;
@property (nonatomic, weak) UIImageView *selectIcon;
@property (nonatomic, weak) UILabel *selectNumLabel;


@end

@implementation LBPhotoPickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
        
    }
    return self;
}

- (void)setUpUI {
    
    UIImageView *photoImageView = [[UIImageView alloc] init];
    photoImageView.frame = self.contentView.bounds;
    photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    photoImageView.clipsToBounds = YES;
    UIImageView *selectIcon = [[UIImageView alloc] init];
    selectIcon.frame = CGRectMake(6, 6, 20, 20);
    UIButton *selectButton = [[UIButton alloc] init];
    UILabel *selectNumLabel = [[UILabel alloc] init];
    selectNumLabel.frame = selectIcon.frame;
    selectNumLabel.textAlignment = NSTextAlignmentCenter;
    selectNumLabel.textColor = [UIColor whiteColor];
    selectNumLabel.font = [UIFont systemFontOfSize:14.0f];
    
    [self.contentView addSubview:photoImageView];
    [self.contentView addSubview:selectButton];
    [selectButton addSubview:selectIcon];
    [selectButton addSubview:selectNumLabel];
    
    self.photoImageView = photoImageView;
    self.selectIcon = selectIcon;
    self.selectButton = selectButton;
    self.selectNumLabel = selectNumLabel;
    
    self.photoImageView.frame = self.contentView.bounds;
    self.selectButton.frame = CGRectMake(self.contentView.bounds.size.width - 32, 0, 32,32);
    self.selectButton.backgroundColor = [UIColor clearColor];
    [self.selectButton addTarget:self action:@selector(selectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setModel:(LBAssetModel *)model {
    _model = model;
    
   [[LBImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.lb_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.photoImageView.image = photo;
       if (!isDegraded) {
           model.pickerImage = photo;
       }
    }];
    
    [self changeIconStatus];
}

- (void)changeIconStatus {
    
    BOOL isShowSelectedBtn = [LBImageManager manager].pickerVc.maxImagesCount > 1;

    self.selectIcon.hidden = !isShowSelectedBtn;
    self.selectButton.hidden = !isShowSelectedBtn;
    self.selectNumLabel.hidden = !isShowSelectedBtn;

    
    if (isShowSelectedBtn) {
        NSString *selectedImageName = @"LBPhotoPickerCell_photo_selected@2x";
        NSString *unSelectedImageName = @"LBPhotoPickerCell_photo_default@2x.png";
        
        NSString *imageNamed = self.model.isSelected ? selectedImageName : unSelectedImageName;
        self.selectIcon.image = [LBImageManager imageNamed:imageNamed];
        self.selectNumLabel.text = [NSString stringWithFormat:@"%ld",self.model.selctedIndex + 1];
        self.selectNumLabel.hidden = !(self.model.isSelected);
    }
    
}

- (void)selectedButtonDidClick:(UIButton *)button {
    [[LBImageManager manager].pickerVc changeAssetModelStatus:self.model];
    [self changeIconStatus];
}

@end

@implementation LBAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
       UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.contentView.bounds;
        imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [LBImageManager imageNamed:@"takePicture@2x.png"];
        [self addSubview:imageView];
        self.clipsToBounds = YES;
    }
    return self;
}



@end
